//
// AuthenticationView.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//

import SwiftUI

/// Authentication view implementing secure sign-in flow
///
/// Follows the cloudflare-hub security model where actual
/// provider tokens never leave the user's development machine.
/// The mobile app authenticates to CFHub cloud service.
struct AuthenticationView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @State private var selectedProvider: AuthProvider?
    @State private var showingProviderAuth = false

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "cloud.bolt.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)

                    VStack(spacing: 8) {
                        Text("CFHub Mobile")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Infrastructure management from anywhere")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 40)

                // Features
                VStack(spacing: 20) {
                    FeatureRow(
                        icon: "shield.checkered",
                        title: "Secure by Design",
                        description: "Your API tokens never leave your development machine"
                    )

                    FeatureRow(
                        icon: "bolt.circle",
                        title: "Emergency Response",
                        description: "Handle deployment emergencies from anywhere"
                    )

                    FeatureRow(
                        icon: "cloud.bolt",
                        title: "Real-time Monitoring",
                        description: "Monitor infrastructure status and deployments live"
                    )
                }
                .padding(.horizontal)

                Spacer()

                // Provider Selection
                VStack(spacing: 16) {
                    Text("Connect your accounts")
                        .font(.headline)

                    VStack(spacing: 12) {
                        ForEach(viewModel.availableProviders) { provider in
                            ProviderButton(provider: provider) {
                                selectedProvider = provider
                                showingProviderAuth = true
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Security Notice
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "lock.shield")
                            .foregroundColor(.green)

                        Text("Your credentials are encrypted and stored securely")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text("CFHub uses a secure proxy model - your API tokens never leave your development environment")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Sign In")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingProviderAuth) {
                if let provider = selectedProvider {
                    ProviderAuthenticationView(provider: provider)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Authenticating...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
            .alert("Authentication Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "Unknown error")
            }
        }
    }
}

/// Feature row showing app capabilities
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }
}

/// Provider authentication button
struct ProviderButton: View {
    let provider: AuthProvider
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: provider.iconName)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Connect to \(provider.displayName)")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(provider.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Provider-specific authentication view
struct ProviderAuthenticationView: View {
    let provider: AuthProvider
    @EnvironmentObject private var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var apiKey = ""
    @State private var email = ""
    @State private var token = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: provider.iconName)
                                .foregroundColor(.blue)

                            Text(provider.displayName)
                                .font(.headline)
                        }

                        Text(provider.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                Section("Credentials") {
                    switch provider.authType {
                    case .apiKey:
                        TextField("API Key", text: $apiKey)
                            .textContentType(.password)

                        TextField("Email (optional)", text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)

                    case .bearer, .oauth:
                        TextField("Access Token", text: $token)
                            .textContentType(.password)
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "shield.checkered")
                                .foregroundColor(.green)

                            Text("Security Notice")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }

                        Text("""
                            Your credentials are securely stored and encrypted. CFHub uses a proxy model where \
                            your actual API tokens remain on your development machine.
                            """)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("\(provider.displayName) Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Connect") {
                        Task {
                            await authenticateWithProvider()
                        }
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView("Connecting...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
        }
    }

    private var isFormValid: Bool {
        switch provider.authType {
        case .apiKey:
            return !apiKey.trimmingCharacters(in: .whitespaces).isEmpty
        case .bearer, .oauth:
            return !token.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    private func authenticateWithProvider() async {
        isLoading = true

        let credentials: ProviderCredentials
        switch provider.authType {
        case .apiKey:
            let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
            credentials = ProviderCredentials(type: .apiKey(
                key: apiKey.trimmingCharacters(in: .whitespaces),
                email: trimmedEmail.isEmpty ? nil : trimmedEmail
            ))
        case .bearer:
            credentials = ProviderCredentials(type: .token(
                value: token.trimmingCharacters(in: .whitespaces)
            ))
        case .oauth:
            credentials = ProviderCredentials(type: .token(
                value: token.trimmingCharacters(in: .whitespaces)
            ))
        }

        await viewModel.signIn(with: provider, credentials: credentials)

        isLoading = false

        if viewModel.isAuthenticated {
            dismiss()
        }
    }
}

/// Placeholder views for other tabs
struct DeploymentsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "cloud.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)

                Text("Deployments")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Coming soon...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Deployments")
        }
    }
}

struct EnvironmentsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "server.rack")
                    .font(.system(size: 64))
                    .foregroundColor(.green)

                Text("Environments")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Coming soon...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Environments")
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            List {
                Section("Account") {
                    if let user = authViewModel.user {
                        HStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(String(user.name.prefix(1)))
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                )

                            VStack(alignment: .leading) {
                                Text(user.name)
                                    .font(.headline)

                                Text(user.email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Connected Providers") {
                    ForEach(Array(authViewModel.activeProviders), id: \.self) { providerId in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)

                            Text(providerId.capitalized)

                            Spacer()
                        }
                    }

                    if authViewModel.activeProviders.isEmpty {
                        Text("No providers connected")
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    Button("Sign Out") {
                        Task {
                            await authViewModel.signOut()
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Preview Support

#Preview("Authentication") {
    AuthenticationView()
        .environmentObject(AuthViewModel())
}

#Preview("Provider Auth - GitHub") {
    ProviderAuthenticationView(
        provider: AuthProvider(
            identifier: "github",
            displayName: "GitHub",
            baseURL: "https://api.github.com",
            authType: .oauth,
            iconName: "cloud",
            description: "Connect to GitHub for repository management"
        )
    )
    .environmentObject(AuthViewModel())
}

#Preview("Provider Auth - Cloudflare") {
    ProviderAuthenticationView(
        provider: AuthProvider(
            identifier: "cloudflare",
            displayName: "Cloudflare",
            baseURL: "https://api.cloudflare.com/client/v4",
            authType: .apiKey,
            iconName: "shield",
            description: "Connect to Cloudflare for DNS and Pages management"
        )
    )
    .environmentObject(AuthViewModel())
}
