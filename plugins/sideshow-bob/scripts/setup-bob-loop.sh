#!/usr/bin/env bash
set -euo pipefail

# Sideshow Bob Loop Setup Script
# Creates a self-improving iterative development loop where each iteration
# learns from the previous and evolves the prompt accordingly.
# Like Bob's elaborate schemes, each attempt learns from previous failures.

print_help() {
    cat << 'EOF'
Sideshow Bob Loop - Self-Improving Iterative Development

"I'll be back. You can't keep the Democrats out of the White House forever!"

USAGE:
    /bob [PROMPT...] [OPTIONS]

OPTIONS:
    --max-iterations <n>         Maximum iterations before auto-stop (default: unlimited)
    --completion-promise '<text>' Phrase that signals task completion
    -h, --help                   Show this help message

DESCRIPTION:
    Unlike ralph-wiggum which feeds the same prompt repeatedly, Sideshow Bob
    evolves the prompt each iteration based on learnings from the previous attempt.

    Like Bob stepping on rakes, each failure teaches something new.

    At the end of each iteration, you should output a <learnings> block:

        <learnings>
        - Discovered that X approach doesn't work because Y
        - Need to handle edge case Z
        - The API requires authentication header
        - Tests are failing due to missing mock
        </learnings>

    These learnings are automatically incorporated into the next iteration's prompt,
    creating a spiral of continuous improvement rather than repetitive attempts.

COMPLETION:
    To complete the loop, output: <promise>YOUR_PHRASE</promise>

    The statement MUST be completely and unequivocally TRUE. You cannot
    output a false completion promise to escape the loop.

EXAMPLES:
    # Basic usage with completion promise
    /bob "Build a REST API with CRUD operations and tests" \
        --completion-promise "ALL_TESTS_PASS"

    # With iteration limit as safety net
    /bob "Implement OAuth2 authentication flow" \
        --max-iterations 30 \
        --completion-promise "AUTH_COMPLETE"

LEARNINGS FORMAT:
    At the end of each iteration, output learnings like this:

        <learnings>
        - [What you discovered]
        - [What didn't work and why]
        - [What needs to happen next]
        - [Edge cases or issues found]
        </learnings>

    These will be prepended to your next iteration's prompt as context.

EOF
}

# Parse arguments
PROMPT=""
MAX_ITERATIONS=""
COMPLETION_PROMISE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            print_help
            exit 0
            ;;
        --max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        --completion-promise)
            COMPLETION_PROMISE="$2"
            shift 2
            ;;
        *)
            if [[ -z "$PROMPT" ]]; then
                PROMPT="$1"
            else
                PROMPT="$PROMPT $1"
            fi
            shift
            ;;
    esac
done

# Validate arguments
if [[ -z "$PROMPT" ]]; then
    echo "Error: No prompt provided"
    echo ""
    print_help
    exit 1
fi

if [[ -n "$MAX_ITERATIONS" ]] && ! [[ "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
    echo "Error: --max-iterations must be a positive integer"
    exit 1
fi

# Create .claude directory if needed
mkdir -p .claude

# Create state file with YAML frontmatter
STATE_FILE=".claude/bob.local.md"
cat > "$STATE_FILE" << EOF
---
active: true
iteration: 1
max_iterations: ${MAX_ITERATIONS:-0}
completion_promise: "${COMPLETION_PROMISE}"
created_at: $(date -Iseconds)
---

# Sideshow Bob Loop State

## Original Prompt
${PROMPT}

## Accumulated Learnings
(No learnings yet - this is iteration 1)

## Current Evolved Prompt
${PROMPT}
EOF

echo "Sideshow Bob loop initialized!"
echo ""
echo "State file: $STATE_FILE"
echo "Iteration: 1"
[[ -n "$MAX_ITERATIONS" ]] && echo "Max iterations: $MAX_ITERATIONS"
[[ -n "$COMPLETION_PROMISE" ]] && echo "Completion promise: $COMPLETION_PROMISE"
echo ""
echo "The loop will now begin. At the end of each iteration, output:"
echo ""
echo "    <learnings>"
echo "    - What you learned"
echo "    - What needs to change"
echo "    </learnings>"
echo ""
echo "To complete, output: <promise>${COMPLETION_PROMISE:-DONE}</promise>"
