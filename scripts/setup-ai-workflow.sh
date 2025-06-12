#!/bin/bash

# CFHub iOS AI-Assisted Development Workflow Setup
# Following cloudflare-hub AI development standards
# 
# 🤖 Generated with [Claude Code](https://claude.ai/code)
# Co-Authored-By: Claude <noreply@anthropic.com>

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

echo ""
log_info "🤖 Setting up CFHub iOS AI-Assisted Development Workflow"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    echo "❌ Not in CFHub iOS root directory. Setup failed."
    exit 1
fi

# 1. Setup git commit template
log_info "Setting up git commit template..."
if git config --local commit.template .gitmessage; then
    log_success "Git commit template configured"
else
    log_warning "Failed to set git commit template"
fi

# 2. Install git hooks
log_info "Installing git hooks..."
if ./scripts/install-git-hooks.sh > /dev/null 2>&1; then
    log_success "Git hooks installed"
else
    log_warning "Failed to install git hooks"
fi

# 3. Setup AI attribution validation
log_info "Setting up AI attribution validation..."

# Create a git alias for checking AI attribution
git config --local alias.check-attribution '!find Sources -name "*.swift" ! -exec grep -l "🤖 Generated with" {} \; | head -10'

log_success "AI attribution check alias created (git check-attribution)"

# 4. Create AI development helper aliases
log_info "Creating AI development aliases..."

# Add helpful git aliases
git config --local alias.ai-commit 'commit --template=.gitmessage'
git config --local alias.validate '!./scripts/validate-standards.sh'
git config --local alias.lint '!./scripts/lint.sh'

log_success "AI development aliases created"

# 5. Setup VS Code settings (if .vscode exists)
if [ -d ".vscode" ]; then
    log_info "Updating VS Code settings for AI development..."
    
    # Create or update settings.json
    cat > .vscode/settings.json << 'EOF'
{
  "swift.autoGenerateCommentsTemplate": true,
  "swift.format.indentSwitchCase": true,
  "swift.lint.runOnSave": true,
  "files.insertFinalNewline": true,
  "files.trimTrailingWhitespace": true,
  "editor.formatOnSave": true,
  "editor.rulers": [120],
  "git.inputValidation": "always",
  "git.inputValidationLength": 72,
  "git.inputValidationSubjectLength": 50,
  "files.associations": {
    "*.swift": "swift",
    ".gitmessage": "git-commit",
    "CLAUDE.md": "markdown"
  },
  "search.exclude": {
    ".build/**": true,
    "DerivedData/**": true
  }
}
EOF
    
    log_success "VS Code settings updated for AI development"
else
    log_warning "No .vscode directory found, skipping VS Code setup"
fi

# 6. Validate current project structure
log_info "Validating project structure..."

VALIDATION_ERRORS=0

# Check for required files
REQUIRED_FILES=("Package.swift" "README.md" "CLAUDE.md" ".gitmessage" ".swiftlint.yml")
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Missing required file: $file"
        VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
    fi
done

# Check for AI attribution in existing Swift files
SWIFT_FILES_WITHOUT_ATTRIBUTION=$(find Sources -name "*.swift" ! -exec grep -l "🤖 Generated with" {} \; 2>/dev/null | wc -l | tr -d ' ')
if [ "$SWIFT_FILES_WITHOUT_ATTRIBUTION" -gt 0 ]; then
    log_warning "$SWIFT_FILES_WITHOUT_ATTRIBUTION Swift files missing AI attribution"
    echo "   Run 'git check-attribution' to see which files need attribution"
fi

# Check for integration architecture
INTEGRATION_DIRS=$(find Sources/Integrations -maxdepth 1 -type d -name "CFHub*" 2>/dev/null | wc -l | tr -d ' ')
if [ "$INTEGRATION_DIRS" -gt 0 ]; then
    log_success "Integration-first architecture detected ($INTEGRATION_DIRS integrations)"
else
    log_warning "No integrations found - consider creating initial integrations"
fi

if [ $VALIDATION_ERRORS -eq 0 ]; then
    log_success "Project structure validation passed"
else
    log_warning "Project structure validation found $VALIDATION_ERRORS issues"
fi

# 7. Create development cheat sheet
log_info "Creating AI development cheat sheet..."

cat > AI_CHEATSHEET.md << 'EOF'
# CFHub iOS AI Development Cheat Sheet

## Quick Commands
```bash
# Quality gates
./scripts/validate-standards.sh

# Linting
./scripts/lint.sh

# Git helpers
git ai-commit                    # Use AI commit template
git check-attribution           # Find files missing AI attribution
git validate                    # Run quality gates
git lint                        # Run linting

# Build and test
swift build                     # Build all packages
swift test                      # Run all tests
swift test --package CFHubCore  # Test specific package
```

## AI Attribution Template
```swift
//
// FileName.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//
```

## Commit Message Template
```
feat(core): implement integration registry pattern

Extended description of the changes made.

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Integration Development Pattern
1. Create `Sources/Integrations/CFHub{Service}/`
2. Implement `Integration` protocol
3. Add service-specific types (distributed types pattern)
4. Register in `IntegrationRegistry`
5. Add comprehensive tests

## Quality Standards Checklist
- [ ] Swift 6 concurrency compliance
- [ ] No force unwrapping in Sources
- [ ] AI attribution in all files
- [ ] Comprehensive error handling
- [ ] Integration-first architecture
- [ ] 95%+ test coverage
- [ ] SwiftLint validation passes
EOF

log_success "AI development cheat sheet created (AI_CHEATSHEET.md)"

# 8. Final summary
echo ""
log_success "🎉 CFHub iOS AI-Assisted Development Workflow Setup Complete!"
echo ""
echo "Next steps:"
echo "1. Review CLAUDE.md for detailed AI development guidelines"
echo "2. Use 'git ai-commit' for your next commit with proper attribution"
echo "3. Run 'git validate' before committing to ensure quality gates pass"
echo "4. Check AI_CHEATSHEET.md for quick reference commands"
echo ""
log_info "Your project now follows cloudflare-hub AI development standards!"
echo ""

# Show useful aliases
echo "Available git aliases:"
echo "  git ai-commit        - Commit with AI attribution template"
echo "  git check-attribution - Find files missing AI attribution"
echo "  git validate         - Run quality gates"
echo "  git lint             - Run SwiftLint"
echo ""

exit 0