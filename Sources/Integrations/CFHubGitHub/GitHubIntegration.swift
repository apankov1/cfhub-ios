//
// GitHubIntegration.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//

import CFHubClient
import CFHubCore
import Foundation

/// GitHub integration for CFHub iOS
///
/// Self-contained integration following cloudflare-hub patterns.
/// Owns all GitHub-specific types, API calls, and business logic.
public actor GitHubIntegration: Integration, Sendable {
    public static let identifier = "github"
    public static let displayName = "GitHub"
    public static let version = "1.0.0"

    public static let requiredPermissions: [Permission] = [
        Permission(scope: "repo", level: .read, description: "Read repositories"),
        Permission(scope: "repo", level: .write, description: "Manage repositories"),
        Permission(scope: "actions", level: .read, description: "Read GitHub Actions"),
        Permission(scope: "actions", level: .write, description: "Trigger deployments"),
        Permission(scope: "deployments", level: .read, description: "Read deployments"),
        Permission(scope: "deployments", level: .write, description: "Create deployments")
    ]

    private let client: HTTPClient
    private let configuration: IntegrationConfiguration

    public init(configuration: IntegrationConfiguration) async throws {
        self.configuration = configuration

        // Initialize HTTP client with GitHub API settings
        var headers = [
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": "CFHub-iOS/\(Self.version)"
        ]

        // Add authentication header
        switch configuration.authentication {
        case .bearer(let token):
            headers["Authorization"] = "Bearer \(token)"
        case .oauth(let accessToken, _):
            headers["Authorization"] = "token \(accessToken)"
        default:
            throw IntegrationError.authenticationFailed(reason: "Invalid authentication method for GitHub")
        }

        guard let baseURL = URL(string: configuration.baseURL) else {
            throw IntegrationError.invalidConfiguration(reason: "Invalid base URL: \(configuration.baseURL)")
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
        async let repositories = getGitHubRepositories()
        async let deployments = getGitHubDeployments()
        async let environments = getGitHubEnvironments()

        do {
            let (reposResult, deploymentsResult, environmentsResult) = try await (repositories, deployments, environments)
            resources.append(contentsOf: reposResult)
            resources.append(contentsOf: deploymentsResult)
            resources.append(contentsOf: environmentsResult)
        } catch {
            throw IntegrationError.actionFailed(
                action: Action(type: .create, resourceId: "", resourceType: .githubRepository, operation: .start),
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
        // GitHub rollback implementation would go here
        throw IntegrationError.unsupportedOperation(
            operation: "rollback",
            context: "GitHub rollback not yet implemented"
        )
    }

    public func healthCheck() async throws -> HealthStatus {
        let startTime = Date()

        do {
            // Simple health check - get user info
            let response = try await client.get(
                path: "/user",
                responseType: GitHubUser.self
            )

            let latency = Date().timeIntervalSince(startTime)

            return HealthStatus(
                isHealthy: response.isSuccessful,
                latency: latency,
                details: [
                    "integration": Self.identifier,
                    "api_version": "2022-11-28",
                    "user_login": response.body?.login ?? "unknown"
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

    private func getGitHubRepositories() async throws -> [Resource] {
        // Get repositories for the authenticated user
        let response = try await client.get(
            path: "/user/repos",
            queryParameters: [
                "type": "owner",
                "sort": "updated",
                "per_page": "100"
            ],
            responseType: [GitHubRepository].self
        )

        guard let repositories = response.body else {
            return []
        }

        return repositories.map { repo in
            Resource(
                id: String(repo.id),
                type: .githubRepository,
                name: repo.name,
                status: repo.archived ? .suspended : .active,
                configuration: ResourceConfiguration([
                    "full_name": ConfigurationValue(repo.full_name),
                    "private": ConfigurationValue(repo.`private`),
                    "default_branch": ConfigurationValue(repo.default_branch),
                    "clone_url": ConfigurationValue(repo.clone_url),
                    "language": ConfigurationValue(repo.language ?? "")
                ]),
                metadata: ResourceMetadata(
                    tags: repo.topics ?? [],
                    labels: [
                        "owner": repo.owner.login,
                        "type": repo.owner.type
                    ],
                    owner: repo.owner.login
                )
            )
        }
    }

    private func getGitHubDeployments() async throws -> [Resource] {
        // In a real implementation, we'd get deployments for specific repositories
        // For now, return empty array as this requires repository context
        return []
    }

    private func getGitHubEnvironments() async throws -> [Resource] {
        // In a real implementation, we'd get environments for specific repositories
        // For now, return empty array as this requires repository context
        return []
    }

    private func getRepositoryDeployments(owner: String, repo: String) async throws -> [Resource] {
        let response = try await client.get(
            path: "/repos/\(owner)/\(repo)/deployments",
            queryParameters: ["per_page": "50"],
            responseType: [GitHubDeployment].self
        )

        guard let deployments = response.body else {
            return []
        }

        return deployments.map { deployment in
            Resource(
                id: String(deployment.id),
                type: .githubDeployment,
                name: "\(repo)-\(deployment.sha.prefix(7))",
                status: mapGitHubDeploymentStatus(deployment.statuses_url),
                configuration: ResourceConfiguration([
                    "sha": ConfigurationValue(deployment.sha),
                    "ref": ConfigurationValue(deployment.ref),
                    "environment": ConfigurationValue(deployment.environment),
                    "description": ConfigurationValue(deployment.description ?? "")
                ]),
                metadata: ResourceMetadata(
                    labels: [
                        "repository": "\(owner)/\(repo)",
                        "creator": deployment.creator?.login ?? "unknown"
                    ]
                )
            )
        }
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
        case (.create, .githubRepository):
            try await createGitHubRepository(action)
        case (.delete, .githubRepository):
            try await deleteGitHubRepository(action)
        case (.create, .githubDeployment):
            try await createGitHubDeployment(action)
        case (.deploy, .githubDeployment):
            try await triggerGitHubDeployment(action)
        default:
            throw IntegrationError.actionNotSupported(
                action: action.type,
                resourceType: action.resourceType
            )
        }
    }

    private func createGitHubRepository(_ action: Action) async throws {
        // Implementation would create a GitHub repository
        throw IntegrationError.unsupportedOperation(
            operation: "create_repository",
            context: "GitHub repository creation not yet implemented"
        )
    }

    private func deleteGitHubRepository(_ action: Action) async throws {
        // Implementation would delete a GitHub repository
        throw IntegrationError.unsupportedOperation(
            operation: "delete_repository",
            context: "GitHub repository deletion not yet implemented"
        )
    }

    private func createGitHubDeployment(_ action: Action) async throws {
        // Implementation would create a GitHub deployment
        throw IntegrationError.unsupportedOperation(
            operation: "create_deployment",
            context: "GitHub deployment creation not yet implemented"
        )
    }

    private func triggerGitHubDeployment(_ action: Action) async throws {
        // Implementation would trigger a GitHub Actions workflow
        throw IntegrationError.unsupportedOperation(
            operation: "trigger_deployment",
            context: "GitHub deployment triggering not yet implemented"
        )
    }

    private func mapGitHubDeploymentStatus(_ statusesUrl: String) -> ResourceStatus {
        // In a real implementation, we'd fetch the actual deployment status
        // For now, default to active
        return .active
    }
}

// MARK: - GitHub-specific Types

/// These types are owned by the GitHub integration and not shared
/// This follows the distributed types pattern from cloudflare-hub

struct GitHubUser: Codable {
    let id: Int
    let login: String
    let name: String?
    let email: String?
    let type: String
}

struct GitHubRepository: Codable {
    let id: Int
    let name: String
    let full_name: String
    let owner: GitHubUser
    let `private`: Bool
    let description: String?
    let fork: Bool
    let archived: Bool
    let disabled: Bool
    let default_branch: String
    let language: String?
    let topics: [String]?
    let clone_url: String
    let ssh_url: String
    let html_url: String
    let created_at: String
    let updated_at: String
    let pushed_at: String?
}

struct GitHubDeployment: Codable {
    let id: Int
    let sha: String
    let ref: String
    let task: String
    let environment: String
    let description: String?
    let creator: GitHubUser?
    let created_at: String
    let updated_at: String
    let statuses_url: String
    let repository_url: String
}

struct GitHubDeploymentStatus: Codable {
    let id: Int
    let state: String
    let description: String?
    let target_url: String?
    let created_at: String
    let updated_at: String
    let deployment_url: String
    let repository_url: String
}

struct GitHubEnvironment: Codable {
    let id: Int
    let name: String
    let url: String
    let html_url: String
    let created_at: String
    let updated_at: String
    let protection_rules: [GitHubEnvironmentProtectionRule]?
    let deployment_branch_policy: GitHubDeploymentBranchPolicy?
}

struct GitHubEnvironmentProtectionRule: Codable {
    let id: Int
    let type: String
    let wait_timer: Int?
    let reviewers: [GitHubEnvironmentReviewer]?
}

struct GitHubEnvironmentReviewer: Codable {
    let type: String
    let reviewer: GitHubUser?
}

struct GitHubDeploymentBranchPolicy: Codable {
    let protected_branches: Bool
    let custom_branch_policies: Bool
}

struct GitHubWorkflow: Codable {
    let id: Int
    let name: String
    let path: String
    let state: String
    let created_at: String
    let updated_at: String
    let url: String
    let html_url: String
    let badge_url: String
}

struct GitHubWorkflowRun: Codable {
    let id: Int
    let name: String?
    let head_branch: String
    let head_sha: String
    let status: String
    let conclusion: String?
    let workflow_id: Int
    let url: String
    let html_url: String
    let created_at: String
    let updated_at: String
    let run_started_at: String?
}
