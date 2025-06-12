//
// DashboardViewModel.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//

import Foundation
import SwiftUI
import Combine
import CFHubCore

/// Dashboard view model implementing cloud-native patterns
/// 
/// Provides real-time infrastructure monitoring following
/// the cloudflare-hub approach of ephemeral environments
/// and instant status visibility.
@MainActor
class DashboardViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var infrastructureStatus: InfrastructureStatus?
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var error: DashboardError?
    @Published var lastUpdated: Date?
    
    // Computed properties for UI
    @Published var overallHealth: OverallHealth = .unknown
    @Published var activeDeployments: [DeploymentSummary] = []
    @Published var environments: [EnvironmentSummary] = []
    @Published var quickActions: [QuickAction] = []
    
    // MARK: - Private Properties
    
    private let integrationRegistry = IntegrationRegistry.shared
    private var refreshTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        setupQuickActions()
        startPeriodicRefresh()
    }
    
    deinit {
        stopRealTimeUpdates()
    }
    
    // MARK: - Public Methods
    
    /// Start real-time updates for the dashboard
    func startRealTimeUpdates() async {
        await refresh()
        startPeriodicRefresh()
    }
    
    /// Stop real-time updates
    func stopRealTimeUpdates() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    /// Refresh all dashboard data
    func refresh() async {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        error = nil
        
        do {
            let status = try await fetchInfrastructureStatus()
            await updateDashboardData(with: status)
            lastUpdated = Date()
        } catch {
            await handleError(error)
        }
        
        isRefreshing = false
    }
    
    /// Execute a quick action
    func executeQuickAction(_ action: QuickAction) async {
        switch action.type {
        case .deployBranch:
            await deployCurrentBranch()
        case .viewLogs:
            await openLogStream()
        case .triggerEmergencyRollback:
            await triggerEmergencyRollback()
        case .createEnvironment:
            await createEphemeralEnvironment()
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchInfrastructureStatus() async throws -> InfrastructureStatus {
        let activeIntegrations = await integrationRegistry.getActiveIntegrations()
        
        var allResources: [Resource] = []
        var integrationErrors: [String] = []
        
        // Fetch resources from all active integrations in parallel
        await withTaskGroup(of: (String, Result<[Resource], Error>).self) { group in
            for (identifier, integration) in activeIntegrations {
                group.addTask {
                    do {
                        let resources = try await integration.getActualState()
                        return (identifier, .success(resources))
                    } catch {
                        return (identifier, .failure(error))
                    }
                }
            }
            
            for await (identifier, result) in group {
                switch result {
                case .success(let resources):
                    allResources.append(contentsOf: resources)
                case .failure(let error):
                    integrationErrors.append("\(identifier): \(error.localizedDescription)")
                }
            }
        }
        
        // Group resources by type
        let environments = allResources.filter { $0.type == .environment }
        let deployments = allResources.filter { $0.type == .deployment }
        let infraResources = allResources.filter { ![.environment, .deployment].contains($0.type) }
        
        return InfrastructureStatus(
            environments: environments,
            deployments: deployments,
            resources: infraResources,
            lastUpdated: Date(),
            errors: integrationErrors
        )
    }
    
    private func updateDashboardData(with status: InfrastructureStatus) async {
        infrastructureStatus = status
        
        // Update overall health
        overallHealth = calculateOverallHealth(from: status)
        
        // Update active deployments
        activeDeployments = status.deployments
            .filter { $0.status.isTransitional }
            .map { deployment in
                DeploymentSummary(
                    id: deployment.id,
                    name: deployment.name,
                    status: deployment.status,
                    progress: calculateDeploymentProgress(deployment),
                    estimatedCompletion: estimateCompletion(deployment)
                )
            }
        
        // Update environments
        environments = status.environments.map { environment in
            EnvironmentSummary(
                id: environment.id,
                name: environment.name,
                status: environment.status,
                url: environment.configuration.value(for: "url", as: String.self),
                lastDeployed: environment.updatedAt,
                resourceCount: countResourcesForEnvironment(environment.id, in: status)
            )
        }
    }
    
    private func calculateOverallHealth(from status: InfrastructureStatus) -> OverallHealth {
        let allResources = status.environments + status.deployments + status.resources
        
        guard !allResources.isEmpty else { return .unknown }
        
        let healthyCount = allResources.filter { $0.status.isHealthy }.count
        let totalCount = allResources.count
        let healthPercentage = Double(healthyCount) / Double(totalCount)
        
        if !status.errors.isEmpty {
            return .degraded
        }
        
        switch healthPercentage {
        case 1.0:
            return .healthy
        case 0.8..<1.0:
            return .degraded
        case 0.5..<0.8:
            return .warning
        default:
            return .critical
        }
    }
    
    private func calculateDeploymentProgress(_ deployment: Resource) -> Double {
        // In a real implementation, this would parse deployment logs or status
        return deployment.status.isTransitional ? 0.7 : 1.0
    }
    
    private func estimateCompletion(_ deployment: Resource) -> Date? {
        // Simple estimation based on deployment age
        let deploymentAge = Date().timeIntervalSince(deployment.createdAt)
        let estimatedDuration: TimeInterval = 300 // 5 minutes average
        
        if deploymentAge < estimatedDuration {
            return Date().addingTimeInterval(estimatedDuration - deploymentAge)
        }
        
        return nil
    }
    
    private func countResourcesForEnvironment(_ environmentId: String, in status: InfrastructureStatus) -> Int {
        return status.resources.filter { resource in
            resource.metadata.environment == environmentId
        }.count
    }
    
    private func setupQuickActions() {
        quickActions = [
            QuickAction(
                id: "deploy-branch",
                title: "Deploy Current Branch",
                subtitle: "Create ephemeral environment",
                icon: "cloud.bolt.fill",
                type: .deployBranch,
                isDestructive: false
            ),
            QuickAction(
                id: "view-logs",
                title: "View Deployment Logs",
                subtitle: "Real-time log streaming",
                icon: "doc.text.magnifyingglass",
                type: .viewLogs,
                isDestructive: false
            ),
            QuickAction(
                id: "emergency-rollback",
                title: "Emergency Rollback",
                subtitle: "Rollback to last stable",
                icon: "arrow.counterclockwise.circle.fill",
                type: .triggerEmergencyRollback,
                isDestructive: true
            ),
            QuickAction(
                id: "create-environment",
                title: "Create Environment",
                subtitle: "New feature environment",
                icon: "plus.circle.fill",
                type: .createEnvironment,
                isDestructive: false
            )
        ]
    }
    
    private func startPeriodicRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            Task { @MainActor in
                await self.refresh()
            }
        }
    }
    
    private func handleError(_ error: Error) async {
        if let dashboardError = error as? DashboardError {
            self.error = dashboardError
        } else if let integrationError = error as? IntegrationError {
            self.error = .integrationError(integrationError)
        } else {
            self.error = .unknown(error.localizedDescription)
        }
    }
    
    // MARK: - Quick Action Implementations
    
    private func deployCurrentBranch() async {
        // Implementation would trigger a deployment of the current Git branch
        // This demonstrates the "ephemeral environments" pattern from cloudflare-hub
        print("Triggering deployment of current branch...")
    }
    
    private func openLogStream() async {
        // Implementation would open real-time log streaming
        print("Opening log stream...")
    }
    
    private func triggerEmergencyRollback() async {
        // Implementation would trigger an emergency rollback
        print("Triggering emergency rollback...")
    }
    
    private func createEphemeralEnvironment() async {
        // Implementation would create a new ephemeral environment
        print("Creating ephemeral environment...")
    }
}

// MARK: - Supporting Types

/// Overall infrastructure health status
enum OverallHealth: String, CaseIterable {
    case healthy = "healthy"
    case degraded = "degraded"
    case warning = "warning"
    case critical = "critical"
    case unknown = "unknown"
    
    var color: Color {
        switch self {
        case .healthy: return .green
        case .degraded: return .yellow
        case .warning: return .orange
        case .critical: return .red
        case .unknown: return .gray
        }
    }
    
    var iconName: String {
        switch self {
        case .healthy: return "checkmark.circle.fill"
        case .degraded: return "exclamationmark.triangle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.circle.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
}

/// Infrastructure status summary
struct InfrastructureStatus {
    let environments: [Resource]
    let deployments: [Resource]
    let resources: [Resource]
    let lastUpdated: Date
    let errors: [String]
}

/// Deployment summary for dashboard display
struct DeploymentSummary: Identifiable {
    let id: String
    let name: String
    let status: ResourceStatus
    let progress: Double
    let estimatedCompletion: Date?
}

/// Environment summary for dashboard display
struct EnvironmentSummary: Identifiable {
    let id: String
    let name: String
    let status: ResourceStatus
    let url: String?
    let lastDeployed: Date
    let resourceCount: Int
}

/// Quick action definition
struct QuickAction: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let type: QuickActionType
    let isDestructive: Bool
}

/// Quick action types
enum QuickActionType {
    case deployBranch
    case viewLogs
    case triggerEmergencyRollback
    case createEnvironment
}

/// Dashboard-specific errors
enum DashboardError: Error, LocalizedError {
    case integrationError(IntegrationError)
    case noActiveIntegrations
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .integrationError(let error):
            return "Integration error: \(error.localizedDescription)"
        case .noActiveIntegrations:
            return "No active integrations. Please check your authentication."
        case .unknown(let message):
            return "Dashboard error: \(message)"
        }
    }
}