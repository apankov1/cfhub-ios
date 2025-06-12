//
// CloudflareIntegration.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//

import CFHubClient
import CFHubCore
import Foundation

/// Cloudflare integration for CFHub iOS
///
/// Self-contained integration following cloudflare-hub patterns.
/// Owns all Cloudflare-specific types, API calls, and business logic.
public actor CloudflareIntegration: Integration {
    public static let identifier = "cloudflare"
    public static let displayName = "Cloudflare"
    public static let version = "1.0.0"

    public static let requiredPermissions: [Permission] = [
        Permission(scope: "zone", level: .read, description: "Read DNS zones"),
        Permission(scope: "zone", level: .write, description: "Manage DNS records"),
        Permission(scope: "page", level: .read, description: "Read Cloudflare Pages"),
        Permission(scope: "page", level: .write, description: "Deploy to Cloudflare Pages"),
        Permission(scope: "worker", level: .read, description: "Read Cloudflare Workers"),
        Permission(scope: "worker", level: .write, description: "Deploy Cloudflare Workers")
    ]

    private let client: HTTPClient
    private let configuration: IntegrationConfiguration

    public init(configuration: IntegrationConfiguration) async throws {
        self.configuration = configuration

        // Initialize HTTP client with Cloudflare API settings
        var headers = [
            "Content-Type": "application/json",
            "User-Agent": "CFHub-iOS/\(Self.version)"
        ]

        // Add authentication header
        switch configuration.authentication {
        case .bearer(let token):
            headers["Authorization"] = "Bearer \(token)"
        case let .apiKey(key, email):
            headers["X-Auth-Email"] = email ?? ""
            headers["X-Auth-Key"] = key
        default:
            throw IntegrationError.authenticationFailed(reason: "Invalid authentication method for Cloudflare")
        }

        guard let baseURL = URL(string: configuration.baseURL) else {
            throw IntegrationError.invalidConfiguration(
                field: "baseURL", 
                reason: "Invalid base URL: \(configuration.baseURL)"
            )
        }

        self.client = HTTPClient(
            baseURL: baseURL,
            defaultHeaders: headers,
            retryPolicy: configuration.retryPolicy,
            timeout: configuration.timeout
        )

        // Verify authentication
        try await verifyAuthentication()
    }

    public func getActualState() async throws -> [Resource] {
        var resources: [Resource] = []

        // Get all resources in parallel
        async let pages = getCloudflarePages()
        async let workers = getCloudflareWorkers()
        async let zones = getCloudflareZones()

        do {
            let (pagesResult, workersResult, zonesResult) = try await (pages, workers, zones)
            resources.append(contentsOf: pagesResult)
            resources.append(contentsOf: workersResult)
            resources.append(contentsOf: zonesResult)
        } catch {
            throw IntegrationError.actionFailed(
                action: Action(type: .create, resourceId: "", resourceType: .cloudflarePages, operation: .start),
                underlyingError: error.localizedDescription
            )
        }

        return resources
    }

    public func plan(desired: [Resource]) async throws -> [Action] {
        let actual = try await getActualState()
        return try generateActions(from: actual, to: desired)
    }

    public func apply(actions: [Action]) async throws -> ApplyResult {
        let startTime = Date()
        var successful: [Action] = []
        var failed: [FailedAction] = []

        // Execute actions sequentially to handle dependencies
        for action in actions {
            do {
                try await executeAction(action)
                successful.append(action)
            } catch {
                let integrationError = error as? IntegrationError ??
                    IntegrationError.unknown(message: error.localizedDescription)
                failed.append(FailedAction(action: action, error: integrationError))
            }
        }

        return ApplyResult(
            successful: successful,
            failed: failed,
            duration: Date().timeIntervalSince(startTime),
            metadata: [
                "integration": Self.identifier,
                "version": Self.version
            ]
        )
    }

    public func rollback() async throws {
        // Cloudflare rollback implementation would go here
        throw IntegrationError.unsupportedOperation(
            operation: "rollback",
            context: "Cloudflare rollback not yet implemented"
        )
    }

    public func healthCheck() async throws -> HealthStatus {
        let startTime = Date()

        do {
            // Simple health check - get user info
            let response = try await client.get(
                path: "/user",
                responseType: CloudflareUserResponse.self
            )

            let latency = Date().timeIntervalSince(startTime)

            return HealthStatus(
                isHealthy: response.isSuccessful,
                latency: latency,
                details: [
                    "integration": Self.identifier,
                    "api_version": "v4",
                    "user_id": response.body?.result.id ?? "unknown"
                ]
            )
        } catch {
            return HealthStatus(
                isHealthy: false,
                latency: Date().timeIntervalSince(startTime),
                details: [
                    "integration": Self.identifier,
                    "error": error.localizedDescription
                ]
            )
        }
    }

    // MARK: - Private Methods

    private func verifyAuthentication() async throws {
        let health = try await healthCheck()
        guard health.isHealthy else {
            throw IntegrationError.authenticationFailed(reason: "Health check failed")
        }
    }

    private func getCloudflarePages() async throws -> [Resource] {
        let response = try await client.get(
            path: "/accounts/\(try await getAccountId())/pages/projects",
            responseType: CloudflarePagesResponse.self
        )

        guard let pages = response.body?.result else {
            return []
        }

        return pages.map { page in
            Resource(
                id: page.id,
                type: .cloudflarePages,
                name: page.name,
                status: mapCloudflareStatus(page.deploymentConfigs.production.deployment?.stage ?? ""),
                configuration: ResourceConfiguration([
                    "domain": ConfigurationValue(page.domains?.first ?? ""),
                    "source": ConfigurationValue(page.source?.type ?? ""),
                    "build_command": ConfigurationValue(page.buildConfig?.buildCommand ?? "")
                ])
            )
        }
    }

    private func getCloudflareWorkers() async throws -> [Resource] {
        let response = try await client.get(
            path: "/accounts/\(try await getAccountId())/workers/scripts",
            responseType: CloudflareWorkersResponse.self
        )

        guard let workers = response.body?.result else {
            return []
        }

        return workers.map { worker in
            Resource(
                id: worker.id,
                type: .cloudflareWorker,
                name: worker.id,
                status: .active, // Workers don't have detailed status
                configuration: ResourceConfiguration([
                    "usage_model": ConfigurationValue(worker.usageModel ?? "bundled"),
                    "routes": ConfigurationValue(worker.routes?.map(\.pattern) ?? [])
                ])
            )
        }
    }

    private func getCloudflareZones() async throws -> [Resource] {
        let response = try await client.get(
            path: "/zones",
            responseType: CloudflareZonesResponse.self
        )

        guard let zones = response.body?.result else {
            return []
        }

        return zones.map { zone in
            Resource(
                id: zone.id,
                type: .cloudflareDNS,
                name: zone.name,
                status: mapCloudflareStatus(zone.status),
                configuration: ResourceConfiguration([
                    "name_servers": ConfigurationValue(zone.nameServers),
                    "plan": ConfigurationValue(zone.plan.name),
                    "development_mode": ConfigurationValue(zone.developmentMode ?? 0)
                ])
            )
        }
    }

    private func getAccountId() async throws -> String {
        // In a real implementation, this would be cached or configured
        let response = try await client.get(
            path: "/accounts",
            responseType: CloudflareAccountsResponse.self
        )

        guard let account = response.body?.result.first else {
            throw IntegrationError.configurationConflict(
                field1: "account",
                field2: "authentication",
                reason: "No accessible accounts found"
            )
        }

        return account.id
    }

    private func generateActions(from actual: [Resource], to desired: [Resource]) throws -> [Action] {
        var actions: [Action] = []

        // Simple diff logic - in practice this would be more sophisticated
        let actualIds = Set(actual.map(\.id))
        let desiredIds = Set(desired.map(\.id))

        // Resources to create
        for desiredResource in desired where !actualIds.contains(desiredResource.id) {
            actions.append(Action(
                type: .create,
                resourceId: desiredResource.id,
                resourceType: desiredResource.type,
                operation: .createResource(configuration: desiredResource.configuration)
            ))
        }

        // Resources to delete
        for actualResource in actual where !desiredIds.contains(actualResource.id) {
            actions.append(Action(
                type: .delete,
                resourceId: actualResource.id,
                resourceType: actualResource.type,
                operation: .deleteResource
            ))
        }

        return actions
    }

    private func executeAction(_ action: Action) async throws {
        switch (action.type, action.resourceType) {
        case (.create, .cloudflarePages):
            try await createCloudflarePages(action)
        case (.delete, .cloudflarePages):
            try await deleteCloudflarePages(action)
        case (.create, .cloudflareWorker):
            try await createCloudflareWorker(action)
        case (.delete, .cloudflareWorker):
            try await deleteCloudflareWorker(action)
        default:
            throw IntegrationError.actionNotSupported(
                action: action.type,
                resourceType: action.resourceType
            )
        }
    }

    private func createCloudflarePages(_ action: Action) async throws {
        // Implementation would create a Cloudflare Pages project
        throw IntegrationError.unsupportedOperation(
            operation: "create_pages",
            context: "Cloudflare Pages creation not yet implemented"
        )
    }

    private func deleteCloudflarePages(_ action: Action) async throws {
        // Implementation would delete a Cloudflare Pages project
        throw IntegrationError.unsupportedOperation(
            operation: "delete_pages",
            context: "Cloudflare Pages deletion not yet implemented"
        )
    }

    private func createCloudflareWorker(_ action: Action) async throws {
        // Implementation would create a Cloudflare Worker
        throw IntegrationError.unsupportedOperation(
            operation: "create_worker",
            context: "Cloudflare Worker creation not yet implemented"
        )
    }

    private func deleteCloudflareWorker(_ action: Action) async throws {
        // Implementation would delete a Cloudflare Worker
        throw IntegrationError.unsupportedOperation(
            operation: "delete_worker",
            context: "Cloudflare Worker deletion not yet implemented"
        )
    }

    private func mapCloudflareStatus(_ status: String) -> ResourceStatus {
        switch status.lowercased() {
        case "active":
            return .active
        case "pending":
            return .creating
        case "initializing":
            return .creating
        case "failure":
            return .failed
        default:
            return .unknown
        }
    }
}

// MARK: - Cloudflare-specific Types

/// These types are owned by the Cloudflare integration and not shared
/// This follows the distributed types pattern from cloudflare-hub

struct CloudflareUserResponse: Codable {
    let success: Bool
    let result: CloudflareUser
}

struct CloudflareUser: Codable {
    let id: String
    let email: String
}

struct CloudflarePagesResponse: Codable {
    let success: Bool
    let result: [CloudflarePage]
}

struct CloudflarePage: Codable {
    let id: String
    let name: String
    let domains: [String]?
    let source: CloudflarePageSource?
    let buildConfig: CloudflarePageBuildConfig?
    let deploymentConfigs: CloudflarePageDeploymentConfigs
}

struct CloudflarePageSource: Codable {
    let type: String
    let config: CloudflarePageSourceConfig?
}

struct CloudflarePageSourceConfig: Codable {
    let owner: String
    let repoName: String
    let productionBranch: String
}

struct CloudflarePageBuildConfig: Codable {
    let buildCommand: String?
    let destinationDir: String?
    let rootDir: String?
}

struct CloudflarePageDeploymentConfigs: Codable {
    let production: CloudflarePageDeploymentConfig
    let preview: CloudflarePageDeploymentConfig
}

struct CloudflarePageDeploymentConfig: Codable {
    let deployment: CloudflarePageDeployment?
}

struct CloudflarePageDeployment: Codable {
    let stage: String
    let url: String?
}

struct CloudflareWorkersResponse: Codable {
    let success: Bool
    let result: [CloudflareWorker]
}

struct CloudflareWorker: Codable {
    let id: String
    let usageModel: String?
    let routes: [CloudflareWorkerRoute]?
}

struct CloudflareWorkerRoute: Codable {
    let pattern: String
    let zoneId: String?
}

struct CloudflareZonesResponse: Codable {
    let success: Bool
    let result: [CloudflareZone]
}

struct CloudflareZone: Codable {
    let id: String
    let name: String
    let status: String
    let nameServers: [String]
    let plan: CloudflareZonePlan
    let developmentMode: Int?
}

struct CloudflareZonePlan: Codable {
    let id: String
    let name: String
}

struct CloudflareAccountsResponse: Codable {
    let success: Bool
    let result: [CloudflareAccount]
}

struct CloudflareAccount: Codable {
    let id: String
    let name: String
}
