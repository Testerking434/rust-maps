// Views/Courses/LessonListView.swift
import SwiftUI

struct LessonListView: View {
    let course: Course
    @EnvironmentObject var appState: AppState
    @State private var lessons: [Lesson] = []
    @State private var isLoading = true
    @State private var selectedLesson: Lesson? = nil

    var body: some View {
        ZStack {
            Color.scBackground.ignoresSafeArea()

            if isLoading {
                loadingView
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: SCSpacing.sm) {
                        // Course header
                        courseHeader

                        // Progress bar
                        courseProgressCard

                        // Lessons
                        ForEach(lessons) { lesson in
                            LessonRow(lesson: lesson, courseColor: course.swiftColor) {
                                if !lesson.isLocked {
                                    selectedLesson = lesson
                                }
                            }
                        }

                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, SCSpacing.md)
                }
            }
        }
        .navigationTitle(course.title)
        .navigationBarTitleDisplayMode(.large)
        .task { await loadLessons() }
        .sheet(item: $selectedLesson) { lesson in
            LessonDetailView(lesson: lesson, course: course) { completed in
                handleLessonCompleted(lesson: lesson)
            }
        }
    }

    var courseHeader: some View {
        HStack(spacing: SCSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(course.swiftColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                Image(systemName: course.icon)
                    .font(.system(size: 26))
                    .foregroundColor(course.swiftColor)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(SCFont.display(22))
                    .foregroundColor(.white)
                Text(course.subtitle)
                    .font(SCFont.body(14))
                    .foregroundColor(.scTextSecondary)
                Text(course.description)
                    .font(SCFont.caption(12))
                    .foregroundColor(.scTextSecondary)
                    .lineLimit(2)
            }
        }
        .padding(SCSpacing.md)
        .scCard()
    }

    var courseProgressCard: some View {
        VStack(spacing: SCSpacing.sm) {
            HStack {
                Text("\(completedCount) / \(lessons.count) Lektionen")
                    .font(SCFont.subheadline(15))
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(SCFont.mono(15))
                    .foregroundColor(course.swiftColor)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.scBorder).frame(height: 8)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [course.swiftColor, course.swiftColor.opacity(0.6)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 8)
                        .animation(.easeInOut(duration: 0.6), value: progress)
                }
            }
            .frame(height: 8)

            if let next = lessons.first(where: { !$0.isCompleted && !$0.isLocked }) {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 11))
                        .foregroundColor(course.swiftColor)
                    Text("Weiter: \(next.title)")
                        .font(SCFont.caption(13))
                        .foregroundColor(.scTextSecondary)
                }
            }
        }
        .padding(SCSpacing.md)
        .scCard()
    }

    var completedCount: Int { lessons.filter { $0.isCompleted }.count }
    var progress: Double {
        guard !lessons.isEmpty else { return 0 }
        return Double(completedCount) / Double(lessons.count)
    }

    var loadingView: some View {
        VStack(spacing: SCSpacing.md) {
            ForEach(0..<5) { _ in
                RoundedRectangle(cornerRadius: SCRadius.lg)
                    .fill(Color.scCard)
                    .frame(height: 80)
                    .shimmer()
            }
        }
        .padding(.horizontal, SCSpacing.md)
    }

    func loadLessons() async {
        isLoading = true
        // 1. Try server first
        if let fetched = try? await ContentService.shared.fetchLessons(courseId: course.id) {
            await ContentService.shared.cacheLessons(fetched, courseId: course.id)
            await MainActor.run { lessons = fetched; isLoading = false }
            return
        }
        // 2. Fall back to cache
        if let cached = await ContentService.shared.cachedLessons(courseId: course.id) {
            await MainActor.run { lessons = cached; isLoading = false }
            return
        }
        // 3. Use static preview data
        await MainActor.run {
            lessons = Lesson.previewLessons(for: course.id)
            isLoading = false
        }
    }

    func handleLessonCompleted(lesson: Lesson) {
        guard let idx = lessons.firstIndex(where: { $0.id == lesson.id }) else { return }
        lessons[idx].isCompleted = true
        // Unlock next lesson
        if idx + 1 < lessons.count {
            lessons[idx + 1].isLocked = false
        }
        let progress = LessonProgress(
            lessonId: lesson.id,
            courseId: course.id,
            completedAt: Date(),
            notes: nil,
            exerciseCompleted: false
        )
        Task { try? await ContentService.shared.markLessonComplete(progress) }
    }
}

// MARK: - Lesson Row
struct LessonRow: View {
    let lesson: Lesson
    let courseColor: Color
    let onTap: () -> Void
    @State private var appear = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: SCSpacing.md) {
                // Number / Status
                ZStack {
                    Circle()
                        .fill(statusBackground)
                        .frame(width: 40, height: 40)
                    if lesson.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    } else if lesson.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.scTextSecondary)
                    } else {
                        Text("\(lesson.order)")
                            .font(SCFont.mono(14))
                            .foregroundColor(lesson.isCompleted ? .white : courseColor)
                    }
                }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(SCFont.subheadline(15))
                        .foregroundColor(lesson.isLocked ? .scTextSecondary : .white)
                        .lineLimit(1)
                    HStack(spacing: 8) {
                        if let sub = lesson.subtitle {
                            Text(sub)
                                .font(SCFont.caption(12))
                                .foregroundColor(.scTextSecondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Label(lesson.readingTime, systemImage: "clock")
                            .font(SCFont.caption(11))
                            .foregroundColor(.scTextSecondary)
                        if lesson.workbookURL != nil {
                            Label("PDF", systemImage: "doc.fill")
                                .font(SCFont.caption(11))
                                .foregroundColor(.scGold.opacity(0.7))
                        }
                    }
                }
            }
            .padding(SCSpacing.sm)
            .padding(.horizontal, SCSpacing.xs)
            .scCard()
            .opacity(lesson.isLocked ? 0.55 : 1.0)
        }
        .disabled(lesson.isLocked)
        .offset(y: appear ? 0 : 10)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3).delay(Double(lesson.order) * 0.04)) {
                appear = true
            }
        }
    }

    var statusBackground: Color {
        if lesson.isCompleted { return courseColor }
        if lesson.isLocked    { return Color.scBorder }
        return courseColor.opacity(0.15)
    }
}
