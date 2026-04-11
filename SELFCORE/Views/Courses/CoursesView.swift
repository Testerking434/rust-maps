// Views/Courses/CoursesView.swift
import SwiftUI

struct CoursesView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ZStack {
                Color.scBackground.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: SCSpacing.md) {
                        // Header stats
                        CourseStatsHeader(courses: appState.courses)

                        // Course list
                        ForEach(appState.courses) { course in
                            CourseCard(course: course)
                        }

                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, SCSpacing.md)
                }
            }
            .navigationTitle("Meine Kurse")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Stats Header
struct CourseStatsHeader: View {
    let courses: [Course]

    var totalCompleted: Int { courses.filter { $0.isCompleted }.count }
    var totalLessons: Int { courses.map { $0.completedLessons }.reduce(0, +) }
    var overallProgress: Double {
        let total = courses.map { $0.totalLessons }.reduce(0, +)
        guard total > 0 else { return 0 }
        return Double(totalLessons) / Double(total)
    }

    var body: some View {
        HStack(spacing: SCSpacing.md) {
            StatBubble(value: "\(Int(overallProgress * 100))%", label: "Gesamt")
            StatBubble(value: "\(totalLessons)", label: "Lektionen")
            StatBubble(value: "\(totalCompleted)/\(courses.count)", label: "Kurse")
        }
        .padding(SCSpacing.md)
        .scCard()
    }
}

struct StatBubble: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(SCFont.headline(20))
                .foregroundColor(.scGold)
            Text(label)
                .font(SCFont.caption(11))
                .foregroundColor(.scTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Course Card with Feature 8 (Unlock Animation)
struct CourseCard: View {
    let course: Course
    @State private var showUnlock = false
    @State private var previousCompleted: Int = 0
    @State private var appear = false

    var body: some View {
        VStack(alignment: .leading, spacing: SCSpacing.md) {
            HStack(spacing: SCSpacing.md) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(course.swiftColor.opacity(0.2))
                        .frame(width: 52, height: 52)
                    Image(systemName: course.icon)
                        .font(.system(size: 22))
                        .foregroundColor(course.swiftColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(course.title)
                            .font(SCFont.headline(16))
                            .foregroundColor(.white)
                        if !course.isUnlocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.scTextSecondary)
                        }
                    }
                    Text(course.subtitle)
                        .font(SCFont.body(13))
                        .foregroundColor(.scTextSecondary)
                }

                Spacer()

                if course.isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.scSuccess)
                }
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.scBorder).frame(height: 6)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [course.swiftColor, course.swiftColor.opacity(0.6)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .frame(width: appear ? geo.size.width * course.progress : 0, height: 6)
                            .animation(.easeInOut(duration: 0.8).delay(0.1), value: appear)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("\(course.completedLessons) / \(course.totalLessons) Lektionen")
                        .font(SCFont.caption(12))
                        .foregroundColor(.scTextSecondary)
                    Spacer()
                    Text("\(course.progressPercent)%")
                        .font(SCFont.mono(13))
                        .foregroundColor(course.swiftColor)
                }
            }

            // Milestone indicators — Feature 8
            HStack(spacing: 6) {
                ForEach(course.milestones, id: \.self) { m in
                    let reached = course.completedLessons >= m
                    HStack(spacing: 3) {
                        Image(systemName: reached ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 10))
                            .foregroundColor(reached ? course.swiftColor : .scBorder)
                        Text("\(m)")
                            .font(SCFont.caption(10))
                            .foregroundColor(reached ? course.swiftColor : .scTextSecondary.opacity(0.5))
                    }
                }
            }

            // Action button
            if course.isUnlocked {
                Button(action: {}) {
                    Text(course.completedLessons == 0 ? "Kurs starten" : "Weiter lernen")
                        .font(SCFont.subheadline(14))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(course.swiftColor.opacity(0.2))
                        .cornerRadius(SCRadius.sm)
                }
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.scTextSecondary)
                    Text("Freischaltbar auf genselfcore.de")
                        .font(SCFont.caption(13))
                        .foregroundColor(.scTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.scCardElevated)
                .cornerRadius(SCRadius.sm)
            }
        }
        .padding(SCSpacing.md)
        .scCard()
        .onAppear { appear = true }
        // Feature 8: Detect milestone changes
        .onChange(of: course.completedLessons) { newValue in
            if let milestone = course.reachedMilestone(from: previousCompleted, to: newValue) {
                showUnlock = true
                _ = milestone
            }
            previousCompleted = newValue
        }
        .overlay(
            Group {
                if showUnlock {
                    CourseUnlockAnimation(courseName: course.title) {
                        showUnlock = false
                    }
                }
            }
        )
        .onAppear { previousCompleted = course.completedLessons }
    }
}
