// Services/ContentService.swift
// Lädt Kurse, Lektionen, Workbooks und Audio-URLs vom Server

import Foundation
import SwiftUI

// MARK: - Signed URL Response
struct SignedURLResponse: Decodable {
    var url: String          // Zeitbegrenzte, sichere URL
    var expiresAt: Date      // Ablaufzeit (z.B. 1 Stunde)
}

// MARK: - Lesson Complete Request
struct LessonCompleteRequest: Encodable {
    var lessonId: String
    var courseId: String
    var exerciseCompleted: Bool
    var notes: String?
    var completedAt: String

    init(progress: LessonProgress) {
        self.lessonId = progress.lessonId
        self.courseId = progress.courseId
        self.exerciseCompleted = progress.exerciseCompleted
        self.notes = progress.notes
        let f = ISO8601DateFormatter()
        self.completedAt = f.string(from: progress.completedAt)
    }
}

// MARK: - Content Service
actor ContentService {
    static let shared = ContentService()

    // MARK: - Courses
    func fetchCourseDetail(courseId: String) async throws -> CourseDetail {
        return try await APIService.shared.makeRequest(endpoint: "/courses/\(courseId)")
    }

    func fetchLessons(courseId: String) async throws -> [Lesson] {
        return try await APIService.shared.makeRequest(endpoint: "/courses/\(courseId)/lessons")
    }

    func fetchLesson(courseId: String, lessonId: String) async throws -> Lesson {
        return try await APIService.shared.makeRequest(endpoint: "/courses/\(courseId)/lessons/\(lessonId)")
    }

    // MARK: - Workbook PDF (signierte URL)
    func fetchWorkbookURL(lessonId: String) async throws -> String {
        let response: SignedURLResponse = try await APIService.shared.makeRequest(
            endpoint: "/content/workbook/\(lessonId)/signed-url"
        )
        return response.url
    }

    // MARK: - Audio (signierte URL für Subscriber)
    func fetchAudioURL(trackId: String) async throws -> String {
        let response: SignedURLResponse = try await APIService.shared.makeRequest(
            endpoint: "/content/audio/\(trackId)/signed-url"
        )
        return response.url
    }

    // MARK: - Lesson Progress
    func markLessonComplete(_ progress: LessonProgress) async throws {
        struct Empty: Decodable {}
        let body = LessonCompleteRequest(progress: progress)
        let _: Empty = try await APIService.shared.makeRequest(
            endpoint: "/courses/\(progress.courseId)/lessons/\(progress.lessonId)/complete",
            method: "POST",
            body: body
        )
    }

    // MARK: - Offline Cache
    private let cacheDir: URL = {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SELFCORE", isDirectory: true)
    }()

    func cacheLessons(_ lessons: [Lesson], courseId: String) {
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        let url = cacheDir.appendingPathComponent("lessons-\(courseId).json")
        if let data = try? JSONEncoder().encode(lessons) {
            try? data.write(to: url)
        }
    }

    func cachedLessons(courseId: String) -> [Lesson]? {
        let url = cacheDir.appendingPathComponent("lessons-\(courseId).json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([Lesson].self, from: data)
    }
}

// MARK: - APIService extension for Content
extension APIService {
    func makeRequest<T: Decodable>(
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
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            guard let result = try? decoder.decode(T.self, from: data) else {
                throw APIError.decodingError
            }
            return result
        case 401: throw APIError.unauthorized
        default:
            let msg = String(data: data, encoding: .utf8) ?? "Server-Fehler \(http.statusCode)"
            throw APIError.serverError(msg)
        }
    }
}
