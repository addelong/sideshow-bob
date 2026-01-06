# Ouroboros

> *The serpent that eats its own tail, forever evolving*

A Claude Code plugin for self-improving iterative development loops. Unlike [ralph-wiggum](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum) which feeds the same prompt repeatedly, Ouroboros **evolves the prompt** each iteration based on learnings from previous attempts.

## The Core Idea

Traditional iterative loops (like ralph-wiggum) work like this:

```
Iteration 1: Prompt A → Work → Files change
Iteration 2: Prompt A → Work → Files change (Claude reads changed files)
Iteration 3: Prompt A → Work → Files change
```

Claude improves by reading its previous file changes, but the *prompt* stays static.

**Ouroboros** works differently:

```
Iteration 1: Prompt A → Work → Learnings extracted
Iteration 2: Prompt A + Learnings → Work → More learnings
Iteration 3: Prompt A + All Learnings → Work → Even more learnings
```

The prompt itself evolves, incorporating explicit learnings from each iteration. This is more like how humans iterate on problems - we don't just look at our previous work, we *remember what we learned*.

## Quick Start

```bash
# Install the plugin (copy to your plugins directory)
cp -r plugins/ouroboros ~/.claude/plugins/

# Start a loop
/ouroboros-loop "Build a REST API with authentication and tests" \
    --completion-promise "ALL_TESTS_PASS" \
    --max-iterations 25
```

## How It Works

### 1. Start the Loop

```bash
/ouroboros-loop "<your task>" --completion-promise "DONE"
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

### `/ouroboros-loop`

Start a self-improving loop.

```bash
/ouroboros-loop "<prompt>" [OPTIONS]

Options:
  --max-iterations <n>        Safety limit on iterations
  --completion-promise <text> Phrase that signals completion
```

### `/cancel-ouroboros`

Cancel the active loop.

```bash
/cancel-ouroboros
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

## Comparison: Ouroboros vs Ralph-Wiggum

| Aspect | Ralph-Wiggum | Ouroboros |
|--------|--------------|-----------|
| Prompt | Static | Evolves each iteration |
| Learning mechanism | Implicit (reads files) | Explicit (learnings blocks) |
| Context growth | None (same prompt) | Accumulates learnings |
| Best for | Simple, well-defined tasks | Complex tasks requiring discovery |
| Memory | Files and git only | Files + explicit learnings |

## When to Use Ouroboros

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

## Philosophy

The ouroboros - the ancient symbol of a serpent eating its own tail - represents cyclical renewal and the eternal cycle of creation. In this plugin, it represents a development loop that feeds on its own learnings, constantly refining and improving.

Key principles:

1. **Explicit > Implicit**: Writing down learnings forces clarity
2. **Accumulated wisdom**: Each iteration builds on all previous ones
3. **Spiral, not circle**: We return to the same task but at a higher level
4. **The prompt is alive**: It grows and adapts, not just the code

## State File

The loop state is stored in `.claude/ouroboros-loop.local.md`:

```yaml
---
active: true
iteration: 5
max_iterations: 20
completion_promise: "ALL_TESTS_PASS"
created_at: 2025-01-05T10:00:00-05:00
updated_at: 2025-01-05T11:30:00-05:00
---

# Ouroboros Loop State

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

Inspired by [ralph-wiggum](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum) from the Claude Code team. Ouroboros takes the core loop concept and adds prompt evolution.

## License

MIT
