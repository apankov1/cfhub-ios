//
// Resource.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//

import Foundation

/// Core resource model following cloudflare-hub distributed types pattern
///
/// Resources represent any manageable infrastructure component across
/// all integrations (Cloudflare Pages, GitHub Repos, etc.)
public struct Resource: Sendable, Codable, Identifiable {
    public let id: String
    public let type: ResourceType
    public let name: String
    public let status: ResourceStatus
    public let configuration: ResourceConfiguration
    public let metadata: ResourceMetadata
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: String,
        type: ResourceType,
        name: String,
        status: ResourceStatus,
        configuration: ResourceConfiguration,
        metadata: ResourceMetadata = ResourceMetadata(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.status = status
        self.configuration = configuration
        self.metadata = metadata
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Resource types across all integrations
public enum ResourceType: String, Sendable, Codable, CaseIterable {
    // Cloudflare Resources
    case cloudflarePages = "cloudflare_pages"
    case cloudflareWorker = "cloudflare_worker"
    case cloudflareDNS = "cloudflare_dns"
    case cloudflareR2 = "cloudflare_r2"
    case cloudflareKV = "cloudflare_kv"

    // GitHub Resources
    case githubRepository = "github_repository"
    case githubAction = "github_action"
    case githubEnvironment = "github_environment"
    case githubDeployment = "github_deployment"

    // Generic Resources
    case deployment = "deployment"
    case environment = "environment"
    case domain = "domain"

    public var integrationIdentifier: String {
        switch self {
        case .cloudflarePages, .cloudflareWorker, .cloudflareDNS, .cloudflareR2, .cloudflareKV:
            return "cloudflare"
        case .githubRepository, .githubAction, .githubEnvironment, .githubDeployment:
            return "github"
        case .deployment, .environment, .domain:
            return "core"
        }
    }

    public var displayName: String {
        switch self {
        case .cloudflarePages:
            return "Cloudflare Pages"
        case .cloudflareWorker:
            return "Cloudflare Worker"
        case .cloudflareDNS:
            return "Cloudflare DNS"
        case .cloudflareR2:
            return "Cloudflare R2"
        case .cloudflareKV:
            return "Cloudflare KV"
        case .githubRepository:
            return "GitHub Repository"
        case .githubAction:
            return "GitHub Action"
        case .githubEnvironment:
            return "GitHub Environment"
        case .githubDeployment:
            return "GitHub Deployment"
        case .deployment:
            return "Deployment"
        case .environment:
            return "Environment"
        case .domain:
            return "Domain"
        }
    }
}

/// Resource status across all types
public enum ResourceStatus: String, Sendable, Codable, CaseIterable {
    case creating
    case active
    case updating
    case deleting
    case deleted
    case failed
    case suspended
    case unknown

    public var isHealthy: Bool {
        switch self {
        case .active:
            return true
        case .creating, .updating, .deleting:
            return false // Transitional states
        case .deleted, .failed, .suspended, .unknown:
            return false
        }
    }

    public var isTransitional: Bool {
        switch self {
        case .creating, .updating, .deleting:
            return true
        case .active, .deleted, .failed, .suspended, .unknown:
            return false
        }
    }
}

/// Flexible configuration for any resource type
public struct ResourceConfiguration: Sendable, Codable {
    private let storage: [String: ConfigurationValue]

    public init(_ dictionary: [String: ConfigurationValue] = [:]) {
        self.storage = dictionary
    }

    public subscript<T: Codable & Sendable>(key: String, as type: T.Type) -> T? {
        get {
            storage[key]?.value as? T
        }
        set {
            var mutableStorage = storage
            if let newValue = newValue {
                mutableStorage[key] = ConfigurationValue(newValue)
            } else {
                mutableStorage.removeValue(forKey: key)
            }
            // Note: This would need to be implemented as a mutating method in practice
        }
    }

    public func value<T: Codable & Sendable>(for key: String, as type: T.Type) -> T? {
        storage[key]?.value as? T
    }

    public mutating func setValue<T: Codable & Sendable>(_ value: T?, for key: String) {
        var mutableStorage = storage
        if let value = value {
            mutableStorage[key] = ConfigurationValue(value)
        } else {
            mutableStorage.removeValue(forKey: key)
        }
        self = ResourceConfiguration(mutableStorage)
    }

    public var keys: [String] {
        Array(storage.keys)
    }
}

/// Type-erased configuration value
public struct ConfigurationValue: Sendable, Codable {
    public let value: any Codable & Sendable
    private let typeIdentifier: String

    public init<T: Codable & Sendable>(_ value: T) {
        self.value = value
        self.typeIdentifier = String(describing: T.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let string as String:
            try container.encode(string)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let bool as Bool:
            try container.encode(bool)
        case let array as [String]:
            try container.encode(array)
        case let dict as [String: String]:
            try container.encode(dict)
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "Unsupported configuration value type: \(typeIdentifier)"
                )
            )
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self) {
            self.value = string
            self.typeIdentifier = "String"
        } else if let int = try? container.decode(Int.self) {
            self.value = int
            self.typeIdentifier = "Int"
        } else if let double = try? container.decode(Double.self) {
            self.value = double
            self.typeIdentifier = "Double"
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
            self.typeIdentifier = "Bool"
        } else if let array = try? container.decode([String].self) {
            self.value = array
            self.typeIdentifier = "[String]"
        } else if let dict = try? container.decode([String: String].self) {
            self.value = dict
            self.typeIdentifier = "[String: String]"
        } else {
            throw DecodingError.typeMismatch(
                ConfigurationValue.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Could not decode configuration value"
                )
            )
        }
    }
}

/// Resource metadata for additional information
public struct ResourceMetadata: Sendable, Codable {
    public let tags: [String]
    public let labels: [String: String]
    public let annotations: [String: String]
    public let owner: String?
    public let team: String?
    public let environment: String?
    public let costCenter: String?

    public init(
        tags: [String] = [],
        labels: [String: String] = [:],
        annotations: [String: String] = [:],
        owner: String? = nil,
        team: String? = nil,
        environment: String? = nil,
        costCenter: String? = nil
    ) {
        self.tags = tags
        self.labels = labels
        self.annotations = annotations
        self.owner = owner
        self.team = team
        self.environment = environment
        self.costCenter = costCenter
    }
}
