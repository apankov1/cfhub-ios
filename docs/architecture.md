# CFHub iOS Architecture

> **Integration-First Mobile Infrastructure Management** following cloudflare-hub patterns

## Overview

CFHub iOS transforms infrastructure management from a desktop-bound CLI tool into a mobile-first experience. The architecture follows the proven patterns from cloudflare-hub, adapted for iOS development with Swift 6 concurrency and SwiftUI.

## Core Architectural Principles

### 1. Integration-First Architecture

Following cloudflare-hub's plugin system, each service integration is completely self-contained:

```
Sources/
├── CFHubCore/                   # Core types & plugin system
├── CFHubClient/                 # Platform-agnostic HTTP client
└── Integrations/
    ├── CFHubCloudflare/         # Complete Cloudflare integration
    └── CFHubGitHub/             # Complete GitHub integration
```

**Key Benefits:**
- **Independent Development**: Each integration can be developed separately
- **Clean Boundaries**: No shared state or coupling between integrations
- **Extensibility**: New integrations follow the same pattern
- **Testing Isolation**: Each integration has its own test suite

### 2. Distributed Types Pattern

Unlike monolithic architectures with central type definitions, CFHub iOS uses **distributed types** where each integration owns its domain-specific types:

```swift
// ❌ Bad: Central types package
Sources/Types/CloudflareTypes.swift
Sources/Types/GitHubTypes.swift

// ✅ Good: Distributed types
Sources/Integrations/CFHubCloudflare/CloudflareTypes.swift
Sources/Integrations/CFHubGitHub/GitHubTypes.swift
```

This prevents:
- Cross-integration dependencies
- Breaking changes rippling across integrations
- Merge conflicts in shared type files

### 3. Security-First Design

The mobile app **never stores actual API tokens**. Instead, it uses a secure proxy model:

```
iOS App ←→ CFHub Cloud ←→ Local Agent ←→ Cloud APIs
   ↓           ↓              ↓           ↓
Mobile     Authentication  Plugin      Actual
  UI       & Proxying      Engine    Resources
```

**Security Benefits:**
- API tokens never leave the developer's machine
- Mobile app works from anywhere with internet
- Consistent plugin system across CLI and mobile
- Real-time updates without exposing credentials

## Package Architecture

### CFHubCore

The core package provides fundamental abstractions:

```swift
public protocol Integration: Actor {
    static var identifier: String { get }
    func getActualState() async throws -> [Resource]
    func plan(desired: [Resource]) async throws -> [Action]
    func apply(actions: [Action]) async throws -> ApplyResult
}
```

**Responsibilities:**
- Define integration contracts
- Provide common types (Resource, Action, Error)
- Integration registry and discovery
- State management patterns

### CFHubClient

Platform-agnostic HTTP client with advanced features:

```swift
public actor HTTPClient: Sendable {
    func get<T: Codable>(path: String, responseType: T.Type) async throws -> HTTPResponse<T>
    func post<T: Codable, U: Codable>(path: String, body: T, responseType: U.Type) async throws -> HTTPResponse<U>
}
```

**Features:**
- Automatic retry with exponential backoff
- Request/response logging and metrics
- Certificate pinning for production
- Concurrent request handling

### Integration Packages

Each integration is a complete, self-contained module:

```swift
public actor CloudflareIntegration: Integration {
    public static let identifier = "cloudflare"
    public static let requiredPermissions: [Permission] = [...]
    
    public func getActualState() async throws -> [Resource] {
        // Fetch from Cloudflare API
    }
}
```

**Pattern Benefits:**
- Complete encapsulation of service logic
- Independent versioning and releases
- Clear permission boundaries
- Isolated testing and mocking

## SwiftUI Application Architecture

### MVVM + Combine Pattern

The app layer uses MVVM with Combine for reactive data flow:

```swift
@MainActor
class DashboardViewModel: ObservableObject {
    @Published var infrastructureStatus: InfrastructureStatus?
    @Published var isLoading = false
    @Published var error: DashboardError?
    
    func refresh() async {
        // Coordinate with IntegrationRegistry
    }
}
```

### View Hierarchy

```
CFHubApp
├── ContentView (Auth Routing)
├── MainTabView
│   ├── DashboardView
│   ├── DeploymentsView
│   ├── EnvironmentsView
│   └── SettingsView
└── AuthenticationView
```

## Cloud-Native Patterns

### 1. Ephemeral Environments

Following cloudflare-hub's ephemeral environment pattern:

```swift
// Quick action to deploy current branch
func deployCurrentBranch() async {
    let branchName = getCurrentGitBranch()
    let environment = "feature-\(branchName)"
    
    try await createEphemeralEnvironment(
        name: environment,
        source: .git(branch: branchName)
    )
}
```

### 2. Real-Time Infrastructure Monitoring

```swift
@MainActor
class DashboardViewModel: ObservableObject {
    private var refreshTimer: Timer?
    
    func startRealTimeUpdates() async {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            Task { await self.refresh() }
        }
    }
}
```

### 3. Emergency Response Capabilities

```swift
func triggerEmergencyRollback() async {
    // Immediate rollback without confirmation
    let lastStableDeployment = try await getLastStableDeployment()
    try await rollbackToDeployment(lastStableDeployment.id)
    
    // Send emergency notification
    await sendEmergencyNotification("Rollback initiated from mobile")
}
```

## State Management

### Global Application State

```swift
@MainActor
class AppState: ObservableObject {
    @Published var isInitialized = false
    @Published var integrationStatus: [String: HealthStatus] = [:]
    
    private let integrationRegistry = IntegrationRegistry.shared
}
```

### Integration Registry

Central registry for dynamic integration discovery:

```swift
public actor IntegrationRegistry: Sendable {
    private var activeIntegrations: [String: any Integration] = [:]
    
    public func activateIntegration(
        identifier: String,
        configuration: IntegrationConfiguration
    ) async throws -> any Integration
}
```

## Error Handling Strategy

### Typed Errors

All errors are strongly typed and contextual:

```swift
public enum IntegrationError: Error, Sendable, Codable {
    case authenticationFailed(reason: String)
    case resourceNotFound(id: String, type: ResourceType)
    case actionFailed(action: Action, underlyingError: String)
    case networkUnavailable
    
    public var isRetryable: Bool { /* ... */ }
    public var severity: ErrorSeverity { /* ... */ }
}
```

### Error Recovery

```swift
private func handleError(_ error: Error) async {
    switch error {
    case let integrationError as IntegrationError where integrationError.isRetryable:
        // Automatic retry with backoff
        try await Task.sleep(nanoseconds: calculateRetryDelay())
        await retry()
    case let authError as AuthError:
        // Force re-authentication
        await authViewModel.signOut()
    default:
        // User-visible error
        self.error = error
    }
}
```

## Concurrency Model

### Swift 6 Strict Concurrency

All code uses Swift 6 strict concurrency:

```swift
public actor CloudflareIntegration: Integration {
    private let client: HTTPClient
    
    public func getActualState() async throws -> [Resource] {
        // All async work is properly isolated
        let pages = try await getCloudflarePages()
        let workers = try await getCloudflareWorkers()
        return pages + workers
    }
}
```

### MainActor Usage

UI components are properly isolated to MainActor:

```swift
@MainActor
class DashboardViewModel: ObservableObject {
    @Published var infrastructureStatus: InfrastructureStatus?
    
    func refresh() async {
        // Background work
        let status = await withTaskGroup(of: [Resource].self) { group in
            // Parallel integration fetching
        }
        
        // UI update on MainActor
        self.infrastructureStatus = status
    }
}
```

## Testing Strategy

### Integration Testing

Each integration has comprehensive tests:

```swift
@Test("Cloudflare integration fetches pages")
func testCloudflarePages() async throws {
    let integration = try await CloudflareIntegration(configuration: mockConfig)
    let resources = try await integration.getActualState()
    
    let pages = resources.filter { $0.type == .cloudflarePages }
    #expect(pages.count > 0)
}
```

### UI Testing

SwiftUI views are tested with proper accessibility:

```swift
@Test("Dashboard displays infrastructure status")
func testDashboardView() async throws {
    let viewModel = DashboardViewModel()
    viewModel.overallHealth = .healthy
    
    let view = DashboardView()
        .environmentObject(viewModel)
    
    // Test view rendering and accessibility
}
```

## Performance Characteristics

### Network Performance

- **30-second timeouts** for all API calls
- **Exponential backoff** retry policies
- **Concurrent requests** with proper rate limiting
- **Background app refresh** for real-time updates

### Memory Performance

- **Lazy loading** of integration modules
- **Weak references** for delegate patterns
- **Proper view lifecycle** management
- **Memory-efficient** caching strategies

### Battery Performance

- **Background app refresh** limitations
- **Network request batching**
- **Efficient SwiftUI** rendering
- **Location services** only when needed

## Security Architecture

### Authentication Flow

```
1. User enters credentials for GitHub/Cloudflare
2. iOS app sends to CFHub cloud service
3. Cloud service validates with actual providers
4. Cloud service returns CFHub proxy token
5. iOS app stores proxy token in Keychain
6. All API calls go through CFHub cloud proxy
```

### Data Protection

- **Keychain storage** for all credentials
- **Certificate pinning** for API calls
- **No sensitive data** in UserDefaults or files
- **Biometric authentication** for app access

## Deployment Strategy

### App Store Distribution

- **iOS 17.0+** minimum deployment target
- **Universal app** with iPhone/iPad support
- **TestFlight** for beta distribution
- **App Store Connect** for production releases

### CI/CD Pipeline

```yaml
# GitHub Actions workflow
- Build and test all packages
- Run quality gates and linting
- Generate test coverage reports
- Build for App Store distribution
- Submit to TestFlight automatically
```

## Future Architecture Considerations

### Scalability

- **Modular integration** system allows unlimited providers
- **Plugin marketplace** for community integrations
- **Enterprise SSO** integration capabilities
- **Multi-tenant** support for organizations

### Platform Expansion

- **macOS Catalyst** for desktop companion
- **watchOS** for infrastructure monitoring
- **tvOS** for dashboard displays
- **visionOS** for 3D infrastructure visualization

---

**🤖 Generated with [Claude Code](https://claude.ai/code)**

**Co-Authored-By: Claude <noreply@anthropic.com>**