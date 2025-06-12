#!/bin/bash

# CFHub iOS Quality Gates
# Strict validation following cloudflare-hub standards
# 
# 🤖 Generated with [Claude Code](https://claude.ai/code)
# Co-Authored-By: Claude <noreply@anthropic.com>

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
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

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
TOTAL_CHECKS=0

# Track check results
check_result() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if [ $1 -eq 0 ]; then
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        log_success "$2"
    else
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
        log_error "$2"
    fi
}

log_info "🚀 Starting CFHub iOS Quality Gates"
log_info "Following cloudflare-hub strict standards..."

# Check 1: Swift Package Build
log_info "📦 Building Swift Package..."
if swift build > /dev/null 2>&1; then
    check_result 0 "Swift package builds successfully"
else
    check_result 1 "Swift package build failed"
    log_error "Run 'swift build' for details"
fi

# Check 2: Swift Tests
log_info "🧪 Running Swift Tests..."
if swift test > /dev/null 2>&1; then
    check_result 0 "All Swift tests pass"
else
    check_result 1 "Swift tests failed"
    log_error "Run 'swift test' for details"
fi

# Check 3: Swift Concurrency Compliance
log_info "🔒 Checking Swift Concurrency Compliance..."
CONCURRENCY_VIOLATIONS=$(swift build 2>&1 | grep -c "warning.*concurrency" || true)
if [ "$CONCURRENCY_VIOLATIONS" -eq 0 ]; then
    check_result 0 "No Swift concurrency violations"
else
    check_result 1 "Found $CONCURRENCY_VIOLATIONS Swift concurrency violations"
    log_error "All code must be Swift 6 concurrency compliant"
fi

# Check 4: No Force Unwrapping (except in tests)
log_info "🚫 Checking for force unwrapping..."
FORCE_UNWRAPS=$(find Sources -name "*.swift" -exec grep -l "!" {} \; | wc -l | tr -d ' ')
if [ "$FORCE_UNWRAPS" -eq 0 ]; then
    check_result 0 "No force unwrapping found in Sources"
else
    check_result 1 "Found force unwrapping in $FORCE_UNWRAPS files"
    log_error "Force unwrapping is forbidden outside of Tests"
    find Sources -name "*.swift" -exec grep -Hn "!" {} \; | head -5
fi

# Check 5: Package.swift Dependencies
log_info "📋 Validating Package.swift dependencies..."
if grep -q "swift-testing" Package.swift; then
    check_result 0 "Swift Testing dependency found"
else
    check_result 1 "Swift Testing dependency missing"
fi

# Check 6: Proper Swift Language Features
log_info "🔮 Checking Swift language features..."
STRICT_CONCURRENCY_COUNT=$(grep -c "StrictConcurrency" Package.swift || true)
if [ "$STRICT_CONCURRENCY_COUNT" -gt 0 ]; then
    check_result 0 "StrictConcurrency enabled"
else
    check_result 1 "StrictConcurrency not enabled"
fi

# Check 7: Documentation Standards
log_info "📚 Checking documentation standards..."
if [ -f "README.md" ] && grep -q "🤖 Generated with" README.md; then
    check_result 0 "README.md has proper AI attribution"
else
    check_result 1 "README.md missing AI attribution"
fi

# Check 8: Integration Architecture
log_info "🏗️  Validating integration architecture..."
INTEGRATION_DIRS=$(find Sources/Integrations -maxdepth 1 -type d -name "CFHub*" | wc -l | tr -d ' ')
if [ "$INTEGRATION_DIRS" -gt 0 ]; then
    check_result 0 "Integration-first architecture detected ($INTEGRATION_DIRS integrations)"
else
    check_result 1 "No integrations found in Sources/Integrations/"
fi

# Check 9: Test Coverage Structure
log_info "🎯 Checking test structure..."
SOURCE_PACKAGES=$(find Sources -maxdepth 1 -type d -name "CFHub*" | wc -l | tr -d ' ')
TEST_PACKAGES=$(find Tests -name "*Tests" -type d | wc -l | tr -d ' ')

if [ "$SOURCE_PACKAGES" -eq "$TEST_PACKAGES" ]; then
    check_result 0 "Test packages match source packages ($TEST_PACKAGES tests)"
else
    check_result 1 "Test packages ($TEST_PACKAGES) don't match source packages ($SOURCE_PACKAGES)"
fi

# Check 10: SwiftLint (if available)
if command -v swiftlint >/dev/null 2>&1; then
    log_info "🧹 Running SwiftLint..."
    if swiftlint > /dev/null 2>&1; then
        check_result 0 "SwiftLint validation passed"
    else
        check_result 1 "SwiftLint validation failed"
    fi
else
    log_warning "SwiftLint not installed, skipping lint check"
fi

# Summary
echo ""
log_info "📊 Quality Gates Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "Total Checks: $TOTAL_CHECKS"
log_success "Passed: $CHECKS_PASSED"

if [ "$CHECKS_FAILED" -gt 0 ]; then
    log_error "Failed: $CHECKS_FAILED"
    echo ""
    log_error "🚫 Quality gates FAILED. Address the issues above before committing."
    exit 1
else
    echo ""
    log_success "🎉 All quality gates PASSED! Code meets CFHub standards."
    exit 0
fi