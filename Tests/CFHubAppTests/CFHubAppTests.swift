//
// CFHubAppTests.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//

@testable import CFHubApp
import Testing

@Test("App initializes successfully")
func testAppInitialization() async throws {
    let appState = AppState()
    #expect(!appState.isInitialized)

    await appState.initialize()
    #expect(appState.isInitialized)
}

@Test("Dashboard view model starts in correct state")
func testDashboardViewModelInitialState() async throws {
    let viewModel = DashboardViewModel()

    #expect(viewModel.infrastructureStatus == nil)
    #expect(!viewModel.isLoading)
    #expect(!viewModel.isRefreshing)
    #expect(viewModel.error == nil)
    #expect(viewModel.overallHealth == .unknown)
}
