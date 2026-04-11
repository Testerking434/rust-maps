// Views/Home/HomeView.swift
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var streakService: StreakService
    @Binding var selectedTab: Int
    @State private var isRefreshing = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.scBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: SCSpacing.md) {
                        // Header
                        headerView

                        if appState.isLoadingProfile {
                            loadingView
                        } else {
                            // Feature 2: Streak Banner
                            StreakBannerView()
                                .environmentObject(streakService)

                            // Feature 1: Daily Energy Card
                            if let profile = appState.profile {
                                DailyEnergyCard(profile: profile) {
                                    selectedTab = 3
                                }
                            }

                            // Check-In Card
                            CheckInCard()

                            // Feature 6: Daily Quote
                            if let profile = appState.profile {
                                DailyQuoteCard(profile: profile)
                            }

                            // Daily Action Card
                            DailyActionCard()

                            // Course Progress Teaser
                            Button {
                                selectedTab = 2
                            } label: {
                                CourseProgressTeaser()
                            }
                            .buttonStyle(.plain)

                            // Profile Teaser
                            Button {
                                selectedTab = 1
                            } label: {
                                ProfileTeaser()
                            }
                            .buttonStyle(.plain)

                            // Bottom padding
                            Color.clear.frame(height: 40)
                        }
                    }
                    .padding(.horizontal, SCSpacing.md)
                }
                .refreshable {
                    await appState.refreshData()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }

    var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(SCFont.body(14))
                    .foregroundColor(.scTextSecondary)
                Text(appState.profile?.firstName ?? "SELFCORE")
                    .font(SCFont.display(28))
                    .foregroundColor(.white)
            }
            Spacer()
            // Profile avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.scGold, Color.scGoldDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                Text(appState.profile?.firstName.prefix(1).uppercased() ?? "S")
                    .font(SCFont.headline(18))
                    .foregroundColor(.black)
            }
        }
        .padding(.top, 8)
    }

    var loadingView: some View {
        VStack(spacing: SCSpacing.lg) {
            ForEach(0..<3) { _ in
                RoundedRectangle(cornerRadius: SCRadius.lg)
                    .fill(Color.scCard)
                    .frame(height: 100)
                    .shimmer()
            }
        }
    }

    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Guten Morgen,"
        case 12..<17: return "Guten Tag,"
        case 17..<22: return "Guten Abend,"
        default:      return "Gute Nacht,"
        }
    }
}

// MARK: - CheckIn Card
struct CheckInCard: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var streakService: StreakService
    @State private var selectedMood: Mood? = nil
    @State private var appear = false

    var body: some View {
        VStack(alignment: .leading, spacing: SCSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.scGold)
                        Text("TÄGLICHER CHECK-IN")
                            .font(SCFont.caption(11))
                            .foregroundColor(.scTextSecondary)
                            .tracking(1.5)
                    }
                    Text("Wie fühlst du dich?")
                        .font(SCFont.headline(18))
                        .foregroundColor(.white)
                }
                Spacer()
                if appState.hasCheckedInToday {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.scSuccess)
                        Text("Erledigt")
                            .font(SCFont.caption(12))
                            .foregroundColor(.scSuccess)
                    }
                }
            }

            if appState.hasCheckedInToday, let checkIn = appState.todayCheckIn {
                // Already checked in
                HStack(spacing: 12) {
                    Text(checkIn.mood.emoji)
                        .font(.system(size: 32))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(checkIn.mood.label)
                            .font(SCFont.headline(16))
                            .foregroundColor(.white)
                        Text(checkIn.mood.message)
                            .font(SCFont.body(13))
                            .foregroundColor(.scTextSecondary)
                    }
                }
                .padding(SCSpacing.sm)
                .background(checkIn.mood.color.opacity(0.1))
                .cornerRadius(SCRadius.md)
            } else {
                // Mood buttons
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: SCSpacing.sm) {
                    ForEach(Mood.allCases, id: \.self) { mood in
                        Button {
                            selectedMood = mood
                            Task { await appState.submitCheckIn(mood: mood) }
                        } label: {
                            VStack(spacing: 4) {
                                Text(mood.emoji)
                                    .font(.system(size: 28))
                                Text(mood.label)
                                    .font(SCFont.caption(10))
                                    .foregroundColor(.scTextSecondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, SCSpacing.sm)
                            .background(
                                selectedMood == mood
                                    ? mood.color.opacity(0.2)
                                    : Color.scCardElevated
                            )
                            .cornerRadius(SCRadius.sm)
                            .overlay(
                                RoundedRectangle(cornerRadius: SCRadius.sm)
                                    .stroke(selectedMood == mood ? mood.color : Color.clear, lineWidth: 1.5)
                            )
                        }
                        .scaleEffect(selectedMood == mood ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3), value: selectedMood)
                    }
                }
            }
        }
        .padding(SCSpacing.md)
        .scCard()
        .offset(y: appear ? 0 : 20)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) { appear = true }
        }
    }
}

// MARK: - Daily Action Card
struct DailyActionCard: View {
    @EnvironmentObject var appState: AppState
    @State private var appear = false

    var action: MicroAction? {
        guard let profile = appState.profile else { return nil }
        return MicroActionsData.dailyAction(for: profile)
    }

    var body: some View {
        guard let action = action else { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: SCSpacing.md) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(action.dimension.color)
                        Text("MICRO-AKTION · \(action.dimension.displayName.uppercased())")
                            .font(SCFont.caption(11))
                            .foregroundColor(.scTextSecondary)
                            .tracking(1.0)
                    }
                    Spacer()
                    Text(action.duration)
                        .font(SCFont.caption(12))
                        .foregroundColor(.scTextSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.scCardElevated)
                        .cornerRadius(8)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(action.title)
                        .font(SCFont.headline(17))
                        .foregroundColor(.white)
                    Text(action.description)
                        .font(SCFont.body(14))
                        .foregroundColor(.scTextSecondary)
                        .lineSpacing(4)
                }

                if appState.todayCheckIn?.actionCompleted == true {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.scSuccess)
                        Text("Als erledigt markiert")
                            .font(SCFont.caption(13))
                            .foregroundColor(.scSuccess)
                    }
                } else {
                    Button("Als erledigt markieren") {
                        appState.markActionComplete()
                    }
                    .font(SCFont.subheadline(14))
                    .foregroundColor(action.dimension.color)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(action.dimension.color.opacity(0.1))
                    .cornerRadius(SCRadius.sm)
                }
            }
            .padding(SCSpacing.md)
            .scCard()
            .offset(y: appear ? 0 : 20)
            .opacity(appear ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5).delay(0.4)) { appear = true }
            }
        )
    }
}

// MARK: - Course Progress Teaser
struct CourseProgressTeaser: View {
    @EnvironmentObject var appState: AppState

    var firstCourse: Course { appState.courses.first ?? Course.allCourses[0] }

    var body: some View {
        HStack(spacing: SCSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(firstCourse.swiftColor.opacity(0.2))
                    .frame(width: 48, height: 48)
                Image(systemName: firstCourse.icon)
                    .font(.system(size: 20))
                    .foregroundColor(firstCourse.swiftColor)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(firstCourse.title)
                    .font(SCFont.headline(15))
                    .foregroundColor(.white)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.scBorder).frame(height: 5)
                        Capsule()
                            .fill(firstCourse.swiftColor)
                            .frame(width: geo.size.width * firstCourse.progress, height: 5)
                    }
                }
                .frame(height: 5)
                Text("\(firstCourse.progressPercent)% · \(firstCourse.completedLessons)/\(firstCourse.totalLessons) Lektionen")
                    .font(SCFont.caption(12))
                    .foregroundColor(.scTextSecondary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.scTextSecondary)
        }
        .padding(SCSpacing.md)
        .scCard()
    }
}

// MARK: - Profile Teaser
struct ProfileTeaser: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: SCSpacing.md) {
            if let profile = appState.profile {
                ZStack {
                    Circle()
                        .fill(profile.selfcoreType.color.opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: profile.selfcoreType.icon)
                        .font(.system(size: 20))
                        .foregroundColor(profile.selfcoreType.color)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.selfcoreType.displayName)
                        .font(SCFont.headline(15))
                        .foregroundColor(.white)
                    Text(profile.selfcoreType.tagline)
                        .font(SCFont.caption(13))
                        .foregroundColor(.scTextSecondary)
                        .lineLimit(1)
                }
            } else {
                Text("Profil laden...")
                    .font(SCFont.body(14))
                    .foregroundColor(.scTextSecondary)
                    .shimmer()
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.scTextSecondary)
        }
        .padding(SCSpacing.md)
        .scCard()
    }
}
