---
description: Cancel active Sideshow Bob loop
hidden_from_slash_command: true
allowed_tools:
  - Bash(test:*)
  - Bash(rm:*)
  - Read
---

# Cancel Sideshow Bob Loop

Cancel the currently active Sideshow Bob loop.

## Steps

1. Check if `.claude/sideshow-bob-loop.local.md` exists
2. If it doesn't exist, inform the user there's no active loop
3. If it exists:
   - Read the file to get the current iteration number
   - Delete the file
   - Confirm cancellation with the iteration count

## Execution

```bash
if [[ -f ".claude/sideshow-bob-loop.local.md" ]]; then
    # Read current iteration for reporting
    ITERATION=$(grep "^iteration:" .claude/sideshow-bob-loop.local.md | sed 's/iteration: *//')
    rm .claude/sideshow-bob-loop.local.md
    echo "Sideshow Bob loop cancelled at iteration $ITERATION"
else
    echo "No active Sideshow Bob loop found"
fi
```
