import Foundation
import CFHubClient

/// Core protocol for all service integrations in CFHub
/// 
/// Each integration (Cloudflare, GitHub, etc.) must implement this protocol
/// to participate in the CFHub ecosystem. This follows the plugin-first
/// architecture from cloudflare-hub.
public protocol Integration: Actor {
    /// Unique identifier for this integration
    static var identifier: String { get }
    
    /// Human-readable name for this integration
    static var displayName: String { get }
    
    /// Version of this integration
    static var version: String { get }
    
    /// Required permissions/scopes for this integration
    static var requiredPermissions: [Permission] { get }
    
    /// Initialize the integration with configuration
    init(configuration: IntegrationConfiguration) async throws
    
    /// Get the current actual state of resources
    func getActualState() async throws -> [Resource]
    
    /// Plan changes from current state to desired state
    func plan(desired: [Resource]) async throws -> [Action]
    
    /// Apply the planned actions
    func apply(actions: [Action]) async throws -> ApplyResult
    
    /// Rollback the last applied changes (if supported)
    func rollback() async throws
    
    /// Health check for this integration
    func healthCheck() async throws -> HealthStatus
}

/// Configuration for integration initialization
public struct IntegrationConfiguration: Sendable {
    public let baseURL: String
    public let authentication: Authentication
    public let timeout: TimeInterval
    public let retryPolicy: RetryPolicy
    
    public init(
        baseURL: String,
        authentication: Authentication,
        timeout: TimeInterval = 30,
        retryPolicy: RetryPolicy = .default
    ) {
        self.baseURL = baseURL
        self.authentication = authentication
        self.timeout = timeout
        self.retryPolicy = retryPolicy
    }
}

/// Authentication methods for integrations
public enum Authentication: Sendable {
    case bearer(token: String)
    case oauth(accessToken: String, refreshToken: String?)
    case apiKey(key: String, secret: String?)
    case none
}


/// Permissions required by integrations
public struct Permission: Sendable, Hashable {
    public let scope: String
    public let level: PermissionLevel
    public let description: String
    
    public init(scope: String, level: PermissionLevel, description: String) {
        self.scope = scope
        self.level = level
        self.description = description
    }
}

/// Permission levels
public enum PermissionLevel: String, Sendable, CaseIterable {
    case read = "read"
    case write = "write"
    case admin = "admin"
}

/// Result of applying actions
public struct ApplyResult: Sendable {
    public let successful: [Action]
    public let failed: [FailedAction]
    public let duration: TimeInterval
    public let metadata: [String: String]
    
    public init(
        successful: [Action],
        failed: [FailedAction],
        duration: TimeInterval,
        metadata: [String: String] = [:]
    ) {
        self.successful = successful
        self.failed = failed
        self.duration = duration
        self.metadata = metadata
    }
}

/// Failed action with error details
public struct FailedAction: Sendable {
    public let action: Action
    public let error: IntegrationError
    public let timestamp: Date
    
    public init(action: Action, error: IntegrationError, timestamp: Date = Date()) {
        self.action = action
        self.error = error
        self.timestamp = timestamp
    }
}

/// Health status of an integration
public struct HealthStatus: Sendable {
    public let isHealthy: Bool
    public let latency: TimeInterval?
    public let lastCheck: Date
    public let details: [String: String]
    
    public init(
        isHealthy: Bool,
        latency: TimeInterval? = nil,
        lastCheck: Date = Date(),
        details: [String: String] = [:]
    ) {
        self.isHealthy = isHealthy
        self.latency = latency
        self.lastCheck = lastCheck
        self.details = details
    }
}