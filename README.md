# Sideshow Bob

> *"I'll be back. You can't keep the Democrats out of the White House forever!"*

A Claude Code plugin for self-improving iterative development loops. Unlike [ralph-wiggum](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum) which feeds the same prompt repeatedly, Sideshow Bob **evolves the prompt** each iteration based on learnings from previous attempts.

Like Bob's increasingly elaborate revenge schemes against Bart, each iteration learns from what went wrong before.

## The Core Idea

Traditional iterative loops (like ralph-wiggum) work like this:

```
Iteration 1: Prompt A → Work → Files change
Iteration 2: Prompt A → Work → Files change (Claude reads changed files)
Iteration 3: Prompt A → Work → Files change
```

Claude improves by reading its previous file changes, but the *prompt* stays static. Like Ralph repeating the same thing over and over.

**Sideshow Bob** works differently:

```
Iteration 1: Prompt A → Work → Learnings extracted
Iteration 2: Prompt A + Learnings → Work → More learnings
Iteration 3: Prompt A + All Learnings → Work → Even more learnings
```

The prompt itself evolves, incorporating explicit learnings from each iteration. Like Bob analyzing why his last scheme failed and adjusting his next one accordingly.

## Quick Start

```bash
# Install the plugin (copy to your plugins directory)
cp -r plugins/sideshow-bob ~/.claude/plugins/

# Start a loop
/bob "Build a REST API with authentication and tests" \
    --completion-promise "ALL_TESTS_PASS" \
    --max-iterations 25
```

## How It Works

### 1. Start the Loop

```bash
/bob "<your task>" --completion-promise "DONE"
```

### 2. Work and Learn

At the end of each iteration, output a learnings block:

```
<learnings>
- The OAuth library requires version 2.x for refresh tokens
- Rate limiting needs to be per-user, not global
- Found a race condition in the token refresh logic
- Tests need mocked Redis for the session tests
</learnings>
```

### 3. Evolved Prompts

On the next iteration, you receive a prompt that includes:
- All accumulated learnings from previous iterations
- The original task
- Instructions to continue where you left off

### 4. Completion

When truly done, output:

```
<promise>DONE</promise>
```

## Commands

### `/bob`

Start a self-improving loop.

```bash
/bob "<prompt>" [OPTIONS]

Options:
  --max-iterations <n>        Safety limit on iterations
  --completion-promise <text> Phrase that signals completion
```

### `/cancel-bob`

Cancel the active loop.

```bash
/cancel-bob
```

## Learnings Best Practices

### Be Specific

❌ Bad:
```
<learnings>
- Things didn't work
- Need to fix stuff
</learnings>
```

✅ Good:
```
<learnings>
- POST /api/users returns 500 because password hashing is async but not awaited
- The User model is missing the 'refreshToken' field added in migration 003
- Jest tests timeout because the DB connection pool isn't closed in afterAll
</learnings>
```

### Include Blockers and Solutions

```
<learnings>
- BLOCKED: Cannot test OAuth flow without client credentials
- SOLUTION NEEDED: Either mock the OAuth provider or get test credentials
- WORKAROUND FOUND: Using nock to intercept OAuth requests works for unit tests
</learnings>
```

### Track What's Left

```
<learnings>
- COMPLETED: User registration and login endpoints
- COMPLETED: JWT token generation and validation
- IN PROGRESS: Refresh token rotation (50% done)
- TODO: Password reset flow
- TODO: Email verification
</learnings>
```

## The Rake Principle

Remember the famous rake gag? Bob steps on a rake, gets hit in the face, steps on another rake, gets hit again... but eventually he learns where the rakes are.

That's this plugin. Each "rake to the face" (failed attempt) teaches something. The learnings accumulate. Eventually, you navigate the yard of rakes successfully.

```
Iteration 1: *steps on rake* "Ugh!" → Learning: there's a rake at position A
Iteration 2: *avoids A, steps on different rake* → Learning: also a rake at B
Iteration 3: *avoids A and B, steps on another* → Learning: rake at C too
...
Iteration N: *navigates perfectly* → "Die, Bart, die!"
```

## Comparison: Sideshow Bob vs Ralph Wiggum

| Aspect | Ralph Wiggum | Sideshow Bob |
|--------|--------------|--------------|
| Prompt | Static ("I'm learnding!") | Evolves each iteration |
| Learning mechanism | Implicit (reads files) | Explicit (learnings blocks) |
| Context growth | None (same prompt) | Accumulates learnings |
| Best for | Simple, well-defined tasks | Complex tasks requiring discovery |
| Memory | Files and git only | Files + explicit learnings |
| Personality | Repeats same thing | Schemes get more elaborate |

## When to Use Sideshow Bob

✅ **Ideal for:**
- Tasks where you'll discover requirements as you go
- Complex debugging where each attempt reveals more information
- Building features where edge cases emerge during implementation
- Greenfield projects with unclear specifications
- Any task where "what I learned" matters as much as "what I built"

❌ **Probably overkill for:**
- Simple, well-defined tasks with clear paths
- Tasks with no discovery component
- Quick fixes or one-shot operations

## State File

The loop state is stored in `.claude/bob.local.md`:

```yaml
---
active: true
iteration: 5
max_iterations: 20
completion_promise: "ALL_TESTS_PASS"
created_at: 2025-01-05T10:00:00-05:00
updated_at: 2025-01-05T11:30:00-05:00
---

# Sideshow Bob Loop State

## Original Prompt
Build a REST API with authentication...

## Accumulated Learnings
### Iteration 1 Learnings:
- Need to set up Express with TypeScript first
...

### Iteration 2 Learnings:
- JWT secret should come from environment
...

## Current Evolved Prompt
[The full evolved prompt for the next iteration]
```

## Credits

Inspired by [ralph-wiggum](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum) from the Claude Code team. Sideshow Bob takes the core loop concept and adds prompt evolution - because while Ralph just repeats things, Bob *learns from his failures*.

## License

MIT
