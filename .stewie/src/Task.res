// Task parsing and validation
// Ensures tasks are well-formed before workers touch them

open Types

// =============================================================================
// Task Creation
// =============================================================================

let make = (
  ~id: string,
  ~title: string,
  ~description: string,
  ~taskType: taskType,
  ~priority: taskPriority,
  ~acceptanceCriteria: array<string>,
  ~verificationChecks: array<verificationCheck>,
  ~linearIssueId: option<string>=?,
) => {
  let now = Date.now()
  {
    id: TaskId(id),
    title,
    description,
    taskType,
    priority,
    status: Pending,
    acceptanceCriteria,
    verificationChecks,
    worktreePath: None,
    linearIssueId,
    createdAt: now,
    updatedAt: now,
  }
}

// =============================================================================
// Validation
// =============================================================================

type validationError =
  | EmptyTitle
  | EmptyDescription
  | NoAcceptanceCriteria
  | NoVerificationChecks
  | InvalidId

let validate = (task: task): result<task, array<validationError>> => {
  let errors = []

  if task.title->String.trim->String.length === 0 {
    errors->Array.push(EmptyTitle)
  }

  if task.description->String.trim->String.length === 0 {
    errors->Array.push(EmptyDescription)
  }

  if task.acceptanceCriteria->Array.length === 0 {
    errors->Array.push(NoAcceptanceCriteria)
  }

  if task.verificationChecks->Array.length === 0 {
    errors->Array.push(NoVerificationChecks)
  }

  let (TaskId(id)) = task.id
  if id->String.trim->String.length === 0 {
    errors->Array.push(InvalidId)
  }

  if errors->Array.length > 0 {
    Error(errors)
  } else {
    Ok(task)
  }
}

let validationErrorToString = error =>
  switch error {
  | EmptyTitle => "Task title cannot be empty"
  | EmptyDescription => "Task description cannot be empty"
  | NoAcceptanceCriteria => "Task must have at least one acceptance criterion"
  | NoVerificationChecks => "Task must have at least one verification check"
  | InvalidId => "Task ID cannot be empty"
  }

// =============================================================================
// Status Transitions
// =============================================================================

type transitionError =
  | InvalidTransition(taskStatus, taskStatus)
  | AlreadyComplete
  | AlreadyFailed

let canTransition = (from: taskStatus, to: taskStatus): bool =>
  switch (from, to) {
  // From Pending
  | (Pending, InProgress) => true
  | (Pending, Blocked(_)) => true

  // From InProgress
  | (InProgress, Complete) => true
  | (InProgress, Failed(_)) => true
  | (InProgress, Blocked(_)) => true

  // From Blocked
  | (Blocked(_), InProgress) => true
  | (Blocked(_), Failed(_)) => true

  // No transitions from terminal states
  | (Complete, _) => false
  | (Failed(_), _) => false

  // Same state is always allowed (no-op)
  | (a, b) if a == b => true

  | _ => false
  }

let transition = (task: task, newStatus: taskStatus): result<task, transitionError> => {
  if !canTransition(task.status, newStatus) {
    Error(InvalidTransition(task.status, newStatus))
  } else {
    Ok({
      ...task,
      status: newStatus,
      updatedAt: Date.now(),
    })
  }
}

// =============================================================================
// Serialization (for task.json files)
// =============================================================================

let taskTypeToString = taskType =>
  switch taskType {
  | Feature => "feature"
  | Bugfix => "bugfix"
  | Refactor => "refactor"
  | Chore => "chore"
  }

let taskTypeFromString = str =>
  switch str {
  | "feature" => Some(Feature)
  | "bugfix" => Some(Bugfix)
  | "refactor" => Some(Refactor)
  | "chore" => Some(Chore)
  | _ => None
  }

let priorityToString = priority =>
  switch priority {
  | Critical => "critical"
  | High => "high"
  | Medium => "medium"
  | Low => "low"
  }

let priorityFromString = str =>
  switch str {
  | "critical" => Some(Critical)
  | "high" => Some(High)
  | "medium" => Some(Medium)
  | "low" => Some(Low)
  | _ => None
  }

let verificationCheckToString = check =>
  switch check {
  | Compiles => "compiles"
  | RunsLocally => "runs_locally"
  | NoConsoleErrors => "no_console_errors"
  | FeatureWorks => "feature_works"
  | TestsPass => "tests_pass"
  }

let verificationCheckFromString = str =>
  switch str {
  | "compiles" => Some(Compiles)
  | "runs_locally" => Some(RunsLocally)
  | "no_console_errors" => Some(NoConsoleErrors)
  | "feature_works" => Some(FeatureWorks)
  | "tests_pass" => Some(TestsPass)
  | _ => None
  }

// =============================================================================
// Default verification checks by task type
// =============================================================================

let defaultVerificationChecks = (taskType: taskType): array<verificationCheck> =>
  switch taskType {
  | Feature => [Compiles, RunsLocally, NoConsoleErrors, FeatureWorks]
  | Bugfix => [Compiles, RunsLocally, NoConsoleErrors, TestsPass]
  | Refactor => [Compiles, TestsPass]
  | Chore => [Compiles]
  }
