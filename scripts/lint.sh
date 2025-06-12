#!/bin/bash

# CFHub iOS Linting Script
# SwiftLint configuration and execution
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

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if SwiftLint is installed
if ! command -v swiftlint >/dev/null 2>&1; then
    log_warning "SwiftLint not found. Installing via Homebrew..."
    if command -v brew >/dev/null 2>&1; then
        brew install swiftlint
    else
        log_error "Homebrew not found. Please install SwiftLint manually:"
        log_error "https://github.com/realm/SwiftLint#installation"
        exit 1
    fi
fi

log_info "🧹 Running SwiftLint on CFHub iOS codebase..."

# Run SwiftLint with strict settings
SWIFTLINT_OUTPUT=$(swiftlint lint --strict --quiet 2>&1) || SWIFTLINT_EXIT_CODE=$?

if [ "${SWIFTLINT_EXIT_CODE:-0}" -eq 0 ]; then
    log_success "SwiftLint validation passed with no violations"
    exit 0
else
    log_error "SwiftLint found violations:"
    echo "$SWIFTLINT_OUTPUT"
    echo ""
    log_error "🚫 Fix all SwiftLint violations before committing"
    log_info "Run 'swiftlint --fix' to auto-fix some issues"
    exit 1
fi