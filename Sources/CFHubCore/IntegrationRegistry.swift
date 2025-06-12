//
// IntegrationRegistry.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//

import Foundation

/// Registry for managing available integrations in CFHub
///
/// This follows the plugin discovery pattern from cloudflare-hub,
/// allowing the core system to dynamically discover and instantiate
/// integrations without tight coupling.
public actor IntegrationRegistry: Sendable {
    private var registeredIntegrations: [String: any IntegrationFactory] = [:]
    private var activeIntegrations: [String: any Integration] = [:]

    public static let shared = IntegrationRegistry()

    private init() {}

    /// Register an integration factory
    public func register<T: Integration>(
        _ integrationType: T.Type,
        factory: @escaping IntegrationFactoryBuilder<T>
    ) {
        let wrapper = ConcreteIntegrationFactory(
            identifier: T.identifier,
            displayName: T.displayName,
            version: T.version,
            requiredPermissions: T.requiredPermissions,
            builder: factory
        )
        registeredIntegrations[T.identifier] = wrapper
    }

    /// Get all registered integration metadata
    public func getRegisteredIntegrations() -> [IntegrationMetadata] {
        return registeredIntegrations.values.map { factory in
            IntegrationMetadata(
                identifier: factory.identifier,
                displayName: factory.displayName,
                version: factory.version,
                requiredPermissions: factory.requiredPermissions,
                isActive: activeIntegrations[factory.identifier] != nil
            )
        }
    }

    /// Create and activate an integration
    public func activateIntegration(
        identifier: String,
        configuration: IntegrationConfiguration
    ) async throws -> any Integration {
        guard let factory = registeredIntegrations[identifier] else {
            throw IntegrationError.unknown(message: "Integration '\(identifier)' not found")
        }

        // Create the integration instance
        let integration = try await factory.create(configuration: configuration)

        // Store the active integration
        activeIntegrations[identifier] = integration

        return integration
    }

    /// Get an active integration
    public func getIntegration(identifier: String) -> (any Integration)? {
        return activeIntegrations[identifier]
    }

    /// Deactivate an integration
    public func deactivateIntegration(identifier: String) {
        activeIntegrations.removeValue(forKey: identifier)
    }

    /// Get all active integrations
    public func getActiveIntegrations() -> [String: any Integration] {
        return activeIntegrations
    }

    /// Perform health checks on all active integrations
    public func healthCheckAll() async -> [String: HealthStatus] {
        var results: [String: HealthStatus] = [:]

        for (identifier, integration) in activeIntegrations {
            do {
                results[identifier] = try await integration.healthCheck()
            } catch {
                results[identifier] = HealthStatus(
                    isHealthy: false,
                    details: ["error": error.localizedDescription]
                )
            }
        }

        return results
    }

    /// Check if an integration is available and registered
    public func isAvailable(identifier: String) -> Bool {
        return registeredIntegrations[identifier] != nil
    }

    /// Check if an integration is currently active
    public func isActive(identifier: String) -> Bool {
        return activeIntegrations[identifier] != nil
    }
}

// MARK: - Supporting Types

/// Factory protocol for creating integrations
public protocol IntegrationFactory: Sendable {
    var identifier: String { get }
    var displayName: String { get }
    var version: String { get }
    var requiredPermissions: [Permission] { get }

    func create(configuration: IntegrationConfiguration) async throws -> any Integration
}

/// Type alias for integration factory builder functions
public typealias IntegrationFactoryBuilder<T: Integration> = @Sendable (IntegrationConfiguration) async throws -> T

/// Concrete implementation of IntegrationFactory
private struct ConcreteIntegrationFactory<T: Integration>: IntegrationFactory {
    let identifier: String
    let displayName: String
    let version: String
    let requiredPermissions: [Permission]
    private let builder: IntegrationFactoryBuilder<T>

    init(
        identifier: String,
        displayName: String,
        version: String,
        requiredPermissions: [Permission],
        builder: @escaping IntegrationFactoryBuilder<T>
    ) {
        self.identifier = identifier
        self.displayName = displayName
        self.version = version
        self.requiredPermissions = requiredPermissions
        self.builder = builder
    }

    func create(configuration: IntegrationConfiguration) async throws -> any Integration {
        return try await builder(configuration)
    }
}

/// Metadata about an available integration
public struct IntegrationMetadata: Sendable, Identifiable {
    public let id: String
    public let identifier: String
    public let displayName: String
    public let version: String
    public let requiredPermissions: [Permission]
    public let isActive: Bool

    public init(
        identifier: String,
        displayName: String,
        version: String,
        requiredPermissions: [Permission],
        isActive: Bool
    ) {
        self.id = identifier
        self.identifier = identifier
        self.displayName = displayName
        self.version = version
        self.requiredPermissions = requiredPermissions
        self.isActive = isActive
    }
}

// MARK: - Integration Registration Helper


// MARK: - Default Integration Registration

/// Helper function to register all available integrations
public func registerDefaultIntegrations() async {
    // This will be implemented when integrations are compiled together
    // For now, integrations register themselves
}
