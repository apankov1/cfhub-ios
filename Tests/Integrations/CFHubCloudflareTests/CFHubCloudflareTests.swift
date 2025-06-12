//
// CFHubCloudflareTests.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//

@testable import CFHubCloudflare
import CFHubCore
import Testing

@Test("Cloudflare integration has correct metadata")
func testCloudflareIntegrationMetadata() async throws {
    #expect(CloudflareIntegration.identifier == "cloudflare")
    #expect(CloudflareIntegration.displayName == "Cloudflare")
    #expect(CloudflareIntegration.version == "1.0.0")
    #expect(!CloudflareIntegration.requiredPermissions.isEmpty)
}

@Test("Cloudflare integration requires valid configuration")
func testCloudflareIntegrationRequiresAuth() async throws {
    let invalidConfig = IntegrationConfiguration(
        baseURL: "https://api.cloudflare.com/client/v4",
        authentication: .none
    )

    do {
        _ = try await CloudflareIntegration(configuration: invalidConfig)
        #expect(Bool(false), "Should throw authentication error")
    } catch {
        #expect(error is IntegrationError)
    }
}
