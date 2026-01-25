// Orchestra Types — the foundation
// All orchestration logic uses these types. No stringly-typed nonsense.

// =============================================================================
// Task Types
// =============================================================================

type taskId = TaskId(string)

type taskPriority =
  | Critical
  | High
  | Medium
  | Low

type taskType =
  | Feature
  | Bugfix
  | Refactor
  | Chore

type taskStatus =
  | Pending
  | InProgress
  | Blocked(string) // reason
  | Complete
  | Failed(string) // error

type verificationCheck =
  | Compiles
  | RunsLocally
  | NoConsoleErrors
  | FeatureWorks
  | TestsPass

type verificationResult = {
  check: verificationCheck,
  passed: bool,
  details: option<string>,
}

type task = {
  id: taskId,
  title: string,
  description: string,
  taskType: taskType,
  priority: taskPriority,
  status: taskStatus,
  acceptanceCriteria: array<string>,
  verificationChecks: array<verificationCheck>,
  worktreePath: option<string>,
  linearIssueId: option<string>,
  createdAt: float,
  updatedAt: float,
}

// =============================================================================
// Worker Types
// =============================================================================

type workerId = WorkerId(string)

type workerState =
  | Idle
  | Starting
  | Running(int) // current iteration
  | WaitingForVerification
  | Completed
  | Escalated(string) // reason
  | Crashed(string) // error

type workerConfig = {
  maxIterations: int,
  timeoutMs: int,
  worktreeBasePath: string,
}

type worker = {
  id: workerId,
  taskId: taskId,
  state: workerState,
  iterations: int,
  startedAt: option<float>,
  completedAt: option<float>,
  logs: array<string>,
}

// =============================================================================
// CodeRabbit Loop Detection
// =============================================================================

type codeRabbitSuggestion = {
  id: string,
  file: string,
  line: int,
  suggestion: string,
  appliedAt: option<float>,
  revertedAt: option<float>,
}

type loopDetectionResult =
  | NoLoop
  | PotentialLoop(array<codeRabbitSuggestion>)
  | ConfirmedLoop(codeRabbitSuggestion, codeRabbitSuggestion) // the conflicting pair

// =============================================================================
// Orchestrator Commands
// =============================================================================

type orchestratorCommand =
  | SpawnWorker(task)
  | CheckWorkerStatus(workerId)
  | KillWorker(workerId)
  | EscalateToHuman(workerId, string) // reason
  | MarkTaskComplete(taskId)
  | RunVerification(taskId, array<verificationCheck>)

type orchestratorEvent =
  | WorkerSpawned(workerId, taskId)
  | WorkerProgress(workerId, int, string) // iteration, message
  | WorkerCompleted(workerId, taskId)
  | WorkerFailed(workerId, string)
  | WorkerEscalated(workerId, string)
  | VerificationPassed(taskId)
  | VerificationFailed(taskId, array<verificationResult>)
  | CodeRabbitLoopDetected(taskId, loopDetectionResult)

// =============================================================================
// Helpers
// =============================================================================

let taskIdToString = (TaskId(id)) => id
let workerIdToString = (WorkerId(id)) => id

let taskStatusToString = status =>
  switch status {
  | Pending => "pending"
  | InProgress => "in_progress"
  | Blocked(reason) => `blocked: ${reason}`
  | Complete => "complete"
  | Failed(error) => `failed: ${error}`
  }

let workerStateToString = state =>
  switch state {
  | Idle => "idle"
  | Starting => "starting"
  | Running(iteration) => `running (iteration ${iteration->Int.toString})`
  | WaitingForVerification => "waiting_for_verification"
  | Completed => "completed"
  | Escalated(reason) => `escalated: ${reason}`
  | Crashed(error) => `crashed: ${error}`
  }
