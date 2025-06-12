//
// CFHubGitHubTests.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//

import Testing
@testable import CFHubGitHub
import CFHubCore

@Test("GitHub integration has correct metadata")
func testGitHubIntegrationMetadata() async throws {
    #expect(GitHubIntegration.identifier == "github")
    #expect(GitHubIntegration.displayName == "GitHub")
    #expect(GitHubIntegration.version == "1.0.0")
    #expect(!GitHubIntegration.requiredPermissions.isEmpty)
}

@Test("GitHub integration requires valid configuration")
func testGitHubIntegrationRequiresAuth() async throws {
    let invalidConfig = IntegrationConfiguration(
        baseURL: "https://api.github.com",
        authentication: .none
    )
    
    do {
        _ = try await GitHubIntegration(configuration: invalidConfig)
        #expect(Bool(false), "Should throw authentication error")
    } catch {
        #expect(error is IntegrationError)
    }
}