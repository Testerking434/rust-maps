// Services/APIService.swift
import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case unauthorized
    case networkError
    case conflict(String)    // 409 – e.g. email already registered

    var errorDescription: String? {
        switch self {
        case .invalidURL:         return "Ungültige URL."
        case .noData:             return "Keine Daten erhalten."
        case .decodingError:      return "Daten konnten nicht gelesen werden."
        case .serverError(let m): return m
        case .unauthorized:       return "Bitte melde dich erneut an."
        case .networkError:       return "Keine Verbindung. Überprüfe dein Internet."
        case .conflict(let m):    return m
        }
    }
}

struct APIConfig {
    static let baseURL = "https://api.genselfcore.de/v1"
    static var token: String? {
        get { UserDefaults.standard.string(forKey: "authToken") }
        set { UserDefaults.standard.set(newValue, forKey: "authToken") }
    }
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let token: String
    let user: UserProfile
    var signalFreeDays: Int = 0
}

struct RegisterRequest: Encodable {
    let name: String
    let email: String
    let password: String
    let referralCode: String?
}

struct CheckInRequest: Encodable {
    let mood: String
    let actionCompleted: Bool
    let note: String?
    let date: String

    init(checkIn: CheckIn) {
        self.mood = checkIn.mood.rawValue
        self.actionCompleted = checkIn.actionCompleted
        self.note = checkIn.note
        let f = ISO8601DateFormatter()
        self.date = f.string(from: checkIn.date)
    }
}

actor APIService {
    static let shared = APIService()

    // MARK: - Core request builder

    func makeRequest<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        requiresAuth: Bool = true,
        idempotencyKey: String? = nil
    ) async throws -> T {
        guard let url = URL(string: APIConfig.baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth {
            guard let token = APIConfig.token else { throw APIError.unauthorized }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Idempotency header prevents duplicate processing on server
        if let key = idempotencyKey {
            request.setValue(key, forHTTPHeaderField: "Idempotency-Key")
        }

        if let body = body {
            request.httpBody = try? JSONEncoder().encode(body)
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw APIError.networkError
        }

        guard let http = response as? HTTPURLResponse else { throw APIError.networkError }

        switch http.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError
            }
        case 401:
            throw APIError.unauthorized
        case 409:
            let msg = String(data: data, encoding: .utf8) ?? "Diese E-Mail ist bereits registriert."
            throw APIError.conflict(msg)
        default:
            let msg = String(data: data, encoding: .utf8) ?? "Server-Fehler \(http.statusCode)"
            throw APIError.serverError(msg)
        }
    }

    // MARK: - Auth: Sign in with Apple

    func loginWithApple(identityToken: String, fullName: PersonNameComponents?, email: String?, referralCode: String?) async throws -> LoginResponse {
        let idempotencyKey = Self.registrationIdempotencyKey()

        struct AppleAuthRequest: Encodable {
            let identityToken: String
            let fullName: FullNamePayload?
            let email: String?
            let referralCode: String?
        }

        struct FullNamePayload: Encodable {
            let givenName: String?
            let familyName: String?
        }

        let namePayload = fullName.map { FullNamePayload(givenName: $0.givenName, familyName: $0.familyName) }
        let body = AppleAuthRequest(identityToken: identityToken, fullName: namePayload, email: email, referralCode: referralCode)

        let response: LoginResponse = try await makeRequest(
            endpoint: "/auth/apple",
            method: "POST",
            body: body,
            requiresAuth: false,
            idempotencyKey: idempotencyKey
        )

        Self.clearRegistrationIdempotencyKey()
        return response
    }

    // MARK: - Auth: Sign in with Google

    func loginWithGoogle(idToken: String, referralCode: String?) async throws -> LoginResponse {
        let idempotencyKey = Self.registrationIdempotencyKey()

        struct GoogleAuthRequest: Encodable {
            let idToken: String
            let referralCode: String?
        }

        let body = GoogleAuthRequest(idToken: idToken, referralCode: referralCode)
        let response: LoginResponse = try await makeRequest(
            endpoint: "/auth/google",
            method: "POST",
            body: body,
            requiresAuth: false,
            idempotencyKey: idempotencyKey
        )

        Self.clearRegistrationIdempotencyKey()
        return response
    }

    // MARK: - Auth: E-Mail (optional)

    func loginWithEmail(email: String, password: String) async throws -> LoginResponse {
        let body = LoginRequest(email: email, password: password)
        return try await makeRequest(endpoint: "/auth/email/login", method: "POST", body: body, requiresAuth: false)
    }

    func registerWithEmail(name: String, email: String, password: String, referralCode: String?) async throws -> LoginResponse {
        let idempotencyKey = Self.registrationIdempotencyKey()

        let body = RegisterRequest(name: name, email: email, password: password, referralCode: referralCode)
        let response: LoginResponse = try await makeRequest(
            endpoint: "/auth/email/register",
            method: "POST",
            body: body,
            requiresAuth: false,
            idempotencyKey: idempotencyKey
        )

        Self.clearRegistrationIdempotencyKey()
        return response
    }

    func logout() async throws {
        struct Empty: Decodable {}
        let _: Empty = try await makeRequest(endpoint: "/auth/logout", method: "POST")
        APIConfig.token = nil
    }

    func deleteAccount() async throws {
        struct MessageResponse: Decodable { let message: String }
        let _: MessageResponse = try await makeRequest(endpoint: "/auth/account", method: "DELETE")
        APIConfig.token = nil
    }

    // MARK: - User

    func fetchProfile() async throws -> UserProfile {
        return try await makeRequest(endpoint: "/user/profile")
    }

    func fetchCourses() async throws -> [Course] {
        return try await makeRequest(endpoint: "/user/courses")
    }

    // MARK: - CheckIns

    func postCheckIn(_ checkIn: CheckIn) async throws {
        struct Empty: Decodable {}
        let body = CheckInRequest(checkIn: checkIn)
        let _: Empty = try await makeRequest(endpoint: "/checkins", method: "POST", body: body)
    }

    // MARK: - Weekly Review

    func fetchWeeklyStats() async throws -> WeeklyStats {
        return try await makeRequest(endpoint: "/user/weekly-stats")
    }

    // MARK: - Idempotency key helpers (nonisolated, keyed on UserDefaults)

    private static let registrationKeyUD = "registrationIdempotencyKey"

    nonisolated static func registrationIdempotencyKey() -> String {
        if let existing = UserDefaults.standard.string(forKey: registrationKeyUD) {
            return existing
        }
        let fresh = UUID().uuidString
        UserDefaults.standard.set(fresh, forKey: registrationKeyUD)
        return fresh
    }

    nonisolated static func clearRegistrationIdempotencyKey() {
        UserDefaults.standard.removeObject(forKey: registrationKeyUD)
    }
}

// MARK: - WeeklyStats model

struct WeeklyStats: Codable {
    var checkInsCount: Int
    var actionsCompleted: Int
    var dominantMood: String?
    var dimensionChanges: [String: Double]

    static let mock = WeeklyStats(
        checkInsCount: 5,
        actionsCompleted: 3,
        dominantMood: "focused",
        dimensionChanges: ["mut": 0.3, "klarheit": 0.5]
    )
}
