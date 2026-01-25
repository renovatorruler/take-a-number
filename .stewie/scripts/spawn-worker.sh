#!/bin/bash
# spawn-worker.sh — Creates a worktree and launches a Claude Code worker
#
# Usage: ./spawn-worker.sh <task-id> <branch-name> [max-iterations]
#
# This is the bash glue. Heavy logic lives in ReScript.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ORCHESTRA_DIR="$PROJECT_ROOT/.stewie"
WORKTREE_BASE="$PROJECT_ROOT/../.worktrees"

# =============================================================================
# Arguments
# =============================================================================

TASK_ID="${1:?Task ID required}"
BRANCH_NAME="${2:?Branch name required}"
MAX_ITERATIONS="${3:-50}"

WORKTREE_PATH="$WORKTREE_BASE/$BRANCH_NAME"

echo "🎭 Orchestra: Spawning worker"
echo "   Task ID: $TASK_ID"
echo "   Branch: $BRANCH_NAME"
echo "   Worktree: $WORKTREE_PATH"
echo "   Max iterations: $MAX_ITERATIONS"

# =============================================================================
# Create worktree
# =============================================================================

if [ -d "$WORKTREE_PATH" ]; then
    echo "⚠️  Worktree already exists, reusing..."
else
    echo "📁 Creating worktree..."
    mkdir -p "$WORKTREE_BASE"
    cd "$PROJECT_ROOT"
    
    # Create branch if it doesn't exist
    if ! git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
        git branch "$BRANCH_NAME"
    fi
    
    git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"
fi

# =============================================================================
# Setup environment
# =============================================================================

cd "$WORKTREE_PATH"

# Symlink .env.local if not present
if [ ! -f ".env.local" ] && [ -f "$PROJECT_ROOT/.env.local" ]; then
    echo "🔗 Linking .env.local..."
    ln -sf "$PROJECT_ROOT/.env.local" .env.local
fi

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install --silent
fi

# =============================================================================
# Write task file
# =============================================================================

TASK_FILE="$WORKTREE_PATH/.stewie-task.json"
cat > "$TASK_FILE" << EOF
{
  "taskId": "$TASK_ID",
  "branch": "$BRANCH_NAME",
  "worktreePath": "$WORKTREE_PATH",
  "maxIterations": $MAX_ITERATIONS,
  "startedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "claudeMdPath": "$PROJECT_ROOT/CLAUDE.md"
}
EOF

echo "📝 Task file written: $TASK_FILE"

# =============================================================================
# Ralph Wiggum Loop
# =============================================================================

echo ""
echo "🔄 Starting Ralph Wiggum loop..."
echo "   Press Ctrl+C to abort"
echo ""

ITERATION=0
STATUS="IN_PROGRESS"
STATUS_FILE="$WORKTREE_PATH/.stewie-status"

while [ $ITERATION -lt $MAX_ITERATIONS ] && [ "$STATUS" != "COMPLETE" ] && [ "$STATUS" != "FAILED" ]; do
    ITERATION=$((ITERATION + 1))
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔁 Iteration $ITERATION / $MAX_ITERATIONS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Run Claude Code
    # The --dangerously-skip-permissions flag allows autonomous operation
    # Claude will read CLAUDE.md from the project root
    
    if command -v claude &> /dev/null; then
        # Claude Code CLI available
        claude --dangerously-skip-permissions \
               --print \
               "Continue working on task $TASK_ID. Check .stewie-task.json for context. Report status at end: IN_PROGRESS, COMPLETE, BLOCKED, or FAILED." \
               2>&1 | tee -a "$WORKTREE_PATH/.stewie-log.txt"
    else
        echo "❌ Claude Code CLI not found. Install with: npm install -g @anthropic-ai/claude-code"
        exit 1
    fi
    
    # Check status file (Claude should update this)
    if [ -f "$STATUS_FILE" ]; then
        STATUS=$(cat "$STATUS_FILE" | tr -d '[:space:]')
        echo "📊 Status: $STATUS"
    fi
    
    # Brief pause between iterations
    sleep 2
done

# =============================================================================
# Completion
# =============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$STATUS" == "COMPLETE" ]; then
    echo "✅ Task completed successfully after $ITERATION iterations"
elif [ "$STATUS" == "FAILED" ]; then
    echo "❌ Task failed after $ITERATION iterations"
    exit 1
elif [ $ITERATION -ge $MAX_ITERATIONS ]; then
    echo "⚠️  Max iterations reached ($MAX_ITERATIONS). Escalating to orchestrator."
    echo "ESCALATED" > "$STATUS_FILE"
    exit 2
else
    echo "⏹️  Loop exited with status: $STATUS"
fi

echo ""
echo "📁 Worktree: $WORKTREE_PATH"
echo "📝 Logs: $WORKTREE_PATH/.stewie-log.txt"
