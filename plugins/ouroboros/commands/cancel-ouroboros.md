---
description: Cancel active Ouroboros loop
hidden_from_slash_command: true
allowed_tools:
  - Bash(test:*)
  - Bash(rm:*)
  - Read
---

# Cancel Ouroboros Loop

Cancel the currently active Ouroboros loop.

## Steps

1. Check if `.claude/ouroboros-loop.local.md` exists
2. If it doesn't exist, inform the user there's no active loop
3. If it exists:
   - Read the file to get the current iteration number
   - Delete the file
   - Confirm cancellation with the iteration count

## Execution

```bash
if [[ -f ".claude/ouroboros-loop.local.md" ]]; then
    # Read current iteration for reporting
    ITERATION=$(grep "^iteration:" .claude/ouroboros-loop.local.md | sed 's/iteration: *//')
    rm .claude/ouroboros-loop.local.md
    echo "Ouroboros loop cancelled at iteration $ITERATION"
else
    echo "No active Ouroboros loop found"
fi
```
