// Stewie — Main orchestration logic
// Entry point for the type-safe orchestration system

open Types

// =============================================================================
// Configuration
// =============================================================================

type config = {
  maxIterationsPerTask: int,
  parallelWorkers: bool,
  worktreeBasePath: string,
  projectRoot: string,
}

let defaultConfig: config = {
  maxIterationsPerTask: 50,
  parallelWorkers: true,
  worktreeBasePath: "../.worktrees",
  projectRoot: ".",
}

// =============================================================================
// Stewietor State
// =============================================================================

type stewietorState = {
  config: config,
  tasks: array<task>,
  workers: array<worker>,
  codeRabbitHistory: CodeRabbitLoop.suggestionHistory,
}

let initialState = (config: config): stewietorState => {
  config,
  tasks: [],
  workers: [],
  codeRabbitHistory: CodeRabbitLoop.emptyHistory(),
}

// =============================================================================
// Task Management
// =============================================================================

let addTask = (state: stewietorState, task: task): result<stewietorState, array<Task.validationError>> => {
  switch Task.validate(task) {
  | Ok(validTask) =>
    Ok({
      ...state,
      tasks: state.tasks->Array.concat([validTask]),
    })
  | Error(errors) => Error(errors)
  }
}

let getTask = (state: stewietorState, taskId: taskId): option<task> => {
  state.tasks->Array.find(t => t.id == taskId)
}

let updateTask = (state: stewietorState, taskId: taskId, updater: task => task): stewietorState => {
  let tasks = state.tasks->Array.map(t =>
    if t.id == taskId {
      updater(t)
    } else {
      t
    }
  )
  {...state, tasks}
}

// =============================================================================
// Worker Management
// =============================================================================

let spawnWorker = (state: stewietorState, taskId: taskId): result<(stewietorState, worker), string> => {
  // Check task exists and is pending
  switch getTask(state, taskId) {
  | None => Error("Task not found")
  | Some(task) =>
    switch task.status {
    | Pending => {
        let workerId = Worker.generateId()
        let workerConfig: workerConfig = {
          maxIterations: state.config.maxIterationsPerTask,
          timeoutMs: 30 * 60 * 1000, // 30 minutes
          worktreeBasePath: state.config.worktreeBasePath,
        }
        let worker = Worker.make(~id=workerId, ~taskId, ~config=workerConfig)

        // Transition task to InProgress
        let state = updateTask(state, taskId, t => {
          ...t,
          status: InProgress,
          updatedAt: Date.now(),
        })

        let state = {
          ...state,
          workers: state.workers->Array.concat([worker]),
        }

        Ok((state, worker))
      }
    | InProgress => Error("Task already in progress")
    | Complete => Error("Task already complete")
    | Failed(_) => Error("Task has failed")
    | Blocked(reason) => Error(`Task is blocked: ${reason}`)
    }
  }
}

let getWorker = (state: stewietorState, workerId: workerId): option<worker> => {
  state.workers->Array.find(w => w.id == workerId)
}

let updateWorker = (
  state: stewietorState,
  workerId: workerId,
  updater: worker => worker,
): stewietorState => {
  let workers = state.workers->Array.map(w =>
    if w.id == workerId {
      updater(w)
    } else {
      w
    }
  )
  {...state, workers}
}

// =============================================================================
// Event Handling
// =============================================================================

let handleEvent = (state: stewietorState, event: stewietorEvent): stewietorState => {
  switch event {
  | WorkerSpawned(workerId, _taskId) =>
    updateWorker(state, workerId, w => {
      ...w,
      state: Starting,
      startedAt: Some(Date.now()),
    })

  | WorkerProgress(workerId, iteration, message) =>
    updateWorker(state, workerId, w => {
      ...w,
      state: Running(iteration),
      iterations: iteration,
      logs: w.logs->Array.concat([message]),
    })

  | WorkerCompleted(workerId, taskId) => {
      let state = updateWorker(state, workerId, w => {
        ...w,
        state: Completed,
        completedAt: Some(Date.now()),
      })
      updateTask(state, taskId, t => {...t, status: Complete, updatedAt: Date.now()})
    }

  | WorkerFailed(workerId, error) =>
    updateWorker(state, workerId, w => {
      ...w,
      state: Crashed(error),
      completedAt: Some(Date.now()),
    })

  | WorkerEscalated(workerId, reason) =>
    updateWorker(state, workerId, w => {
      ...w,
      state: Escalated(reason),
      completedAt: Some(Date.now()),
    })

  | VerificationPassed(taskId) => updateTask(state, taskId, t => {...t, status: Complete, updatedAt: Date.now()})

  | VerificationFailed(_taskId, _results) =>
    // Task stays InProgress, worker will retry
    state

  | CodeRabbitLoopDetected(_taskId, loopResult) =>
    switch CodeRabbitLoop.getRecommendation(loopResult) {
    | CodeRabbitLoop.Stop(reason) =>
      // Find the worker for this task and escalate
      // For now, just log - in real impl would escalate
      Console.log(`CodeRabbit loop detected: ${reason}`)
      state
    | _ => state
    }
  }
}

// =============================================================================
// Command Processing
// =============================================================================

type commandResult =
  | Success(stewietorState)
  | Failure(string)

let processCommand = (state: stewietorState, command: stewietorCommand): commandResult => {
  switch command {
  | SpawnWorker(task) =>
    switch addTask(state, task) {
    | Ok(state) =>
      switch spawnWorker(state, task.id) {
      | Ok((state, _worker)) => Success(state)
      | Error(err) => Failure(err)
      }
    | Error(errors) =>
      let errorStr = errors->Array.map(Task.validationErrorToString)->Array.join(", ")
      Failure(`Validation failed: ${errorStr}`)
    }

  | CheckWorkerStatus(workerId) =>
    // This is a query, doesn't change state
    switch getWorker(state, workerId) {
    | Some(_worker) => Success(state)
    | None => Failure("Worker not found")
    }

  | KillWorker(workerId) =>
    switch getWorker(state, workerId) {
    | Some(worker) =>
      if Worker.isRunning(worker) {
        let state = updateWorker(state, workerId, w => {
          ...w,
          state: Crashed("Killed by stewietor"),
          completedAt: Some(Date.now()),
        })
        Success(state)
      } else {
        Failure("Worker is not running")
      }
    | None => Failure("Worker not found")
    }

  | EscalateToHuman(workerId, reason) =>
    let state = updateWorker(state, workerId, w => {
      ...w,
      state: Escalated(reason),
      completedAt: Some(Date.now()),
    })
    Success(state)

  | MarkTaskComplete(taskId) =>
    switch getTask(state, taskId) {
    | Some(_task) =>
      let state = updateTask(state, taskId, t => {...t, status: Complete, updatedAt: Date.now()})
      Success(state)
    | None => Failure("Task not found")
    }

  | RunVerification(_taskId, _checks) =>
    // In real impl, this would trigger verification scripts
    // For now, just pass through
    Success(state)
  }
}

// =============================================================================
// Status Summary
// =============================================================================

type statusSummary = {
  totalTasks: int,
  pendingTasks: int,
  inProgressTasks: int,
  completedTasks: int,
  failedTasks: int,
  activeWorkers: int,
  totalIterations: int,
}

let getStatus = (state: stewietorState): statusSummary => {
  let countByStatus = (status: taskStatus) =>
    state.tasks->Array.filter(t => t.status == status)->Array.length

  let activeWorkers = state.workers->Array.filter(Worker.isRunning)->Array.length

  let totalIterations = state.workers->Array.reduce(0, (acc, w) => acc + w.iterations)

  {
    totalTasks: state.tasks->Array.length,
    pendingTasks: countByStatus(Pending),
    inProgressTasks: state.tasks->Array.filter(t =>
      switch t.status {
      | InProgress => true
      | _ => false
      }
    )->Array.length,
    completedTasks: countByStatus(Complete),
    failedTasks: state.tasks->Array.filter(t =>
      switch t.status {
      | Failed(_) => true
      | _ => false
      }
    )->Array.length,
    activeWorkers,
    totalIterations,
  }
}
