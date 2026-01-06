#!/usr/bin/env bash
set -euo pipefail

# Sideshow Bob Stop Hook
# Intercepts exit attempts and evolves the prompt based on learnings from the previous iteration.
# Like Bob's elaborate revenge schemes, each attempt learns from previous failures.
# This is the key differentiator from ralph-wiggum: the prompt IMPROVES each iteration.

STATE_FILE=".claude/sideshow-bob-loop.local.md"

# Allow exit if no active loop
if [[ ! -f "$STATE_FILE" ]]; then
    echo '{"block": false}'
    exit 0
fi

# Parse state file
ACTIVE=$(grep "^active:" "$STATE_FILE" | sed 's/active: *//' || echo "false")
if [[ "$ACTIVE" != "true" ]]; then
    rm -f "$STATE_FILE"
    echo '{"block": false}'
    exit 0
fi

ITERATION=$(grep "^iteration:" "$STATE_FILE" | sed 's/iteration: *//' || echo "1")
MAX_ITERATIONS=$(grep "^max_iterations:" "$STATE_FILE" | sed 's/max_iterations: *//' || echo "0")
COMPLETION_PROMISE=$(grep "^completion_promise:" "$STATE_FILE" | sed 's/completion_promise: *"//' | sed 's/"$//' || echo "")

# Validate numeric fields
if ! [[ "$ITERATION" =~ ^[0-9]+$ ]]; then
    ITERATION=1
fi
if ! [[ "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
    MAX_ITERATIONS=0
fi

# Check max iterations
if [[ "$MAX_ITERATIONS" -gt 0 ]] && [[ "$ITERATION" -ge "$MAX_ITERATIONS" ]]; then
    rm -f "$STATE_FILE"
    echo '{"block": false}'
    exit 0
fi

# Get transcript to check for completion and extract learnings
TRANSCRIPT_FILE="$CLAUDE_TRANSCRIPT"
if [[ -z "${TRANSCRIPT_FILE:-}" ]] || [[ ! -f "$TRANSCRIPT_FILE" ]]; then
    rm -f "$STATE_FILE"
    echo '{"block": false}'
    exit 0
fi

# Get the last assistant message
LAST_MESSAGE=$(jq -rs '[.[] | select(.type == "assistant")] | last | .message.content | map(select(.type == "text")) | map(.text) | join("\n")' "$TRANSCRIPT_FILE" 2>/dev/null || echo "")

if [[ -z "$LAST_MESSAGE" ]]; then
    rm -f "$STATE_FILE"
    echo '{"block": false}'
    exit 0
fi

# Check for completion promise
if [[ -n "$COMPLETION_PROMISE" ]]; then
    if echo "$LAST_MESSAGE" | grep -q "<promise>$COMPLETION_PROMISE</promise>"; then
        rm -f "$STATE_FILE"
        echo '{"block": false}'
        exit 0
    fi
fi

# Extract learnings from the last message (between <learnings> tags)
NEW_LEARNINGS=""
if echo "$LAST_MESSAGE" | grep -q "<learnings>"; then
    NEW_LEARNINGS=$(echo "$LAST_MESSAGE" | sed -n '/<learnings>/,/<\/learnings>/p' | sed '1d;$d' || echo "")
fi

# Extract sections from state file
ORIGINAL_PROMPT=$(sed -n '/^## Original Prompt$/,/^## /{/^## Original Prompt$/d;/^## /d;p;}' "$STATE_FILE" | head -c 50000)
ACCUMULATED_LEARNINGS=$(sed -n '/^## Accumulated Learnings$/,/^## /{/^## Accumulated Learnings$/d;/^## /d;p;}' "$STATE_FILE" | head -c 50000)

# Build new accumulated learnings
if [[ -n "$NEW_LEARNINGS" ]]; then
    ACCUMULATED_LEARNINGS="${ACCUMULATED_LEARNINGS}

### Iteration $ITERATION Learnings:
${NEW_LEARNINGS}"
fi

# Build the evolved prompt
NEXT_ITERATION=$((ITERATION + 1))

if [[ -n "$ACCUMULATED_LEARNINGS" ]] && [[ "$ACCUMULATED_LEARNINGS" != "(No learnings yet - this is iteration 1)" ]]; then
    EVOLVED_PROMPT="# Context from Previous Iterations

You are on iteration ${NEXT_ITERATION} of this task. Here is what has been learned so far:

${ACCUMULATED_LEARNINGS}

---

# Original Task

${ORIGINAL_PROMPT}

---

# Instructions for This Iteration

1. Review the learnings above and the current state of the codebase
2. Continue working on the task, applying what was learned
3. At the end of this iteration, output new learnings in this format:

\`\`\`
<learnings>
- What you discovered or learned this iteration
- What approaches didn't work and why
- What still needs to be done
- Any blockers or edge cases found
</learnings>
\`\`\`

4. When the task is COMPLETELY done, output: <promise>${COMPLETION_PROMISE:-DONE}</promise>"
else
    EVOLVED_PROMPT="${ORIGINAL_PROMPT}

---

# End of Iteration Instructions

At the end of this iteration, please output your learnings:

\`\`\`
<learnings>
- What you discovered or learned
- What approaches didn't work and why
- What still needs to be done
- Any blockers or edge cases found
</learnings>
\`\`\`

When the task is COMPLETELY done, output: <promise>${COMPLETION_PROMISE:-DONE}</promise>"
fi

# Update state file
cat > "$STATE_FILE" << EOF
---
active: true
iteration: ${NEXT_ITERATION}
max_iterations: ${MAX_ITERATIONS}
completion_promise: "${COMPLETION_PROMISE}"
created_at: $(grep "^created_at:" "$STATE_FILE" | sed 's/created_at: *//' || date -Iseconds)
updated_at: $(date -Iseconds)
---

# Sideshow Bob Loop State

## Original Prompt
${ORIGINAL_PROMPT}

## Accumulated Learnings
${ACCUMULATED_LEARNINGS}

## Current Evolved Prompt
${EVOLVED_PROMPT}
EOF

# Build system message for context
SYSTEM_MSG="[Sideshow Bob Loop - Iteration ${NEXT_ITERATION}$([ "$MAX_ITERATIONS" -gt 0 ] && echo " of ${MAX_ITERATIONS}")]"

# Output JSON to block exit and feed evolved prompt
# Escape the prompt for JSON
ESCAPED_PROMPT=$(echo "$EVOLVED_PROMPT" | jq -Rs '.')

cat << EOF
{
    "block": true,
    "reason": ${ESCAPED_PROMPT},
    "systemMessage": "${SYSTEM_MSG}"
}
EOF
