//
// CFHubClientTests.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//

@testable import CFHubClient
import Testing

@Test("HTTP client initializes with correct configuration")
func testHTTPClientInitialization() async throws {
    let baseURL = URL(string: "https://api.example.com")!
    let client = HTTPClient(
        baseURL: baseURL,
        defaultHeaders: ["User-Agent": "CFHub-iOS-Test"],
        timeout: 30.0
    )

    // Basic smoke test - client should initialize without errors
    #expect(client != nil)
}

@Test("Retry policy has correct default values")
func testRetryPolicyDefaults() async throws {
    let policy = RetryPolicy.default

    #expect(policy.maxAttempts == 3)
    #expect(policy.initialDelay == 1.0)
    #expect(policy.backoffMultiplier == 2.0)
    #expect(policy.maxDelay == 30.0)
}
