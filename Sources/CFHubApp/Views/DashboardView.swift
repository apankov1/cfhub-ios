//
// DashboardView.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//

import CFHubCore
import SwiftUI

/// Main dashboard view showing infrastructure status
///
/// Implements cloud-native patterns from cloudflare-hub:
/// - Real-time infrastructure monitoring
/// - Emergency response capabilities
/// - Ephemeral environment status
/// - Quick deployment actions
struct DashboardView: View {
    @EnvironmentObject private var viewModel: DashboardViewModel
    @State private var showingQuickActions = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Overall Status Card
                    OverallStatusCard(
                        health: viewModel.overallHealth,
                        lastUpdated: viewModel.lastUpdated
                    )

                    // Active Deployments
                    if !viewModel.activeDeployments.isEmpty {
                        ActiveDeploymentsCard(deployments: viewModel.activeDeployments)
                    }

                    // Environments Grid
                    EnvironmentsGrid(environments: viewModel.environments)

                    // Quick Actions
                    QuickActionsCard(
                        actions: viewModel.quickActions
                    ) { action in
                        Task {
                            await viewModel.executeQuickAction(action)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Infrastructure")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .refreshable {
                await viewModel.refresh()
            }
            .toolbar {
                ToolbarItem(placement: {
                    #if os(iOS)
                    return .navigationBarTrailing
                    #else
                    return .automatic
                    #endif
                }()) {
                    Button {
                        showingQuickActions = true
                    } label: {
                        Image(systemName: "bolt.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingQuickActions) {
                QuickActionsSheet(
                    actions: viewModel.quickActions
                ) { action in
                    showingQuickActions = false
                    Task {
                        await viewModel.executeQuickAction(action)
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Loading infrastructure...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
            .alert("Dashboard Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "Unknown error")
            }
        }
    }
}

/// Overall infrastructure health status card
struct OverallStatusCard: View {
    let health: OverallHealth
    let lastUpdated: Date?

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: health.iconName)
                    .font(.title)
                    .foregroundColor(health.color)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Infrastructure Status")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(health.rawValue.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(health.color)
                }

                Spacer()
            }

            if let lastUpdated = lastUpdated {
                HStack {
                    Text("Last updated:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(lastUpdated, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()
                }
            }
        }
        .padding()
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(NSColor.windowBackgroundColor))
        #endif
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

/// Active deployments card showing ongoing operations
struct ActiveDeploymentsCard: View {
    let deployments: [DeploymentSummary]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "cloud.bolt.fill")
                    .foregroundColor(.blue)

                Text("Active Deployments")
                    .font(.headline)

                Spacer()

                Badge(text: "\(deployments.count)", color: .blue)
            }

            ForEach(deployments) { deployment in
                DeploymentRow(deployment: deployment)
            }
        }
        .padding()
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(NSColor.windowBackgroundColor))
        #endif
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

/// Individual deployment row
struct DeploymentRow: View {
    let deployment: DeploymentSummary

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(deployment.name)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(deployment.status.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let completion = deployment.estimatedCompletion {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("ETA")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Text(completion, style: .relative)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }

            ProgressView(value: deployment.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
        }
        .padding(.vertical, 4)
    }
}

/// Environments grid showing all environment status
struct EnvironmentsGrid: View {
    let environments: [EnvironmentSummary]

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "server.rack")
                    .foregroundColor(.green)

                Text("Environments")
                    .font(.headline)

                Spacer()

                Badge(text: "\(environments.count)", color: .green)
            }

            if environments.isEmpty {
                EmptyStateView(
                    icon: "server.rack",
                    title: "No Environments",
                    subtitle: "Create your first environment to get started"
                )
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(environments) { environment in
                        EnvironmentCard(environment: environment)
                    }
                }
            }
        }
        .padding()
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(NSColor.windowBackgroundColor))
        #endif
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

/// Individual environment card
struct EnvironmentCard: View {
    let environment: EnvironmentSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(environment.status.isHealthy ? Color.green : Color.red)
                    .frame(width: 8, height: 8)

                Text(environment.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 4) {
                if let url = environment.url {
                    HStack {
                        Image(systemName: "link")
                            .font(.caption2)
                            .foregroundColor(.blue)

                        Text(url)
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .lineLimit(1)
                    }
                }

                HStack {
                    Text("\(environment.resourceCount) resources")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(environment.lastDeployed, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        #if os(iOS)
        .background(Color(.secondarySystemBackground))
        #else
        .background(Color(NSColor.controlBackgroundColor))
        #endif
        .cornerRadius(8)
    }
}

/// Quick actions card
struct QuickActionsCard: View {
    let actions: [QuickAction]
    let onActionSelected: (QuickAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.orange)

                Text("Quick Actions")
                    .font(.headline)

                Spacer()
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(actions) { action in
                    QuickActionButton(action: action) {
                        onActionSelected(action)
                    }
                }
            }
        }
        .padding()
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(NSColor.windowBackgroundColor))
        #endif
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

/// Individual quick action button
struct QuickActionButton: View {
    let action: QuickAction
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: action.icon)
                    .font(.title2)
                    .foregroundColor(action.isDestructive ? .red : .blue)

                VStack(spacing: 2) {
                    Text(action.title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)

                    Text(action.subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            #if os(iOS)
            .background(Color(.secondarySystemBackground))
            #else
            .background(Color(NSColor.controlBackgroundColor))
            #endif
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Quick actions sheet for full-screen action selection
struct QuickActionsSheet: View {
    let actions: [QuickAction]
    let onActionSelected: (QuickAction) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List(actions) { action in
                QuickActionRow(action: action) {
                    onActionSelected(action)
                }
            }
            .navigationTitle("Quick Actions")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: {
                    #if os(iOS)
                    return .navigationBarTrailing
                    #else
                    return .automatic
                    #endif
                }()) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Quick action row for the sheet
struct QuickActionRow: View {
    let action: QuickAction
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: action.icon)
                    .font(.title2)
                    .foregroundColor(action.isDestructive ? .red : .blue)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(action.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(action.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if action.isDestructive {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supporting Views

/// Badge view for counts and status
struct Badge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

/// Empty state view
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

// MARK: - Preview Support

/*
#Preview("Dashboard - Healthy") {
    DashboardView()
        .environmentObject({
            let vm = DashboardViewModel()
            vm.overallHealth = .healthy
            vm.lastUpdated = Date()
            vm.activeDeployments = [
                DeploymentSummary(
                    id: "1",
                    name: "feature/auth-flow",
                    status: .creating,
                    progress: 0.7,
                    estimatedCompletion: Date().addingTimeInterval(120)
                )
            ]
            vm.environments = [
                EnvironmentSummary(
                    id: "1",
                    name: "production",
                    status: .active,
                    url: "https://app.example.com",
                    lastDeployed: Date().addingTimeInterval(-3_600),
                    resourceCount: 5
                ),
                EnvironmentSummary(
                    id: "2",
                    name: "staging",
                    status: .active,
                    url: "https://staging.example.com",
                    lastDeployed: Date().addingTimeInterval(-1_800),
                    resourceCount: 3
                )
            ]
            return vm
        }())
}
*/

/*
#Preview("Dashboard - Critical") {
    DashboardView()
        .environmentObject({
            let vm = DashboardViewModel()
            vm.overallHealth = .critical
            vm.lastUpdated = Date()
            vm.environments = []
            return vm
        }())
}
*/
