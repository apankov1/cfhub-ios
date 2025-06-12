#!/bin/bash

# CFHub iOS Pre-commit Hook
# Enforces quality gates before commits
# 
# Install: cp scripts/pre-commit-hook.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
# 
# 🤖 Generated with [Claude Code](https://claude.ai/code)
# Co-Authored-By: Claude <noreply@anthropic.com>

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo ""
log_info "🔍 CFHub iOS Pre-commit Quality Gates"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    log_error "Not in CFHub iOS root directory. Pre-commit hook failed."
    exit 1
fi

# Run validation scripts
log_info "Running validation scripts..."

# 1. Validate standards
if ./scripts/validate-standards.sh; then
    log_success "Standards validation passed"
else
    log_error "Standards validation failed"
    echo ""
    log_error "🚫 Commit blocked. Fix the issues above before committing."
    exit 1
fi

# 2. Run linting (if available)
if [ -f "./scripts/lint.sh" ]; then
    if ./scripts/lint.sh; then
        log_success "Linting passed"
    else
        log_error "Linting failed"
        echo ""
        log_error "🚫 Commit blocked. Fix linting issues before committing."
        exit 1
    fi
fi

# 3. Check for AI attribution in modified files
MODIFIED_SWIFT_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.swift$' || true)

if [ -n "$MODIFIED_SWIFT_FILES" ]; then
    log_info "Checking AI attribution in modified Swift files..."
    
    MISSING_ATTRIBUTION=0
    for file in $MODIFIED_SWIFT_FILES; do
        if [ -f "$file" ] && ! grep -q "🤖 Generated with \[Claude Code\]" "$file"; then
            log_error "Missing AI attribution in: $file"
            MISSING_ATTRIBUTION=1
        fi
    done
    
    if [ $MISSING_ATTRIBUTION -eq 1 ]; then
        echo ""
        log_error "🚫 Commit blocked. Add AI attribution header to modified Swift files:"
        echo "// 🤖 Generated with [Claude Code](https://claude.ai/code)"
        echo "// Co-Authored-By: Claude <noreply@anthropic.com>"
        exit 1
    fi
fi

# 4. Check for manual version bumps (forbidden - must use Changesets)
if git diff --cached --name-only | grep -q "Package.swift"; then
    if git diff --cached Package.swift | grep -q "version.*="; then
        log_error "Manual version bumps are forbidden. Use changesets workflow."
        echo ""
        log_error "🚫 Commit blocked. Remove version changes from Package.swift"
        exit 1
    fi
fi

echo ""
log_success "🎉 All pre-commit checks passed! Proceeding with commit."
exit 0