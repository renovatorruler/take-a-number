// CodeRabbit Loop Detection
// Prevents infinite A→B→A suggestion loops

open Types

// =============================================================================
// Suggestion Tracking
// =============================================================================

type suggestionHistory = {
  suggestions: array<codeRabbitSuggestion>,
  appliedSuggestions: array<string>, // IDs of applied suggestions
  revertedSuggestions: array<string>, // IDs of suggestions that were later undone
}

let emptyHistory = (): suggestionHistory => {
  suggestions: [],
  appliedSuggestions: [],
  revertedSuggestions: [],
}

let addSuggestion = (history: suggestionHistory, suggestion: codeRabbitSuggestion): suggestionHistory => {
  {
    ...history,
    suggestions: history.suggestions->Array.concat([suggestion]),
  }
}

let markApplied = (history: suggestionHistory, suggestionId: string): suggestionHistory => {
  // Update the suggestion's appliedAt timestamp
  let suggestions = history.suggestions->Array.map(s =>
    if s.id === suggestionId {
      {...s, appliedAt: Some(Date.now())}
    } else {
      s
    }
  )

  {
    ...history,
    suggestions,
    appliedSuggestions: history.appliedSuggestions->Array.concat([suggestionId]),
  }
}

let markReverted = (history: suggestionHistory, suggestionId: string): suggestionHistory => {
  // Update the suggestion's revertedAt timestamp
  let suggestions = history.suggestions->Array.map(s =>
    if s.id === suggestionId {
      {...s, revertedAt: Some(Date.now())}
    } else {
      s
    }
  )

  {
    ...history,
    suggestions,
    revertedSuggestions: history.revertedSuggestions->Array.concat([suggestionId]),
  }
}

// =============================================================================
// Loop Detection
// =============================================================================

// Check if a new suggestion conflicts with a previously applied one
let findConflict = (
  history: suggestionHistory,
  newSuggestion: codeRabbitSuggestion,
): option<codeRabbitSuggestion> => {
  // A conflict exists if:
  // 1. There's a previously applied suggestion
  // 2. For the same file and line (or overlapping region)
  // 3. That was subsequently reverted
  // 4. And this new suggestion wants to change it again

  history.suggestions->Array.find(existingSuggestion => {
    let sameLocation =
      existingSuggestion.file === newSuggestion.file &&
      existingSuggestion.line === newSuggestion.line

    let wasAppliedAndReverted =
      existingSuggestion.appliedAt->Option.isSome && existingSuggestion.revertedAt->Option.isSome

    sameLocation && wasAppliedAndReverted
  })
}

// Comprehensive loop detection
let detectLoop = (history: suggestionHistory, newSuggestion: codeRabbitSuggestion): loopDetectionResult => {
  // First, check for direct conflicts (same file/line that was applied then reverted)
  switch findConflict(history, newSuggestion) {
  | Some(conflictingSuggestion) => ConfirmedLoop(conflictingSuggestion, newSuggestion)
  | None => {
      // Check for potential loop patterns:
      // Multiple suggestions for the same location in a short time
      let samLocationSuggestions =
        history.suggestions->Array.filter(s =>
          s.file === newSuggestion.file && s.line === newSuggestion.line
        )

      if samLocationSuggestions->Array.length >= 2 {
        PotentialLoop(samLocationSuggestions)
      } else {
        NoLoop
      }
    }
  }
}

// =============================================================================
// Similarity Detection (for semantic loops)
// =============================================================================

// Sometimes the loop isn't exact same line, but semantically similar suggestions
// e.g., "add error handling" → "remove redundant error handling" → "add error handling"

type semanticPattern =
  | AddRemovePattern // "add X" followed by "remove X"
  | RefactorUndoPattern // refactor that gets undone
  | StyleFlipFlop // style changes that flip back

let extractAction = (suggestion: string): option<(string, string)> => {
  // Very simple pattern matching - in real impl would be more sophisticated
  let lowerSuggestion = suggestion->String.toLowerCase

  if lowerSuggestion->String.includes("add") {
    Some(("add", suggestion))
  } else if lowerSuggestion->String.includes("remove") {
    Some(("remove", suggestion))
  } else if lowerSuggestion->String.includes("delete") {
    Some(("remove", suggestion))
  } else {
    None
  }
}

let detectSemanticLoop = (history: suggestionHistory): option<semanticPattern> => {
  // Look for add/remove patterns on same concept
  let actions = history.suggestions->Array.filterMap(s => {
    switch extractAction(s.suggestion) {
    | Some((action, _)) => Some((s.file, action))
    | None => None
    }
  })

  // Check if same file has both "add" and "remove" actions
  let files = actions->Array.map(((file, _)) => file)->Array.reduce([], (acc, file) => {
    if !(acc->Array.includes(file)) {
      acc->Array.concat([file])
    } else {
      acc
    }
  })

  let hasFlipFlop = files->Array.some(file => {
    let fileActions = actions->Array.filter(((f, _)) => f === file)->Array.map(((_, action)) => action)
    fileActions->Array.includes("add") && fileActions->Array.includes("remove")
  })

  if hasFlipFlop {
    Some(AddRemovePattern)
  } else {
    None
  }
}

// =============================================================================
// Recommended Action
// =============================================================================

type recommendedAction =
  | Continue // No loop, keep going
  | Pause // Potential loop, slow down
  | Stop(string) // Confirmed loop, stop and escalate with reason

let getRecommendation = (detection: loopDetectionResult): recommendedAction =>
  switch detection {
  | NoLoop => Continue
  | PotentialLoop(_) => Pause
  | ConfirmedLoop(prev, current) =>
    Stop(
      `Loop detected: Previous suggestion "${prev.suggestion}" at ${prev.file}:${prev.line->Int.toString} ` ++
      `conflicts with new suggestion "${current.suggestion}"`,
    )
  }
