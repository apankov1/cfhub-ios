//
// HTTPClient.swift
// CFHub iOS
//
// 🤖 Generated with [Claude Code](https://claude.ai/code)
// Co-Authored-By: Claude <noreply@anthropic.com>
//

import Foundation

/// Platform-agnostic HTTP client for CFHub integrations
///
/// This follows the cloudflare-hub pattern of having a shared client
/// that all integrations use, ensuring consistent behavior across
/// all service integrations.
public actor HTTPClient: Sendable {
    private let session: URLSession
    private let baseURL: URL
    private let defaultHeaders: [String: String]
    private let retryPolicy: RetryPolicy
    private let timeout: TimeInterval

    public init(
        baseURL: URL,
        defaultHeaders: [String: String] = [:],
        retryPolicy: RetryPolicy = .default,
        timeout: TimeInterval = 30.0,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
        self.retryPolicy = retryPolicy
        self.timeout = timeout
        self.session = session
    }

    /// Perform a GET request
    public func get<T: Codable & Sendable>(
        path: String,
        queryParameters: [String: String] = [:],
        headers: [String: String] = [:],
        responseType: T.Type
    ) async throws -> HTTPResponse<T> {
        let request = try buildRequest(
            method: .GET,
            path: path,
            queryParameters: queryParameters,
            headers: headers
        )

        return try await performRequest(request, responseType: responseType)
    }

    /// Perform a POST request
    public func post<T: Codable & Sendable, U: Codable & Sendable>(
        path: String,
        body: T,
        headers: [String: String] = [:],
        responseType: U.Type
    ) async throws -> HTTPResponse<U> {
        let request = try buildRequest(
            method: .POST,
            path: path,
            queryParameters: [:],
            headers: headers,
            body: body
        )

        return try await performRequest(request, responseType: responseType)
    }

    /// Perform a PUT request
    public func put<T: Codable & Sendable, U: Codable & Sendable>(
        path: String,
        body: T,
        headers: [String: String] = [:],
        responseType: U.Type
    ) async throws -> HTTPResponse<U> {
        let request = try buildRequest(
            method: .PUT,
            path: path,
            queryParameters: [:],
            headers: headers,
            body: body
        )

        return try await performRequest(request, responseType: responseType)
    }

    /// Perform a PATCH request
    public func patch<T: Codable & Sendable, U: Codable & Sendable>(
        path: String,
        body: T,
        headers: [String: String] = [:],
        responseType: U.Type
    ) async throws -> HTTPResponse<U> {
        let request = try buildRequest(
            method: .PATCH,
            path: path,
            queryParameters: [:],
            headers: headers,
            body: body
        )

        return try await performRequest(request, responseType: responseType)
    }

    /// Perform a DELETE request
    public func delete<T: Codable & Sendable>(
        path: String,
        headers: [String: String] = [:],
        responseType: T.Type
    ) async throws -> HTTPResponse<T> {
        let request = try buildRequest(
            method: .DELETE,
            path: path,
            queryParameters: [:],
            headers: headers
        )

        return try await performRequest(request, responseType: responseType)
    }

    // MARK: - Private Methods

    private func buildRequest(
        method: HTTPMethod,
        path: String,
        queryParameters: [String: String],
        headers: [String: String]
    ) throws -> URLRequest {
        return try buildRequest(
            method: method,
            path: path,
            queryParameters: queryParameters,
            headers: headers,
            body: Optional<String>.none
        )
    }

    private func buildRequest<T: Codable & Sendable>(
        method: HTTPMethod,
        path: String,
        queryParameters: [String: String],
        headers: [String: String],
        body: T?
    ) throws -> URLRequest {
        // Build URL with path and query parameters
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)

        if !queryParameters.isEmpty {
            urlComponents?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = urlComponents?.url else {
            throw HTTPClientError.invalidURL(path: path)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeout

        // Add default headers
        for (key, value) in defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Add request-specific headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Add Content-Type for requests with body
        if body != nil && request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        // Encode body if provided
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw HTTPClientError.encodingFailed(error: error)
            }
        }

        return request
    }

    private func performRequest<T: Codable & Sendable>(
        _ request: URLRequest,
        responseType: T.Type
    ) async throws -> HTTPResponse<T> {
        var lastError: Error?

        for attempt in 1...retryPolicy.maxAttempts {
            do {
                let (data, response) = try await session.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw HTTPClientError.invalidResponse
                }

                // Check for HTTP errors
                if !(200...299).contains(httpResponse.statusCode) {
                    throw HTTPClientError.httpError(
                        statusCode: httpResponse.statusCode,
                        data: data,
                        headers: httpResponse.allHeaderFields as? [String: String] ?? [:]
                    )
                }

                // Decode response body if not empty
                let body: T?
                if !data.isEmpty {
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        body = try decoder.decode(responseType, from: data)
                    } catch {
                        throw HTTPClientError.decodingFailed(error: error, data: data)
                    }
                } else {
                    body = nil
                }

                return HTTPResponse<T>(
                    data: data,
                    statusCode: httpResponse.statusCode,
                    headers: httpResponse.allHeaderFields as? [String: String] ?? [:],
                    body: body
                )

            } catch {
                lastError = error

                // Don't retry for certain errors
                if !shouldRetry(error: error, attempt: attempt) {
                    throw error
                }

                // Wait before retrying
                if attempt < retryPolicy.maxAttempts {
                    let delay = calculateRetryDelay(attempt: attempt)
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }

        throw lastError ?? HTTPClientError.maxRetriesExceeded
    }

    private func shouldRetry(error: Error, attempt: Int) -> Bool {
        guard attempt < retryPolicy.maxAttempts else { return false }

        switch error {
        case let httpError as HTTPClientError:
            switch httpError {
            case .httpError(let statusCode, _, _):
                // Retry on server errors and rate limiting
                return statusCode >= 500 || statusCode == 429
            case .networkError, .timeout:
                return true
            default:
                return false
            }
        case URLError.timedOut, URLError.networkConnectionLost, URLError.notConnectedToInternet:
            return true
        default:
            return false
        }
    }

    private func calculateRetryDelay(attempt: Int) -> TimeInterval {
        let delay = retryPolicy.initialDelay * pow(retryPolicy.backoffMultiplier, Double(attempt - 1))
        return min(delay, retryPolicy.maxDelay)
    }
}

/// HTTP method enumeration
public enum HTTPMethod: String, Sendable, CaseIterable {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
    case HEAD = "HEAD"
    case OPTIONS = "OPTIONS"
}

/// HTTP response wrapper
public struct HTTPResponse<T: Codable & Sendable>: Sendable {
    public let statusCode: Int
    public let headers: [String: String]
    public let data: Data
    public let body: T?

    public init(data: Data, statusCode: Int, headers: [String: String], body: T? = nil) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
    }

    public var isSuccessful: Bool {
        return (200...299).contains(statusCode)
    }

    public var isClientError: Bool {
        return (400...499).contains(statusCode)
    }

    public var isServerError: Bool {
        return (500...599).contains(statusCode)
    }
}

/// HTTP client specific errors
public enum HTTPClientError: Error, Sendable {
    case invalidURL(path: String)
    case encodingFailed(error: Error)
    case decodingFailed(error: Error, data: Data)
    case networkError(Error)
    case timeout
    case invalidResponse
    case httpError(statusCode: Int, data: Data, headers: [String: String])
    case maxRetriesExceeded

    public var localizedDescription: String {
        switch self {
        case .invalidURL(let path):
            return "Invalid URL for path: \(path)"
        case .encodingFailed(let error):
            return "Failed to encode request body: \(error.localizedDescription)"
        case .decodingFailed(let error, _):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .timeout:
            return "Request timed out"
        case .invalidResponse:
            return "Invalid response received"
        case .httpError(let statusCode, _, _):
            return "HTTP error: \(statusCode)"
        case .maxRetriesExceeded:
            return "Maximum retry attempts exceeded"
        }
    }
}

/// Retry policy for HTTP requests
public struct RetryPolicy: Sendable {
    public let maxAttempts: Int
    public let initialDelay: TimeInterval
    public let backoffMultiplier: Double
    public let maxDelay: TimeInterval

    public static let `default` = RetryPolicy(
        maxAttempts: 3,
        initialDelay: 1.0,
        backoffMultiplier: 2.0,
        maxDelay: 30.0
    )

    public static let aggressive = RetryPolicy(
        maxAttempts: 5,
        initialDelay: 0.5,
        backoffMultiplier: 1.5,
        maxDelay: 10.0
    )

    public static let conservative = RetryPolicy(
        maxAttempts: 2,
        initialDelay: 2.0,
        backoffMultiplier: 3.0,
        maxDelay: 60.0
    )

    public init(
        maxAttempts: Int,
        initialDelay: TimeInterval,
        backoffMultiplier: Double,
        maxDelay: TimeInterval
    ) {
        self.maxAttempts = maxAttempts
        self.initialDelay = initialDelay
        self.backoffMultiplier = backoffMultiplier
        self.maxDelay = maxDelay
    }
}
