# CFHub iOS - AI Development Guidelines

> **AI-Assisted Development Standards** following cloudflare-hub patterns

## AI Assistance Overview

This project follows the cloudflare-hub model of **85-90% AI-generated code** with rigorous human oversight. All AI-assisted development must be properly attributed and meet strict quality standards.

## Human vs AI Responsibilities

### 👨‍💻 Human Responsibilities
- **Strategic Architecture**: Overall system design and architectural decisions
- **Security Review**: Authentication flows, keychain usage, data protection
- **Requirements Definition**: Feature specifications and acceptance criteria
- **Code Review**: Quality gates, architectural compliance, security validation
- **Integration Testing**: End-to-end workflows and integration points
- **Release Management**: Version control, deployment strategies, App Store submission

### 🤖 AI Responsibilities
- **Implementation**: Swift code generation following established patterns
- **Test Generation**: Unit tests, integration tests, UI tests
- **Documentation**: Code comments, README updates, API documentation
- **Boilerplate Code**: Repetitive patterns, protocol conformances, view hierarchies
- **Code Refactoring**: Performance improvements, pattern consistency
- **Error Handling**: Comprehensive error cases and user feedback

## Attribution Requirements

### Commit Messages
All AI-assisted commits MUST include attribution:

```
feat(core): implement CloudflareIntegration actor

Add complete Cloudflare API integration following the
integration-first architecture pattern from cloudflare-hub.

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### File Headers
All Swift files MUST include the header:

```swift
//
// FileName.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//
```

### Documentation
All AI-generated documentation must include attribution footer:

```markdown
---

**🤖 Generated with [Claude Code](https://claude.ai/code)**

**Co-Authored-By: Claude <noreply@anthropic.com>**
```

## Quality Standards

### Code Quality
- **Swift 6 Concurrency**: All code must be `StrictConcurrency` compliant
- **No Force Unwrapping**: Forbidden in Sources (allowed in Tests only)
- **Comprehensive Error Handling**: Use typed errors from `CFHubCore/Errors.swift`
- **Protocol-First Design**: Follow integration patterns from `CFHubCore/Integration.swift`
- **Memory Safety**: Use `@MainActor` and `Sendable` appropriately

### Testing Requirements
- **95%+ Code Coverage**: All new code must have comprehensive tests
- **Integration Tests**: Test actual API integrations with mocks
- **UI Tests**: SwiftUI view testing with proper accessibility
- **Performance Tests**: Network timeout and retry behavior

### Architecture Compliance
- **Integration-First**: Each service integration must be self-contained
- **Distributed Types**: No central types package - each domain owns its types
- **Plugin Discovery**: Use `IntegrationRegistry` for dynamic integration loading
- **Security-First**: Follow keychain patterns from `AuthViewModel`

## Development Workflow

### Setup Git Configuration
```bash
# Setup commit message template
git config commit.template .gitmessage

# Install quality gates
./scripts/install-git-hooks.sh

# Setup commit attribution
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### Pre-Commit Checklist
1. **Quality Gates**: Run `./scripts/validate-standards.sh`
2. **Linting**: Run `./scripts/lint.sh` 
3. **Tests**: Ensure `swift test` passes
4. **Attribution**: Verify AI attribution in modified files
5. **Architecture**: Confirm integration patterns are followed

### AI-Assisted Development Process

#### 1. Architecture Phase (Human-Led)
- Define feature requirements and acceptance criteria
- Design integration points and data flow
- Specify security requirements and authentication patterns
- Create architectural decision records

#### 2. Implementation Phase (AI-Led)
- Generate Swift code following established patterns
- Implement comprehensive error handling
- Create unit tests with high coverage
- Add inline documentation and comments

#### 3. Review Phase (Human-Led)
- Validate architectural compliance
- Security review for authentication and data handling
- Performance testing and optimization
- Integration testing with real API endpoints

#### 4. Integration Phase (Collaborative)
- End-to-end testing scenarios
- App Store compliance verification
- Accessibility testing and optimization
- Final quality gate validation

## AI Prompt Guidelines

### Effective Prompts
```
Generate a SwiftUI view for displaying deployment status that:
- Follows the existing DashboardView patterns
- Uses CFHubCore types for Resource and ResourceStatus
- Implements proper error handling with DashboardError
- Includes AI attribution header
- Has comprehensive accessibility support
```

### Architecture Context
Always provide architectural context:
```
This CFHub iOS project follows cloudflare-hub patterns:
- Integration-first architecture with self-contained modules
- Distributed types (no central types package)
- Security-first with keychain storage
- Swift 6 concurrency with StrictConcurrency enabled
```

## Quality Gates

### Automated Validation
- **Build**: `swift build` must succeed
- **Tests**: `swift test` must pass 100%
- **Concurrency**: No concurrency warnings allowed
- **Force Unwrapping**: Forbidden in Sources
- **SwiftLint**: All rules must pass

### Manual Review Points
- **Security**: Keychain usage, authentication flows
- **Architecture**: Integration patterns, type distribution
- **UX**: SwiftUI best practices, accessibility
- **Performance**: Memory usage, network efficiency

## Commands Reference

### Development Commands
```bash
# Build all packages
swift build

# Run all tests
swift test

# Run quality gates
./scripts/validate-standards.sh

# Run linting
./scripts/lint.sh

# Install git hooks
./scripts/install-git-hooks.sh
```

### AI Development Commands
```bash
# Setup AI attribution template
git config commit.template .gitmessage

# Validate AI attribution in files
grep -r "🤖 Generated with" Sources/

# Check for missing attribution
find Sources -name "*.swift" ! -exec grep -l "🤖 Generated with" {} \;
```

## Integration Patterns

### Adding New Integrations
1. Create `Sources/Integrations/CFHub{Service}/`
2. Implement `Integration` protocol from `CFHubCore`
3. Add service-specific types (no shared types)
4. Register in `IntegrationRegistry`
5. Add comprehensive tests

### Example Integration Structure
```
Sources/Integrations/CFHubAWS/
├── AWSIntegration.swift          # Main integration actor
├── AWSTypes.swift                # Service-specific types
├── AWSCloudFormation.swift       # Sub-service implementations
├── AWSLambda.swift
└── AWSEC2.swift

Tests/Integrations/CFHubAWSTests/
├── AWSIntegrationTests.swift
├── AWSCloudFormationTests.swift
└── MockAWSResponses.swift
```

## Security Guidelines

### Authentication
- Use `AuthViewModel` patterns for secure credential storage
- Never store actual provider tokens on device
- Implement CFHub cloud proxy authentication
- Use keychain for credential encryption

### API Security
- Validate all API responses with typed errors
- Implement proper timeout and retry policies
- Use certificate pinning for production
- Log security events without exposing sensitive data

## Performance Standards

### Network Performance
- 30-second default timeout for API calls
- Exponential backoff retry policies
- Background app refresh for real-time updates
- Offline-first architecture with intelligent caching

### UI Performance
- 60 FPS for all animations and scrolling
- Lazy loading for large data sets
- Progressive image loading with placeholders
- Memory-efficient view lifecycle management

---

**🤖 Generated with [Claude Code](https://claude.ai/code)**

**Co-Authored-By: Claude <noreply@anthropic.com>**