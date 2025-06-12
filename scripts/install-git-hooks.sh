#!/bin/bash

# CFHub iOS Git Hooks Installation
# Sets up pre-commit hooks for quality enforcement
# 
# 🤖 Generated with [Claude Code](https://claude.ai/code)
# Co-Authored-By: Claude <noreply@anthropic.com>

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not in a git repository. Run 'git init' first."
    exit 1
fi

log_info "Installing CFHub iOS git hooks..."

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Install pre-commit hook
cp scripts/pre-commit-hook.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

log_success "Pre-commit hook installed"

# Install commit-msg hook for AI attribution enforcement
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash

# CFHub iOS Commit Message Hook
# Ensures proper AI attribution in commit messages

COMMIT_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_FILE")

# Check if this is an AI-generated commit
if echo "$COMMIT_MSG" | grep -q "🤖 Generated with"; then
    # Valid AI attribution found
    exit 0
fi

# For manual commits, suggest adding AI attribution for AI-assisted work
if echo "$COMMIT_MSG" | grep -qE "(implement|add|create|fix|update)" && ! echo "$COMMIT_MSG" | grep -q "manual"; then
    echo ""
    echo "💡 If this work was AI-assisted, consider adding:"
    echo "🤖 Generated with [Claude Code](https://claude.ai/code)"
    echo ""
    echo "Co-Authored-By: Claude <noreply@anthropic.com>"
    echo ""
fi

exit 0
EOF

chmod +x .git/hooks/commit-msg

log_success "Commit message hook installed"

echo ""
log_success "🎉 CFHub iOS git hooks installed successfully!"
log_info "Your commits will now be validated against CFHub quality standards."