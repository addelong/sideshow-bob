---
description: Start a self-improving Sideshow Bob loop
allowed_tools:
  - Bash(test:*)
  - Bash(mkdir:*)
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-bob-loop.sh:*)
---

# Sideshow Bob Loop Command

Start a self-improving iterative development loop. Unlike ralph-wiggum which repeats the same prompt (like Ralph repeating things), Sideshow Bob evolves the prompt each iteration based on learnings from previous attempts - like Bob's increasingly elaborate revenge schemes.

## Usage

```
/bob "<prompt>" [--max-iterations <n>] [--completion-promise "<text>"]
```

## How It Works

1. **Iteration 1**: You receive the original prompt and work on the task
2. **End of iteration**: You output a `<learnings>` block with what you discovered
3. **Iteration 2+**: You receive an evolved prompt that includes:
   - All accumulated learnings from previous iterations
   - The original task
   - Instructions to continue where you left off

This creates a **spiral of improvement** rather than repetitive attempts at the same problem.

## Learnings Format

At the end of each iteration, output:

```
<learnings>
- Discovered that the API requires OAuth2 authentication
- The rate limit is 100 requests/minute, need to add throttling
- Tests are failing because mock data is stale
- Need to handle the edge case where user has no profile
</learnings>
```

## Completion

When the task is COMPLETELY and UNEQUIVOCALLY done, output:

```
<promise>YOUR_COMPLETION_PHRASE</promise>
```

**WARNING**: The completion promise must be TRUE. You cannot output a false promise to escape the loop.

## Examples

```bash
# Build a feature with iterative refinement
/bob "Build a user authentication system with JWT tokens, refresh tokens, and comprehensive tests" \
    --completion-promise "AUTH_COMPLETE" \
    --max-iterations 20

# Debug a complex issue
/bob "Fix the race condition in the payment processing pipeline. All tests must pass." \
    --completion-promise "BUG_FIXED" \
    --max-iterations 15
```

## Execution

Run the setup script:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-bob-loop.sh" $ARGUMENTS
```

Then begin working on the task. The stop hook will intercept exit attempts and feed back an evolved prompt incorporating your learnings.
