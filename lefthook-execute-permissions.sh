# shellcheck shell=bash
# Lefthook-compatible execute permission checker.
# Detects files with unexpected execute permissions.
# Allowed patterns configurable via LEFTHOOK_EXECUTE_PERMISSIONS_ALLOWED env var.
# Usage: lefthook-execute-permissions file1 [file2 ...]
# NOTE: sourced by writeShellApplication - no shebang or set needed.

if [ $# -eq 0 ]; then
    exit 0
fi

allowed_pattern="${LEFTHOOK_EXECUTE_PERMISSIONS_ALLOWED:-^\./bin/|^\./scripts/|^\./libexec/|/Rakefile$}"
violations=()

for f in "$@"; do
    [ -f "$f" ] || continue
    if [ -x "$f" ] && ! echo "$f" | grep -qE "$allowed_pattern"; then
        violations+=("$f")
    fi
done

if [ ${#violations[@]} -gt 0 ]; then
    echo "Unexpected execute permissions:"
    for v in "${violations[@]}"; do
        echo "  - $v"
    done
    exit 1
fi
