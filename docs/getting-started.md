# Getting Started with CFHub iOS

> **Quick start guide** for mobile infrastructure management

## Prerequisites

### Development Environment

- **macOS 14.0+** (Sonoma or later)
- **Xcode 15.0+** with Swift 6.0 support
- **iOS 17.0+** device or simulator
- **Git** with command line tools
- **Homebrew** (recommended for dependencies)

### Optional Tools

- **SwiftLint** for code quality
- **Instruments** for performance profiling
- **TestFlight** for beta testing

## Quick Setup

### 1. Clone and Build

```bash
# Clone the repository
git clone https://github.com/your-org/cfhub-ios.git
cd cfhub-ios

# Build all packages
swift build

# Run tests to verify setup
swift test
```

### 2. Setup Development Environment

```bash
# Install SwiftLint (optional but recommended)
brew install swiftlint

# Setup AI-assisted development workflow
./scripts/setup-ai-workflow.sh

# Install quality gates
./scripts/install-git-hooks.sh
```

### 3. Open in Xcode

```bash
# Open Package.swift in Xcode
open Package.swift

# Or use the command line
xed .
```

## Project Structure

```
cfhub-ios/
├── Package.swift                 # Swift Package Manager configuration
├── README.md                     # Project overview
├── CLAUDE.md                     # AI development guidelines
│
├── Sources/
│   ├── CFHubApp/                # SwiftUI application layer
│   │   ├── CFHubApp.swift       # Main app entry point
│   │   ├── ViewModels/          # MVVM view models
│   │   └── Views/               # SwiftUI views
│   │
│   ├── CFHubCore/               # Core types & protocols
│   │   ├── Integration.swift    # Integration protocol
│   │   ├── Resource.swift       # Resource types
│   │   └── Action.swift         # Action types
│   │
│   ├── CFHubClient/             # HTTP client
│   │   └── HTTPClient.swift     # Network layer
│   │
│   └── Integrations/            # Service integrations
│       ├── CFHubCloudflare/     # Cloudflare integration
│       └── CFHubGitHub/         # GitHub integration
│
├── Tests/                       # Test suites
│   ├── CFHubAppTests/
│   ├── CFHubCoreTests/
│   └── Integrations/
│
├── scripts/                     # Development scripts
│   ├── validate-standards.sh    # Quality gates
│   ├── lint.sh                  # SwiftLint runner
│   └── setup-ai-workflow.sh     # AI development setup
│
└── docs/                        # Documentation
    ├── architecture.md           # Technical architecture
    └── getting-started.md        # This file
```

## Understanding the Architecture

### Integration-First Design

CFHub iOS follows an **integration-first architecture** where each cloud service is a self-contained module:

```swift
// Each integration implements the core protocol
public protocol Integration: Actor {
    static var identifier: String { get }
    func getActualState() async throws -> [Resource]
    func plan(desired: [Resource]) async throws -> [Action]
    func apply(actions: [Action]) async throws -> ApplyResult
}
```

### Security Model

The app uses a **secure proxy architecture**:

1. **Mobile app** authenticates to CFHub cloud service
2. **CFHub cloud** proxies commands to your local agent
3. **Local agent** holds actual API tokens
4. **Mobile app** never sees sensitive credentials

This ensures your API tokens never leave your development machine while enabling remote infrastructure management.

## Running the App

### 1. iOS Simulator

```bash
# Build and run in simulator
swift run

# Or use Xcode
# Product → Run (⌘R)
```

### 2. Physical Device

1. Connect your iOS device via USB
2. Select your device in Xcode's scheme selector
3. Click "Run" or press ⌘R
4. Trust the developer certificate on your device

### 3. TestFlight (Coming Soon)

Beta releases will be distributed via TestFlight for real device testing.

## Development Workflow

### 1. Quality Gates

Before committing any code, run quality gates:

```bash
# Run all quality validations
./scripts/validate-standards.sh

# Individual checks
swift build                    # Compilation check
swift test                     # Test suite
./scripts/lint.sh             # SwiftLint validation
```

### 2. AI-Assisted Development

This project uses AI assistance following strict guidelines:

```bash
# Use AI commit template
git ai-commit

# Check for missing AI attribution
git check-attribution

# Validate project standards
git validate
```

See [CLAUDE.md](../CLAUDE.md) for detailed AI development guidelines.

### 3. Testing Strategy

```bash
# Run all tests
swift test

# Run specific package tests
swift test --package CFHubCore

# Generate test coverage (in Xcode)
# Product → Test (⌘U) with code coverage enabled
```

## Common Development Tasks

### Adding a New Integration

1. **Create integration package**:
   ```bash
   mkdir -p Sources/Integrations/CFHubAWS
   mkdir -p Tests/Integrations/CFHubAWSTests
   ```

2. **Implement Integration protocol**:
   ```swift
   public actor AWSIntegration: Integration {
       public static let identifier = "aws"
       public static let displayName = "Amazon Web Services"
       
       public func getActualState() async throws -> [Resource] {
           // Implementation
       }
   }
   ```

3. **Register in IntegrationRegistry**:
   ```swift
   await registry.register(AWSIntegration.self) { configuration in
       try await AWSIntegration(configuration: configuration)
   }
   ```

4. **Add tests**:
   ```swift
   @Test("AWS integration fetches EC2 instances")
   func testAWSEC2() async throws {
       // Test implementation
   }
   ```

### Creating New Views

1. **Follow MVVM pattern**:
   ```swift
   @MainActor
   class MyViewModel: ObservableObject {
       @Published var data: [Resource] = []
   }
   
   struct MyView: View {
       @StateObject private var viewModel = MyViewModel()
   }
   ```

2. **Include AI attribution header**:
   ```swift
   //
   // MyView.swift
   // CFHub iOS
   //
   // 🤖 Generated with [Claude Code](https://claude.ai/code)
   // Co-Authored-By: Claude <noreply@anthropic.com>
   //
   ```

3. **Add accessibility support**:
   ```swift
   Text("Infrastructure Status")
       .accessibilityLabel("Infrastructure overall health status")
       .accessibilityValue(health.rawValue)
   ```

### Debugging Network Issues

1. **Enable network logging**:
   ```swift
   let client = HTTPClient(
       baseURL: URL(string: "https://api.example.com")!,
       defaultHeaders: ["User-Agent": "CFHub-iOS-Debug"]
   )
   ```

2. **Use Instruments for network profiling**:
   - Open Instruments (⌘I in Xcode)
   - Select "Network" template
   - Profile your app's network behavior

3. **Mock API responses for testing**:
   ```swift
   struct MockHTTPClient: HTTPClientProtocol {
       func get<T: Codable>(path: String, responseType: T.Type) async throws -> T {
           // Return mock data
       }
   }
   ```

## Troubleshooting

### Build Issues

**Swift Package Resolution Fails**:
```bash
# Clear package cache
rm -rf .build
swift package reset

# Resolve dependencies
swift package resolve
```

**Xcode Build Errors**:
```bash
# Clean build folder
# Product → Clean Build Folder (⇧⌘K)

# Reset package caches in Xcode
# File → Packages → Reset Package Caches
```

### Runtime Issues

**Integration Not Loading**:
```swift
// Verify integration is registered
let integrations = await IntegrationRegistry.shared.getRegisteredIntegrations()
print("Registered integrations: \(integrations.map(\.identifier))")
```

**Authentication Failures**:
```swift
// Check keychain storage
let authViewModel = AuthViewModel()
await authViewModel.restoreAuthentication()
print("Authentication status: \(authViewModel.isAuthenticated)")
```

### Testing Issues

**Tests Failing in CI**:
```bash
# Run tests with verbose output
swift test --verbose

# Run tests for specific package
swift test --package CFHubCore --verbose
```

**UI Tests Not Finding Elements**:
```swift
// Add accessibility identifiers
Text("Status")
    .accessibilityIdentifier("infrastructure-status")

// Use in tests
let statusText = app.staticTexts["infrastructure-status"]
XCTAssertTrue(statusText.exists)
```

## Next Steps

### 1. Explore the Codebase

- **Start with** `Sources/CFHubApp/CFHubApp.swift` - main entry point
- **Understand** `Sources/CFHubCore/Integration.swift` - core abstractions
- **Review** `Sources/Integrations/` - integration examples

### 2. Run Sample Workflows

- **Authentication**: Sign in with GitHub or Cloudflare
- **Dashboard**: View infrastructure status
- **Quick Actions**: Try deploying a feature branch

### 3. Contribute

- **Check issues** for contribution opportunities
- **Follow** AI development guidelines in CLAUDE.md
- **Submit PRs** with proper quality gates

### 4. Learn More

- **Read** [Architecture Documentation](architecture.md)
- **Review** AI development guidelines in [CLAUDE.md](../CLAUDE.md)
- **Explore** integration patterns in existing code

## Support

### Getting Help

- **GitHub Issues**: Report bugs and request features
- **Architecture Questions**: Review architecture.md
- **AI Development**: Check CLAUDE.md guidelines

### Contributing

1. Fork the repository
2. Create a feature branch
3. Follow quality gates and AI attribution standards
4. Submit a pull request with comprehensive tests

### Community

- **Code of Conduct**: Be respectful and collaborative
- **AI Attribution**: Always credit AI assistance
- **Quality Standards**: Maintain high code quality

---

**🤖 Generated with [Claude Code](https://claude.ai/code)**

**Co-Authored-By: Claude <noreply@anthropic.com>**