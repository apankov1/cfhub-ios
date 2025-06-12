//
// CFHubCoreTests.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//

import Testing
@testable import CFHubCore

@Test("Resource can be created with basic properties")
func testResourceCreation() async throws {
    let resource = Resource(
        id: "test-id",
        type: .cloudflarePages,
        name: "test-resource",
        status: .active,
        configuration: ResourceConfiguration()
    )
    
    #expect(resource.id == "test-id")
    #expect(resource.type == .cloudflarePages)
    #expect(resource.status == .active)
}

@Test("Action can be created with correct properties")
func testActionCreation() async throws {
    let action = Action(
        type: .create,
        resourceId: "resource-123",
        resourceType: .githubRepository,
        operation: .createResource(configuration: ResourceConfiguration())
    )
    
    #expect(action.type == .create)
    #expect(action.resourceId == "resource-123")
    #expect(action.resourceType == .githubRepository)
}

@Test("Integration registry manages integrations")
func testIntegrationRegistry() async throws {
    let registry = IntegrationRegistry.shared
    let integrations = await registry.getRegisteredIntegrations()
    
    // Initially empty
    #expect(integrations.isEmpty)
}