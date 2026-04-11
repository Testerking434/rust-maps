// Services/APIService.swift
import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case unauthorized
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidURL:        return "Ungültige URL."
        case .noData:            return "Keine Daten erhalten."
        case .decodingError:     return "Daten konnten nicht gelesen werden."
        case .serverError(let m): return m
        case .unauthorized:      return "Bitte melde dich erneut an."
        case .networkError:      return "Keine Verbindung. Überprüfe dein Internet."
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

    private func makeRequest<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        requiresAuth: Bool = true
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
        default:
            let msg = String(data: data, encoding: .utf8) ?? "Server-Fehler \(http.statusCode)"
            throw APIError.serverError(msg)
        }
    }

    // MARK: - Auth
    func login(email: String, password: String) async throws -> LoginResponse {
        let body = LoginRequest(email: email, password: password)
        return try await makeRequest(endpoint: "/auth/login", method: "POST", body: body, requiresAuth: false)
    }

    func logout() async throws {
        struct Empty: Decodable {}
        let _: Empty = try await makeRequest(endpoint: "/auth/logout", method: "POST")
        APIConfig.token = nil
    }

    func resetPassword(email: String) async throws {
        struct Body: Encodable { let email: String }
        struct Empty: Decodable {}
        let _: Empty = try await makeRequest(endpoint: "/auth/reset-password", method: "POST", body: Body(email: email), requiresAuth: false)
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
}

// MARK: - WeeklyStats model
struct WeeklyStats: Codable {
    var checkInsCount: Int
    var actionsCompleted: Int
    var dominantMood: String?
    var dimensionChanges: [String: Double]

    // Fallback for offline/no-server
    static let mock = WeeklyStats(
        checkInsCount: 5,
        actionsCompleted: 3,
        dominantMood: "focused",
        dimensionChanges: ["mut": 0.3, "klarheit": 0.5]
    )
}
