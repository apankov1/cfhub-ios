# Contributing to CFHub iOS

Welcome to CFHub iOS! This project follows **Claude-first development practices** with 85-90% AI-generated code and rigorous human oversight.

## 🤖 AI-Assisted Development Model

### Core Philosophy
- **Human Strategic Oversight**: Architecture decisions, security review, requirements definition
- **AI Implementation**: Code generation, test creation, documentation, boilerplate
- **Collaborative Quality**: Both human and AI contributions are essential

### Attribution Requirements
All AI-assisted contributions must include:

```swift
//
// FileName.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//
```

## 🏗️ Architecture Principles

### Integration-First Design
Each service integration is completely self-contained:

```
Sources/Integrations/CFHub{Service}/
├── {Service}Integration.swift     # Implements Integration protocol
├── {Service}Types.swift          # Service-specific types
├── {Service}Client.swift         # HTTP client wrapper
└── {Service}Errors.swift         # Service-specific errors
```

### Security-First Model
- **No client-side credentials**: All authentication via secure proxy
- **Swift 6 concurrency**: Safe concurrent operations with actors
- **Input validation**: Comprehensive validation at all boundaries

## 🚀 Getting Started

### Prerequisites
- macOS 12.0+
- Xcode 15.0+
- Swift 6.0+
- SwiftLint (install via `brew install swiftlint`)

### Setup Development Environment
```bash
git clone https://github.com/username/cfhub-ios.git
cd cfhub-ios
./scripts/setup-ai-workflow.sh
```

### Development Workflow
1. **Create Feature Branch**: `git checkout -b feature/your-feature`
2. **Setup AI Context**: Review `CLAUDE.md` for development guidelines
3. **Implement Changes**: Follow established patterns and AI attribution
4. **Run Quality Gates**: `./scripts/validate-standards.sh`
5. **Commit with Attribution**: `git ai-commit`
6. **Create Pull Request**: Use our PR template

## 📝 Contribution Types

### 🐛 Bug Fixes
1. Create issue using bug report template
2. Implement fix following existing patterns
3. Add/update tests to prevent regression
4. Ensure AI attribution is included

### ✨ New Features
1. Create feature request issue
2. Discuss architectural approach
3. Implement following integration-first patterns
4. Comprehensive testing and documentation

### 🔌 New Integrations
1. Use new integration issue template
2. Follow self-contained integration pattern
3. Implement all required protocol methods
4. Add comprehensive test coverage

### 📖 Documentation
1. Update relevant documentation files
2. Include AI attribution in generated docs
3. Follow established documentation patterns

## 🧪 Testing Standards

### Test Coverage Requirements
- **Minimum**: 95% test coverage
- **Integration Tests**: Required for all integrations
- **Error Handling**: Test all error paths
- **Concurrency**: Test actor isolation and Swift 6 compliance

### Test Structure
```
Tests/
├── CFHubCoreTests/              # Core functionality tests
├── CFHubClientTests/            # HTTP client tests
├── CFHubAppTests/               # UI/Application tests
└── Integrations/
    ├── CFHub{Service}Tests/     # Integration-specific tests
    └── IntegrationTests/        # Cross-integration tests
```

### Running Tests
```bash
# All tests
swift test

# Specific package
swift test --package CFHubCore

# With coverage
swift test --enable-code-coverage
```

## 🔍 Quality Gates

### Automated Validation
All contributions must pass:

```bash
# Run all quality gates
./scripts/validate-standards.sh

# Individual checks
swift build                      # Build check
swift test                       # Test suite
./scripts/lint.sh               # SwiftLint
git check-attribution           # AI attribution check
```

### Manual Review Checklist
- [ ] Architecture aligns with integration-first principles
- [ ] Security model maintained (no client credentials)
- [ ] AI attribution properly included
- [ ] Tests comprehensive and passing
- [ ] Documentation updated
- [ ] Swift 6 concurrency compliance

## 🤝 Code Review Process

### For Contributors
1. Ensure all quality gates pass
2. Fill out PR template completely
3. Include test coverage information
4. Address reviewer feedback promptly

### For Reviewers
1. Verify architectural alignment
2. Check AI attribution compliance
3. Validate security considerations
4. Ensure test coverage is adequate
5. Review for Swift 6 compliance

## 🔐 Security Guidelines

### Credential Management
- **Never** commit credentials to the repository
- Use proxy authentication pattern for all integrations
- Store sensitive configuration in environment variables

### Input Validation
- Validate all external inputs
- Sanitize user-provided data
- Implement proper error handling

### Dependencies
- Keep dependencies minimal and well-maintained
- Regular security audits of dependencies
- Swift Package Manager only for dependencies

## 📊 AI Development Metrics

We track AI contribution metrics:
- **Code Attribution**: Percentage of AI-generated code
- **Quality Compliance**: AI attribution coverage
- **Architectural Alignment**: Integration-first pattern compliance

## 🏷️ Issue and PR Labels

### Priority Labels
- `priority:critical` - Security issues, broken builds
- `priority:high` - Important features, major bugs
- `priority:medium` - Standard features, minor bugs
- `priority:low` - Nice-to-have features

### Type Labels
- `bug` - Something isn't working
- `enhancement` - New feature or improvement
- `integration` - New service integration
- `documentation` - Improvements to documentation
- `ai-assisted` - Indicates AI-generated content

### Status Labels
- `needs-triage` - Awaiting initial review
- `ready-for-review` - Ready for code review
- `needs-changes` - Changes requested
- `approved` - Approved for merge

## 🎯 Project Roadmap

### Current Focus
- Cloudflare and GitHub integrations
- Swift 6 concurrency migration
- Enhanced security model

### Future Integrations
- AWS services
- Vercel/Netlify
- Docker/Kubernetes

## 💬 Community Guidelines

### Communication
- Be respectful and constructive
- Provide clear, actionable feedback
- Acknowledge AI-assisted contributions
- Help maintain our quality standards

### Getting Help
- Check existing issues and documentation
- Create detailed issue reports
- Include environment details and reproduction steps
- Tag issues appropriately

## 📚 Resources

### Project Documentation
- [Architecture Overview](docs/architecture.md)
- [Getting Started Guide](docs/getting-started.md)
- [Security Model](docs/security.md)
- [AI Development Guidelines](CLAUDE.md)

### Swift Resources
- [Swift 6 Migration Guide](https://swift.org/migration/)
- [Swift Package Manager](https://swift.org/package-manager/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

### Git Workflow
```bash
# Helpful aliases (set up by setup-ai-workflow.sh)
git ai-commit              # Commit with AI template
git check-attribution      # Find files missing AI attribution
git validate              # Run quality gates
git lint                  # Run SwiftLint
```

## 🏆 Recognition

We recognize both human and AI contributions:
- **Human Contributors**: Strategic decisions, architecture, review
- **AI Contributions**: Implementation, testing, documentation
- **Collaborative Success**: Acknowledgment of AI-human partnership

---

**🤖 Generated with [Claude Code](https://claude.ai/code)**

**Co-Authored-By: Claude <noreply@anthropic.com>**

Thank you for contributing to CFHub iOS and helping advance AI-assisted development practices!