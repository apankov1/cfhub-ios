//
// CFHubApp.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//

import CFHubCore
import SwiftUI

/// Main CFHub iOS application following cloud-native patterns
///
/// This app demonstrates the cloudflare-hub principles adapted for iOS:
/// - Ephemeral environments via mobile deployment triggers
/// - Real-time infrastructure monitoring
/// - Emergency response capabilities
/// - Team collaboration on infrastructure changes
#if !TESTING
@main
#endif
struct CFHubApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var dashboardViewModel = DashboardViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(authViewModel)
                .environmentObject(dashboardViewModel)
                .task {
                    await setupApplication()
                }
        }
    }

    private func setupApplication() async {
        // Register available integrations
        await registerDefaultIntegrations()

        // Initialize app state
        await appState.initialize()

        // Restore authentication if available
        await authViewModel.restoreAuthentication()
    }
}

/// Main content view with authentication routing
struct ContentView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var dashboardViewModel: DashboardViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .onChange(of: authViewModel.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                Task {
                    await appState.activateIntegrations(with: authViewModel.credentials)
                }
            } else {
                Task {
                    await appState.deactivateIntegrations()
                    dashboardViewModel.stopRealTimeUpdates()
                }
            }
        }
    }
}

/// Main tab-based navigation
struct MainTabView: View {
    @EnvironmentObject private var dashboardViewModel: DashboardViewModel
    @State private var selectedTab: Tab = .dashboard

    enum Tab: String, CaseIterable {
        case dashboard = "Dashboard"
        case deployments = "Deployments"
        case environments = "Environments"
        case settings = "Settings"

        var iconName: String {
            switch self {
            case .dashboard:
                return "chart.bar.fill"
            case .deployments:
                return "cloud.fill"
            case .environments:
                return "server.rack"
            case .settings:
                return "gear"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label(Tab.dashboard.rawValue, systemImage: Tab.dashboard.iconName)
                }
                .tag(Tab.dashboard)

            DeploymentsView()
                .tabItem {
                    Label(Tab.deployments.rawValue, systemImage: Tab.deployments.iconName)
                }
                .tag(Tab.deployments)

            EnvironmentsView()
                .tabItem {
                    Label(Tab.environments.rawValue, systemImage: Tab.environments.iconName)
                }
                .tag(Tab.environments)

            SettingsView()
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.iconName)
                }
                .tag(Tab.settings)
        }
        .tint(.blue)
        .task {
            // Start real-time updates when main view appears
            await dashboardViewModel.startRealTimeUpdates()
        }
        .onDisappear {
            // Stop real-time updates when view disappears
            dashboardViewModel.stopRealTimeUpdates()
        }
    }
}

/// Global application state management
@MainActor
class AppState: ObservableObject {
    @Published var isInitialized = false
    @Published var integrationStatus: [String: HealthStatus] = [:]
    @Published var lastHealthCheck: Date?

    private let integrationRegistry = IntegrationRegistry.shared
    private var healthCheckTimer: Timer?

    func initialize() async {
        // Setup integration registry and perform initial health checks
        await performHealthCheck()
        startHealthCheckTimer()
        isInitialized = true
    }

    func cleanup() {
        stopHealthCheckTimer()
    }

    func activateIntegrations(with credentials: AuthCredentials) async {
        // Activate integrations based on available credentials
        for (provider, credential) in credentials.providers {
            do {
                let configuration = IntegrationConfiguration(
                    baseURL: credential.baseURL,
                    authentication: credential.authentication,
                    timeout: 30.0,
                    retryPolicy: .default
                )

                _ = try await integrationRegistry.activateIntegration(
                    identifier: provider,
                    configuration: configuration
                )
            } catch {
                print("Failed to activate \(provider) integration: \(error)")
            }
        }

        await performHealthCheck()
    }

    func deactivateIntegrations() async {
        let activeIntegrations = await integrationRegistry.getActiveIntegrations()
        for identifier in activeIntegrations.keys {
            await integrationRegistry.deactivateIntegration(identifier: identifier)
        }
        integrationStatus.removeAll()
        stopHealthCheckTimer()
    }

    private func performHealthCheck() async {
        let results = await integrationRegistry.healthCheckAll()
        await MainActor.run {
            self.integrationStatus = results
            self.lastHealthCheck = Date()
        }
    }

    private func startHealthCheckTimer() {
        healthCheckTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            Task {
                await self.performHealthCheck()
            }
        }
    }

    func stopHealthCheckTimer() {
        healthCheckTimer?.invalidate()
        healthCheckTimer = nil
    }
}

/// Authentication credentials container
struct AuthCredentials: Sendable, Codable {
    let providers: [String: ProviderCredential]

    struct ProviderCredential: Sendable, Codable {
        let baseURL: String
        let authentication: Authentication
    }
}

// MARK: - Preview Support

/*
#Preview("Authenticated") {
    ContentView()
        .environmentObject(AppState())
        .environmentObject({
            let auth = AuthViewModel()
            auth.isAuthenticated = true
            return auth
        }())
        .environmentObject(DashboardViewModel())
}

#Preview("Unauthenticated") {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(AuthViewModel())
        .environmentObject(DashboardViewModel())
}
*/
