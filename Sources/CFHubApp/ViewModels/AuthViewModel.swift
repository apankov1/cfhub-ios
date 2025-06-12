//
// AuthViewModel.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//

import CFHubCore
import Foundation
import Security
import SwiftUI

/// Authentication view model following security-first patterns
///
/// Implements the cloudflare-hub security model where tokens
/// never leave the user's development environment. The mobile
/// app authenticates to the CFHub cloud service which proxies
/// commands to the user's local agent.
@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: AuthError?
    @Published var user: User?

    // Authentication state
    @Published var availableProviders: [AuthProvider] = []
    @Published var activeProviders: Set<String> = []

    // MARK: - Internal Properties

    private(set) var credentials = AuthCredentials(providers: [:])

    // MARK: - Private Properties

    private let keychainService = "com.cfhub.ios"
    private let cfhubCloudURL = "https://api.cfhub.cloud"

    // MARK: - Initialization

    init() {
        setupAvailableProviders()
    }

    // MARK: - Public Methods

    /// Restore authentication from stored credentials
    func restoreAuthentication() async {
        isLoading = true
        error = nil

        do {
            // Try to restore from keychain
            if let storedCredentials = try loadCredentialsFromKeychain() {
                credentials = storedCredentials

                // Validate stored credentials
                let isValid = try await validateStoredCredentials()
                if isValid {
                    isAuthenticated = true
                    await fetchUserProfile()
                } else {
                    // Clear invalid credentials
                    try clearStoredCredentials()
                }
            }
        } catch {
            await handleError(.keychainError(error.localizedDescription))
        }

        isLoading = false
    }

    /// Sign in with a specific provider
    func signIn(with provider: AuthProvider, credentials: ProviderCredentials) async {
        isLoading = true
        error = nil

        do {
            // Authenticate with CFHub cloud service
            let authResult = try await authenticateWithCFHubCloud(
                provider: provider,
                credentials: credentials
            )

            // Store credentials securely
            let authCredentials = AuthCredentials(providers: [
                provider.identifier: AuthCredentials.ProviderCredential(
                    baseURL: provider.baseURL,
                    authentication: authResult.authentication
                )
            ])

            try storeCredentialsInKeychain(authCredentials)

            // Update state
            self.credentials = authCredentials
            self.user = authResult.user
            self.activeProviders.insert(provider.identifier)
            self.isAuthenticated = true
        } catch {
            await handleError(.authenticationFailed(error.localizedDescription))
        }

        isLoading = false
    }

    /// Add additional provider authentication
    func addProvider(_ provider: AuthProvider, credentials: ProviderCredentials) async {
        isLoading = true
        error = nil

        do {
            // Authenticate with additional provider
            let authResult = try await authenticateWithCFHubCloud(
                provider: provider,
                credentials: credentials
            )

            // Update existing credentials
            var updatedProviders = self.credentials.providers
            updatedProviders[provider.identifier] = AuthCredentials.ProviderCredential(
                baseURL: provider.baseURL,
                authentication: authResult.authentication
            )

            let updatedCredentials = AuthCredentials(providers: updatedProviders)
            try storeCredentialsInKeychain(updatedCredentials)

            // Update state
            self.credentials = updatedCredentials
            self.activeProviders.insert(provider.identifier)
        } catch {
            await handleError(.providerAddFailed(provider.displayName, error.localizedDescription))
        }

        isLoading = false
    }

    /// Remove provider authentication
    func removeProvider(_ providerId: String) async {
        var updatedProviders = credentials.providers
        updatedProviders.removeValue(forKey: providerId)

        let updatedCredentials = AuthCredentials(providers: updatedProviders)

        do {
            try storeCredentialsInKeychain(updatedCredentials)
            self.credentials = updatedCredentials
            self.activeProviders.remove(providerId)
        } catch {
            await handleError(.keychainError(error.localizedDescription))
        }
    }

    /// Sign out and clear all credentials
    func signOut() async {
        do {
            try clearStoredCredentials()

            // Reset state
            credentials = AuthCredentials(providers: [:])
            user = nil
            activeProviders.removeAll()
            isAuthenticated = false
            error = nil
        } catch {
            await handleError(.signOutFailed(error.localizedDescription))
        }
    }

    /// Refresh authentication tokens
    func refreshAuthentication() async {
        guard isAuthenticated else { return }

        isLoading = true

        do {
            let isValid = try await validateStoredCredentials()
            if !isValid {
                await signOut()
            }
        } catch {
            await handleError(.tokenRefreshFailed(error.localizedDescription))
        }

        isLoading = false
    }

    // MARK: - Private Methods

    private func setupAvailableProviders() {
        availableProviders = [
            AuthProvider(
                identifier: "github",
                displayName: "GitHub",
                baseURL: "https://api.github.com",
                authType: .oauth,
                iconName: "cloud",
                description: "Connect to GitHub for repository and deployment management"
            ),
            AuthProvider(
                identifier: "cloudflare",
                displayName: "Cloudflare",
                baseURL: "https://api.cloudflare.com/client/v4",
                authType: .apiKey,
                iconName: "shield",
                description: "Connect to Cloudflare for DNS, Pages, and Workers management"
            )
        ]
    }

    private func authenticateWithCFHubCloud(
        provider: AuthProvider,
        credentials: ProviderCredentials
    ) async throws -> AuthResult {
        // In a real implementation, this would:
        // 1. Send credentials to CFHub cloud service
        // 2. CFHub cloud would validate with the actual provider
        // 3. Return a CFHub token that proxies to the user's local agent
        // 4. Never store actual provider tokens on the mobile device

        // Mock implementation for now
        let mockUser = User(
            id: "user-123",
            email: "user@example.com",
            name: "Demo User",
            avatarURL: nil
        )

        let mockAuth: Authentication
        switch provider.authType {
        case .oauth:
            mockAuth = .oauth(accessToken: "cfhub-proxy-token-\(UUID().uuidString)", refreshToken: nil)
        case .apiKey:
            mockAuth = .bearer(token: "cfhub-proxy-token-\(UUID().uuidString)")
        case .bearer:
            mockAuth = .bearer(token: "cfhub-proxy-token-\(UUID().uuidString)")
        }

        return AuthResult(
            user: mockUser,
            authentication: mockAuth
        )
    }

    private func validateStoredCredentials() async throws -> Bool {
        // Validate credentials with CFHub cloud service
        // This would make a health check call to ensure tokens are still valid

        // Mock validation for now
        !credentials.providers.isEmpty
    }

    private func fetchUserProfile() async {
        // Fetch user profile from CFHub cloud service
        // Mock for now
        user = User(
            id: "user-123",
            email: "user@example.com",
            name: "Demo User",
            avatarURL: nil
        )
    }

    // MARK: - Keychain Operations

    private func storeCredentialsInKeychain(_ credentials: AuthCredentials) throws {
        let data = try JSONEncoder().encode(credentials)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: "cfhub-credentials",
            kSecValueData as String: data
        ]

        // Delete existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw AuthError.keychainError("Failed to store credentials: \(status)")
        }
    }

    private func loadCredentialsFromKeychain() throws -> AuthCredentials? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: "cfhub-credentials",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw AuthError.keychainError("Failed to load credentials: \(status)")
        }

        guard let data = result as? Data else {
            throw AuthError.keychainError("Invalid credentials data")
        }

        return try JSONDecoder().decode(AuthCredentials.self, from: data)
    }

    private func clearStoredCredentials() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: "cfhub-credentials"
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AuthError.keychainError("Failed to clear credentials: \(status)")
        }
    }

    private func handleError(_ error: AuthError) async {
        self.error = error
    }
}

// MARK: - Supporting Types

/// Authentication provider configuration
struct AuthProvider: Identifiable, Codable {
    let id = UUID()
    let identifier: String
    let displayName: String
    let baseURL: String
    let authType: AuthType
    let iconName: String
    let description: String

    enum AuthType: String, Codable {
        case oauth = "oauth"
        case apiKey = "api_key"
        case bearer = "bearer"
    }
}

/// Provider-specific credentials
struct ProviderCredentials {
    let type: CredentialType

    enum CredentialType {
        case oauth(clientId: String, clientSecret: String)
        case apiKey(key: String, email: String?)
        case token(value: String)
    }
}

/// Authentication result from CFHub cloud
struct AuthResult {
    let user: User
    let authentication: Authentication
}

/// User profile information
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    let avatarURL: String?
}

/// Authentication errors
enum AuthError: Error, LocalizedError {
    case authenticationFailed(String)
    case providerAddFailed(String, String)
    case tokenRefreshFailed(String)
    case signOutFailed(String)
    case keychainError(String)
    case networkError(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .authenticationFailed(let reason):
            return "Authentication failed: \(reason)"
        case let .providerAddFailed(provider, reason):
            return "Failed to add \(provider): \(reason)"
        case .tokenRefreshFailed(let reason):
            return "Token refresh failed: \(reason)"
        case .signOutFailed(let reason):
            return "Sign out failed: \(reason)"
        case .keychainError(let reason):
            return "Keychain error: \(reason)"
        case .networkError(let reason):
            return "Network error: \(reason)"
        case .unknown(let reason):
            return "Unknown error: \(reason)"
        }
    }
}

// MARK: - Codable Extensions

extension AuthCredentials: Codable {}
extension AuthCredentials.ProviderCredential: Codable {}
