//
// Errors.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//

import Foundation

/// Comprehensive error system for CFHub integrations
/// 
/// Following Swift 6 error handling best practices with typed errors
/// and detailed context for debugging and user feedback.
public enum IntegrationError: Error, Sendable {
    // Authentication Errors
    case authenticationFailed(reason: String)
    case tokenExpired
    case insufficientPermissions(required: [Permission])
    case rateLimited(retryAfter: TimeInterval?)
    
    // Network Errors
    case networkUnavailable
    case requestTimeout(duration: TimeInterval)
    case serverError(statusCode: Int, message: String?)
    case invalidResponse(expected: String, received: String)
    
    // Resource Errors
    case resourceNotFound(id: String, type: ResourceType)
    case resourceAlreadyExists(id: String, type: ResourceType)
    case resourceInInvalidState(id: String, currentState: ResourceStatus, requiredState: ResourceStatus)
    case resourceLocked(id: String, lockHolder: String?)
    
    // Action Errors
    case actionNotSupported(action: ActionType, resourceType: ResourceType)
    case actionFailed(action: Action, underlyingError: String)
    case dependencyNotMet(actionId: String, missingDependency: String)
    case concurrentModification(resourceId: String)
    
    // Configuration Errors
    case invalidConfiguration(field: String, reason: String)
    case missingRequiredField(field: String)
    case configurationConflict(field1: String, field2: String, reason: String)
    
    // Validation Errors
    case validationFailed(errors: [ValidationError])
    case unsupportedOperation(operation: String, context: String)
    case quotaExceeded(resource: String, limit: Int, current: Int)
    
    // Integration-Specific Errors
    case cloudflareError(code: String, message: String)
    case githubError(code: String, message: String)
    
    // Generic Errors
    case unknown(message: String)
    case internalError(file: String, line: Int, function: String)
    
    public var localizedDescription: String {
        switch self {
        case .authenticationFailed(let reason):
            return "Authentication failed: \(reason)"
        case .tokenExpired:
            return "Authentication token has expired. Please sign in again."
        case .insufficientPermissions(let required):
            let permissions = required.map { "\($0.scope):\($0.level.rawValue)" }.joined(separator: ", ")
            return "Insufficient permissions. Required: \(permissions)"
        case .rateLimited(let retryAfter):
            if let retryAfter = retryAfter {
                return "Rate limited. Try again in \(Int(retryAfter)) seconds."
            } else {
                return "Rate limited. Please try again later."
            }
        case .networkUnavailable:
            return "Network unavailable. Check your internet connection."
        case .requestTimeout(let duration):
            return "Request timed out after \(duration) seconds."
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message ?? "Unknown error")"
        case .invalidResponse(let expected, let received):
            return "Invalid response. Expected \(expected), received \(received)."
        case .resourceNotFound(let id, let type):
            return "\(type.displayName) with ID '\(id)' not found."
        case .resourceAlreadyExists(let id, let type):
            return "\(type.displayName) with ID '\(id)' already exists."
        case .resourceInInvalidState(let id, let currentState, let requiredState):
            return "Resource '\(id)' is in state '\(currentState.rawValue)' but requires '\(requiredState.rawValue)'."
        case .resourceLocked(let id, let lockHolder):
            if let lockHolder = lockHolder {
                return "Resource '\(id)' is locked by '\(lockHolder)'."
            } else {
                return "Resource '\(id)' is locked."
            }
        case .actionNotSupported(let action, let resourceType):
            return "Action '\(action.rawValue)' is not supported for \(resourceType.displayName)."
        case .actionFailed(let action, let underlyingError):
            return "Action '\(action.operation.displayName)' failed: \(underlyingError)"
        case .dependencyNotMet(let actionId, let missingDependency):
            return "Action '\(actionId)' cannot proceed. Missing dependency: '\(missingDependency)'"
        case .concurrentModification(let resourceId):
            return "Resource '\(resourceId)' was modified by another process. Please retry."
        case .invalidConfiguration(let field, let reason):
            return "Invalid configuration for '\(field)': \(reason)"
        case .missingRequiredField(let field):
            return "Required field '\(field)' is missing."
        case .configurationConflict(let field1, let field2, let reason):
            return "Configuration conflict between '\(field1)' and '\(field2)': \(reason)"
        case .validationFailed(let errors):
            let errorMessages = errors.map(\.message).joined(separator: "; ")
            return "Validation failed: \(errorMessages)"
        case .unsupportedOperation(let operation, let context):
            return "Operation '\(operation)' is not supported in context '\(context)'."
        case .quotaExceeded(let resource, let limit, let current):
            return "Quota exceeded for '\(resource)'. Limit: \(limit), Current: \(current)."
        case .cloudflareError(let code, let message):
            return "Cloudflare API error (\(code)): \(message)"
        case .githubError(let code, let message):
            return "GitHub API error (\(code)): \(message)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        case .internalError(let file, let line, let function):
            return "Internal error in \(function) at \(file):\(line)"
        }
    }
    
    public var errorCode: String {
        switch self {
        case .authenticationFailed: return "AUTH_FAILED"
        case .tokenExpired: return "TOKEN_EXPIRED"
        case .insufficientPermissions: return "INSUFFICIENT_PERMISSIONS"
        case .rateLimited: return "RATE_LIMITED"
        case .networkUnavailable: return "NETWORK_UNAVAILABLE"
        case .requestTimeout: return "REQUEST_TIMEOUT"
        case .serverError: return "SERVER_ERROR"
        case .invalidResponse: return "INVALID_RESPONSE"
        case .resourceNotFound: return "RESOURCE_NOT_FOUND"
        case .resourceAlreadyExists: return "RESOURCE_ALREADY_EXISTS"
        case .resourceInInvalidState: return "RESOURCE_INVALID_STATE"
        case .resourceLocked: return "RESOURCE_LOCKED"
        case .actionNotSupported: return "ACTION_NOT_SUPPORTED"
        case .actionFailed: return "ACTION_FAILED"
        case .dependencyNotMet: return "DEPENDENCY_NOT_MET"
        case .concurrentModification: return "CONCURRENT_MODIFICATION"
        case .invalidConfiguration: return "INVALID_CONFIGURATION"
        case .missingRequiredField: return "MISSING_REQUIRED_FIELD"
        case .configurationConflict: return "CONFIGURATION_CONFLICT"
        case .validationFailed: return "VALIDATION_FAILED"
        case .unsupportedOperation: return "UNSUPPORTED_OPERATION"
        case .quotaExceeded: return "QUOTA_EXCEEDED"
        case .cloudflareError: return "CLOUDFLARE_ERROR"
        case .githubError: return "GITHUB_ERROR"
        case .unknown: return "UNKNOWN_ERROR"
        case .internalError: return "INTERNAL_ERROR"
        }
    }
    
    public var isRetryable: Bool {
        switch self {
        case .networkUnavailable, .requestTimeout, .serverError, .rateLimited:
            return true
        case .authenticationFailed, .tokenExpired, .insufficientPermissions:
            return false
        case .invalidResponse:
            return false
        case .resourceNotFound, .resourceAlreadyExists, .resourceInInvalidState, .resourceLocked:
            return false
        case .actionNotSupported, .actionFailed, .dependencyNotMet, .concurrentModification:
            return false
        case .invalidConfiguration, .missingRequiredField, .configurationConflict:
            return false
        case .validationFailed, .unsupportedOperation, .quotaExceeded:
            return false
        case .cloudflareError, .githubError:
            return false // Integration-specific errors should handle their own retry logic
        case .unknown, .internalError:
            return false
        }
    }
    
    public var severity: ErrorSeverity {
        switch self {
        case .authenticationFailed, .tokenExpired, .insufficientPermissions:
            return .high
        case .networkUnavailable, .requestTimeout:
            return .medium
        case .serverError, .invalidResponse:
            return .high
        case .resourceNotFound, .resourceAlreadyExists:
            return .medium
        case .resourceInInvalidState, .resourceLocked:
            return .medium
        case .actionNotSupported, .actionFailed:
            return .high
        case .dependencyNotMet, .concurrentModification:
            return .medium
        case .invalidConfiguration, .missingRequiredField, .configurationConflict:
            return .high
        case .validationFailed, .unsupportedOperation:
            return .medium
        case .quotaExceeded:
            return .high
        case .rateLimited:
            return .low
        case .cloudflareError, .githubError:
            return .medium
        case .unknown, .internalError:
            return .critical
        }
    }
}

/// Validation error details
public struct ValidationError: Sendable, Codable {
    public let field: String
    public let message: String
    public let code: String?
    
    public init(field: String, message: String, code: String? = nil) {
        self.field = field
        self.message = message
        self.code = code
    }
}

/// Error severity levels
public enum ErrorSeverity: String, Sendable, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    public var priority: Int {
        switch self {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        case .critical: return 4
        }
    }
}

// MARK: - Error Creation Helpers

extension IntegrationError {
    /// Create an authentication error with context
    public static func authFailure(
        reason: String,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> IntegrationError {
        return .authenticationFailed(reason: "\(reason) [\(function)]")
    }
    
    /// Create an internal error with file/line context
    public static func internalFailure(
        message: String = "Unexpected error occurred",
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> IntegrationError {
        return .internalError(file: file, line: line, function: function)
    }
    
    /// Create a resource error with type safety
    public static func resourceError(
        _ error: ResourceErrorType,
        id: String,
        type: ResourceType,
        context: String? = nil
    ) -> IntegrationError {
        switch error {
        case .notFound:
            return .resourceNotFound(id: id, type: type)
        case .alreadyExists:
            return .resourceAlreadyExists(id: id, type: type)
        case .invalidState(let current, let required):
            return .resourceInInvalidState(id: id, currentState: current, requiredState: required)
        case .locked(let holder):
            return .resourceLocked(id: id, lockHolder: holder)
        }
    }
}

/// Resource error types for type-safe error creation
public enum ResourceErrorType {
    case notFound
    case alreadyExists
    case invalidState(current: ResourceStatus, required: ResourceStatus)
    case locked(holder: String?)
}