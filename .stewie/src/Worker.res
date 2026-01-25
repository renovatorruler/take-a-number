// Worker state machine
// Manages the lifecycle of a Claude Code worker in a Ralph Wiggum loop

open Types

// =============================================================================
// Worker Creation
// =============================================================================

let make = (~id: string, ~taskId: taskId, ~_config: workerConfig): worker => {
  {
    id: WorkerId(id),
    taskId,
    state: Idle,
    iterations: 0,
    startedAt: None,
    completedAt: None,
    logs: [],
  }
}

let generateId = (): string => {
  // Simple unique ID: timestamp + random suffix
  let timestamp = Date.now()->Float.toString
  let random = Math.random()->Float.toString->String.sliceToEnd(~start=2)
  `worker-${timestamp}-${random}`
}

// =============================================================================
// State Transitions
// =============================================================================

type stateTransitionError =
  | InvalidStateTransition(workerState, workerState)
  | MaxIterationsReached(int)
  | WorkerNotRunning

let canTransitionState = (from: workerState, to: workerState): bool =>
  switch (from, to) {
  // From Idle
  | (Idle, Starting) => true

  // From Starting
  | (Starting, Running(_)) => true
  | (Starting, Crashed(_)) => true

  // From Running
  | (Running(_), Running(_)) => true // iteration increment
  | (Running(_), WaitingForVerification) => true
  | (Running(_), Escalated(_)) => true
  | (Running(_), Crashed(_)) => true

  // From WaitingForVerification
  | (WaitingForVerification, Running(_)) => true // verification failed, retry
  | (WaitingForVerification, Completed) => true
  | (WaitingForVerification, Escalated(_)) => true

  // Terminal states: no transitions out
  | (Completed, _) => false
  | (Escalated(_), _) => false
  | (Crashed(_), _) => false

  | _ => false
  }

let transitionState = (
  worker: worker,
  newState: workerState,
): result<worker, stateTransitionError> => {
  if !canTransitionState(worker.state, newState) {
    Error(InvalidStateTransition(worker.state, newState))
  } else {
    let now = Date.now()
    let worker = {
      ...worker,
      state: newState,
    }

    // Update timestamps based on state
    let worker = switch newState {
    | Starting => {...worker, startedAt: Some(now)}
    | Completed | Escalated(_) | Crashed(_) => {...worker, completedAt: Some(now)}
    | _ => worker
    }

    Ok(worker)
  }
}

// =============================================================================
// Iteration Management
// =============================================================================

let incrementIteration = (worker: worker, config: workerConfig): result<worker, stateTransitionError> => {
  let newIteration = worker.iterations + 1

  if newIteration >= config.maxIterations {
    Error(MaxIterationsReached(config.maxIterations))
  } else {
    switch worker.state {
    | Running(_) =>
      Ok({
        ...worker,
        iterations: newIteration,
        state: Running(newIteration),
      })
    | _ => Error(WorkerNotRunning)
    }
  }
}

let shouldEscalate = (worker: worker, config: workerConfig): bool => {
  worker.iterations >= config.maxIterations - 5 // Warn 5 iterations before max
}

// =============================================================================
// Logging
// =============================================================================

let addLog = (worker: worker, message: string): worker => {
  let timestamp = Date.now()->Date.fromTime->Date.toISOString
  let logEntry = `[${timestamp}] ${message}`
  {
    ...worker,
    logs: worker.logs->Array.concat([logEntry]),
  }
}

// =============================================================================
// Status Checks
// =============================================================================

let isTerminal = (worker: worker): bool =>
  switch worker.state {
  | Completed | Escalated(_) | Crashed(_) => true
  | _ => false
  }

let isRunning = (worker: worker): bool =>
  switch worker.state {
  | Running(_) | WaitingForVerification => true
  | _ => false
  }

let canAcceptWork = (worker: worker): bool =>
  switch worker.state {
  | Idle => true
  | _ => false
  }

// =============================================================================
// Summary
// =============================================================================

type workerSummary = {
  id: string,
  taskId: string,
  state: string,
  iterations: int,
  maxIterations: int,
  runningTimeMs: option<float>,
}

let summarize = (worker: worker, config: workerConfig): workerSummary => {
  let (WorkerId(id)) = worker.id
  let (TaskId(taskId)) = worker.taskId

  let runningTimeMs = switch (worker.startedAt, worker.completedAt) {
  | (Some(start), Some(end)) => Some(end -. start)
  | (Some(start), None) => Some(Date.now() -. start)
  | _ => None
  }

  {
    id,
    taskId,
    state: worker.state->workerStateToString,
    iterations: worker.iterations,
    maxIterations: config.maxIterations,
    runningTimeMs,
  }
}
