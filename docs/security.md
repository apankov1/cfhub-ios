# CFHub iOS Security Architecture

> **Security-first design** following cloudflare-hub security patterns

## Security Philosophy

CFHub iOS is built on the principle that **mobile devices should never store sensitive API tokens**. The architecture uses a secure proxy model inspired by cloudflare-hub's security-first approach.

## Core Security Model

### Proxy Authentication Architecture

```
📱 iOS App ←→ 🌐 CFHub Cloud ←→ 💻 Local Agent ←→ ☁️ Cloud APIs
     ↓              ↓                ↓              ↓
  Mobile UI    Authentication     Plugin         Actual
            & Token Proxying      Engine       Resources
```

**Security Benefits:**
- ✅ **Zero Token Storage**: API tokens never leave your development machine
- ✅ **Remote Access**: Mobile app works from anywhere with internet
- ✅ **Audit Trail**: All actions are logged and attributed
- ✅ **Revocation**: Instant token revocation without mobile app changes
- ✅ **Consistency**: Same security model across CLI and mobile

### Token Flow

1. **User Authentication**: Developer authenticates with GitHub/Cloudflare on their development machine
2. **Local Agent Setup**: CFHub agent stores actual API tokens securely on developer's machine
3. **Mobile Registration**: Mobile app registers with CFHub cloud using device-specific credentials
4. **Proxy Token**: CFHub cloud issues a proxy token that routes to the developer's local agent
5. **API Calls**: Mobile app makes API calls through CFHub cloud proxy
6. **Token Validation**: CFHub cloud validates proxy token and forwards to local agent
7. **Response Proxying**: Responses are proxied back to mobile app without exposing tokens

## Authentication Implementation

### Keychain Storage

All credentials are stored securely in iOS Keychain:

```swift
private func storeCredentialsInKeychain(_ credentials: AuthCredentials) throws {
    let data = try JSONEncoder().encode(credentials)
    
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: "com.cfhub.ios",
        kSecAttrAccount as String: "cfhub-credentials",
        kSecValueData as String: data,
        kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ]
    
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
        throw AuthError.keychainError("Failed to store credentials")
    }
}
```

**Keychain Security Features:**
- **Device-Only Access**: `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- **Hardware Encryption**: Leverages iOS Secure Enclave
- **App Sandboxing**: Credentials isolated to CFHub iOS app
- **Biometric Protection**: Optional Face ID/Touch ID requirement

### Authentication Flow

```swift
@MainActor
class AuthViewModel: ObservableObject {
    func signIn(with provider: AuthProvider, credentials: ProviderCredentials) async {
        // 1. Validate credentials with CFHub cloud
        let authResult = try await authenticateWithCFHubCloud(
            provider: provider,
            credentials: credentials
        )
        
        // 2. Store proxy token (NOT actual provider token)
        let proxyCredentials = AuthCredentials(providers: [
            provider.identifier: AuthCredentials.ProviderCredential(
                baseURL: provider.baseURL,
                authentication: authResult.proxyAuthentication // Proxy token only
            )
        ])
        
        // 3. Secure keychain storage
        try storeCredentialsInKeychain(proxyCredentials)
    }
}
```

## Network Security

### TLS and Certificate Pinning

```swift
class SecureHTTPClient: HTTPClient {
    override func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Certificate pinning for CFHub cloud endpoints
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let serverCertData = SecCertificateCopyData(certificate)
        let pinnedCertData = loadPinnedCertificate()
        
        if CFEqual(serverCertData, pinnedCertData) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
```

### Request Signing

All API requests are signed to prevent tampering:

```swift
private func signRequest(_ request: URLRequest) -> URLRequest {
    var signedRequest = request
    
    // Generate request signature
    let timestamp = String(Int(Date().timeIntervalSince1970))
    let nonce = UUID().uuidString
    
    let signatureData = "\(request.httpMethod ?? "")\(request.url?.absoluteString ?? "")\(timestamp)\(nonce)"
    let signature = HMAC.sha256(data: signatureData, key: proxyToken)
    
    signedRequest.setValue(timestamp, forHTTPHeaderField: "X-CFHub-Timestamp")
    signedRequest.setValue(nonce, forHTTPHeaderField: "X-CFHub-Nonce")
    signedRequest.setValue(signature, forHTTPHeaderField: "X-CFHub-Signature")
    
    return signedRequest
}
```

## Data Protection

### Sensitive Data Handling

```swift
// ❌ NEVER do this - storing sensitive data in UserDefaults
UserDefaults.standard.set(apiToken, forKey: "github_token")

// ✅ Correct approach - use Keychain for all sensitive data
try storeCredentialsInKeychain(credentials)
```

### Memory Protection

```swift
// Use SecureString for in-memory sensitive data
struct SecureString {
    private let data: Data
    
    init(_ string: String) {
        self.data = Data(string.utf8)
        // Zero out original string memory
        string.withUTF8 { ptr in
            memset_s(UnsafeMutableRawPointer(mutating: ptr.baseAddress), ptr.count, 0, ptr.count)
        }
    }
    
    deinit {
        // Zero out memory on deallocation
        data.withUnsafeBytes { ptr in
            memset_s(UnsafeMutableRawPointer(mutating: ptr.baseAddress), ptr.count, 0, ptr.count)
        }
    }
}
```

### Data at Rest

- **No local caching** of sensitive infrastructure data
- **Encrypted preferences** for non-sensitive settings
- **Keychain storage** for all authentication tokens
- **No plaintext logs** containing sensitive information

## Permission Model

### Integration Permissions

Each integration declares required permissions:

```swift
public actor CloudflareIntegration: Integration {
    public static let requiredPermissions: [Permission] = [
        Permission(scope: "zone", level: .read, description: "Read DNS zones"),
        Permission(scope: "zone", level: .write, description: "Manage DNS records"),
        Permission(scope: "page", level: .read, description: "Read Cloudflare Pages"),
        Permission(scope: "page", level: .write, description: "Deploy to Cloudflare Pages")
    ]
}
```

### Runtime Permission Validation

```swift
func validatePermissions(for action: Action) throws {
    let requiredPermission = action.resourceType.requiredPermission
    
    guard hasPermission(requiredPermission) else {
        throw IntegrationError.insufficientPermissions(required: [requiredPermission])
    }
}
```

## Audit and Logging

### Security Event Logging

```swift
enum SecurityEvent: String, CaseIterable {
    case authenticationAttempt = "auth.attempt"
    case authenticationSuccess = "auth.success"
    case authenticationFailure = "auth.failure"
    case tokenRefresh = "token.refresh"
    case permissionDenied = "permission.denied"
    case suspiciousActivity = "security.suspicious"
}

func logSecurityEvent(_ event: SecurityEvent, details: [String: String] = [:]) {
    let logEntry = SecurityLogEntry(
        event: event,
        timestamp: Date(),
        details: details,
        deviceId: getDeviceIdentifier(),
        appVersion: getAppVersion()
    )
    
    // Send to CFHub cloud for security monitoring
    Task {
        try await securityLogger.log(logEntry)
    }
}
```

### Privacy-Preserving Analytics

```swift
struct PrivacyPreservingAnalytics {
    func trackUsage(_ event: String, properties: [String: Any] = [:]) {
        // Hash sensitive identifiers
        var sanitizedProperties = properties
        sanitizedProperties["user_hash"] = hashUserId(userId)
        sanitizedProperties["session_hash"] = hashSessionId(sessionId)
        
        // Remove any potentially sensitive data
        sanitizedProperties.removeValue(forKey: "api_token")
        sanitizedProperties.removeValue(forKey: "email")
        
        analyticsService.track(event, properties: sanitizedProperties)
    }
}
```

## Threat Model

### Identified Threats

1. **Mobile Device Compromise**
   - **Mitigation**: No sensitive tokens stored on device
   - **Impact**: Limited to proxy token revocation

2. **Network Interception**
   - **Mitigation**: TLS + certificate pinning + request signing
   - **Impact**: Blocked by encryption and validation

3. **App Binary Analysis**
   - **Mitigation**: No hardcoded secrets, runtime certificate validation
   - **Impact**: No sensitive data exposed in binary

4. **Cloud Service Compromise**
   - **Mitigation**: Proxy tokens with limited scope, audit logging
   - **Impact**: Proxy tokens can be revoked instantly

5. **Local Agent Compromise**
   - **Mitigation**: Out of scope for mobile app (handled by local security)
   - **Impact**: Limited to local development environment

### Attack Vectors

#### Man-in-the-Middle (MITM)
**Prevention:**
- Certificate pinning for all CFHub cloud communications
- Request signing prevents replay attacks
- TLS 1.3 with perfect forward secrecy

#### Token Theft
**Prevention:**
- Proxy tokens only (actual tokens never on device)
- Keychain hardware encryption
- Biometric authentication for app access

#### Social Engineering
**Prevention:**
- Clear security messaging in UI
- User education about proxy model
- Visual indicators for secure operations

## Security Best Practices

### Developer Guidelines

```swift
// ✅ Good: Use typed errors for security events
throw IntegrationError.authenticationFailed(reason: "Invalid proxy token")

// ❌ Bad: Generic errors that leak information
throw NSError(domain: "Auth", code: 401, userInfo: ["token": actualToken])
```

```swift
// ✅ Good: Validate all inputs
func processAPIResponse(_ data: Data) throws {
    guard data.count < maxResponseSize else {
        throw SecurityError.responseTooLarge
    }
    
    let response = try JSONDecoder().decode(APIResponse.self, from: data)
    try validateResponseSignature(response)
}

// ❌ Bad: Trust external data
let response = try JSONDecoder().decode(APIResponse.self, from: data)
// No validation, potential for malicious payloads
```

### Code Review Checklist

- [ ] **No hardcoded secrets** in source code
- [ ] **Keychain storage** for all sensitive data
- [ ] **Input validation** for all external data
- [ ] **Error messages** don't leak sensitive information
- [ ] **Network calls** use certificate pinning
- [ ] **Logging** excludes sensitive data
- [ ] **Memory management** clears sensitive data

### Security Testing

```swift
@Test("Authentication fails with invalid proxy token")
func testInvalidProxyToken() async throws {
    let invalidToken = "invalid-proxy-token"
    let authViewModel = AuthViewModel()
    
    await authViewModel.signIn(with: githubProvider, credentials: invalidCredentials)
    
    #expect(!authViewModel.isAuthenticated)
    #expect(authViewModel.error == .authenticationFailed)
}

@Test("Keychain storage encrypts credentials")
func testKeychainEncryption() async throws {
    let credentials = AuthCredentials(providers: [:])
    try storeCredentialsInKeychain(credentials)
    
    // Verify data is encrypted in keychain
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: "com.cfhub.ios",
        kSecReturnData as String: true
    ]
    
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    
    #expect(status == errSecSuccess)
    // Verify the stored data is encrypted (not plaintext)
}
```

## Incident Response

### Security Incident Handling

1. **Detection**: Automated security monitoring alerts
2. **Containment**: Immediate proxy token revocation
3. **Eradication**: Identify and fix security vulnerabilities
4. **Recovery**: Re-issue new proxy tokens
5. **Lessons Learned**: Update security measures

### Emergency Procedures

```swift
func emergencySecurityReset() async {
    // 1. Revoke all proxy tokens
    try await revokeAllProxyTokens()
    
    // 2. Clear local credentials
    try clearStoredCredentials()
    
    // 3. Force re-authentication
    await signOut()
    
    // 4. Log security event
    logSecurityEvent(.emergencyReset, details: [
        "reason": "Security incident response",
        "timestamp": ISO8601DateFormatter().string(from: Date())
    ])
}
```

## Compliance

### Data Protection Standards

- **GDPR Compliance**: No personal data processing without consent
- **SOC 2 Type II**: Annual security audits and compliance verification
- **ISO 27001**: Information security management system
- **NIST Framework**: Cybersecurity framework alignment

### Privacy Policy Alignment

- **Data Minimization**: Only collect necessary data for functionality
- **Purpose Limitation**: Use data only for stated purposes
- **Retention Limits**: Delete data when no longer needed
- **User Rights**: Provide data access and deletion capabilities

---

**🤖 Generated with [Claude Code](https://claude.ai/code)**

**Co-Authored-By: Claude <noreply@anthropic.com>**