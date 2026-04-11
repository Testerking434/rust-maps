// Views/Signal/AudioPlayerView.swift — Background Audio + Feature 5 (Sleep Timer)
import SwiftUI
import AVFoundation

// MARK: - Audio Player Manager
@MainActor
class AudioPlayerManager: ObservableObject {
    static let shared = AudioPlayerManager()

    @Published var currentTrack: AudioTrack? = nil
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 1
    @Published var isLoading: Bool = false

    // Feature 5: Sleep Timer
    @Published var sleepTimerMinutes: Int = 0
    @Published var sleepTimerRemaining: Int = 0
    @Published var sleepTimerActive: Bool = false
    private var sleepTimerTask: Task<Void, Never>? = nil

    private var player: AVPlayer? = nil
    private var timeObserver: Any? = nil
    private var healthKit = HealthKitService.shared
    private var sessionStartTime: Date? = nil

    init() { setupAudioSession() }

    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession error: \(error)")
        }
    }

    func play(track: AudioTrack) {
        stop()
        currentTrack = track
        isLoading = true

        guard let url = URL(string: track.streamURL) else {
            isLoading = false
            return
        }

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player?.play()
        isPlaying = true
        isLoading = false
        sessionStartTime = Date()

        // Observe time
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self else { return }
            Task { @MainActor in
                self.currentTime = time.seconds
                if let dur = self.player?.currentItem?.duration.seconds, !dur.isNaN {
                    self.duration = dur
                }
            }
        }

        // Auto-stop at end
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { [weak self] _ in
            Task { @MainActor in
                self?.isPlaying = false
                self?.logHealthKitSession()
            }
        }
    }

    func togglePlayPause() {
        if isPlaying {
            player?.pause()
            logHealthKitSession()
        } else {
            player?.play()
            sessionStartTime = Date()
        }
        isPlaying.toggle()
    }

    func seek(to time: Double) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 600))
    }

    func skip(seconds: Double) {
        let newTime = max(0, min(currentTime + seconds, duration))
        seek(to: newTime)
    }

    func stop() {
        if let obs = timeObserver, let p = player {
            p.removeTimeObserver(obs)
        }
        logHealthKitSession()
        player?.pause()
        player = nil
        isPlaying = false
        currentTime = 0
        duration = 1
        currentTrack = nil
        cancelSleepTimer()
    }

    // MARK: - Feature 5: Sleep Timer
    func setSleepTimer(minutes: Int) {
        cancelSleepTimer()
        guard minutes > 0 else {
            sleepTimerActive = false
            sleepTimerMinutes = 0
            return
        }
        sleepTimerMinutes = minutes
        sleepTimerRemaining = minutes * 60
        sleepTimerActive = true

        sleepTimerTask = Task {
            while sleepTimerRemaining > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { break }
                await MainActor.run {
                    sleepTimerRemaining -= 1
                }
            }
            await MainActor.run {
                if sleepTimerActive {
                    // Fade out and stop
                    player?.volume = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.stop()
                    }
                    sleepTimerActive = false
                }
            }
        }
    }

    func cancelSleepTimer() {
        sleepTimerTask?.cancel()
        sleepTimerTask = nil
        sleepTimerActive = false
        sleepTimerRemaining = 0
        player?.volume = 1.0
    }

    var sleepTimerDisplay: String {
        guard sleepTimerActive else { return "" }
        let m = sleepTimerRemaining / 60
        let s = sleepTimerRemaining % 60
        return String(format: "%d:%02d", m, s)
    }

    // MARK: - HealthKit Feature 10
    private func logHealthKitSession() {
        guard let start = sessionStartTime, let track = currentTrack else { return }
        let duration = Date().timeIntervalSince(start)
        if duration > 30 {
            healthKit.logMindfulAudioSession(trackTitle: track.title, duration: duration)
        }
        sessionStartTime = nil
    }
}

// MARK: - Audio Track Row (for lists)
struct AudioTrackRow: View {
    let track: AudioTrack
    let isSubscribed: Bool
    let onTap: () -> Void

    @ObservedObject var playerManager = AudioPlayerManager.shared
    var isCurrentTrack: Bool { playerManager.currentTrack?.id == track.id }

    var body: some View {
        Button(action: {
            if isSubscribed { onTap() }
        }) {
            HStack(spacing: SCSpacing.md) {
                // Cover
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(track.swiftColor.opacity(0.3))
                        .frame(width: 48, height: 48)
                    if isCurrentTrack && playerManager.isPlaying {
                        WaveformIcon()
                    } else {
                        Image(systemName: isSubscribed ? "play.fill" : "lock.fill")
                            .font(.system(size: isSubscribed ? 16 : 13))
                            .foregroundColor(isSubscribed ? .white : .scTextSecondary)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(track.title)
                            .font(SCFont.subheadline(15))
                            .foregroundColor(isSubscribed ? .white : .scTextSecondary)
                        if !isSubscribed {
                            Text("PREMIUM")
                                .font(SCFont.caption(9))
                                .foregroundColor(.scGold)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.scGold.opacity(0.15))
                                .cornerRadius(4)
                        }
                    }
                    Text(track.frequency)
                        .font(SCFont.caption(12))
                        .foregroundColor(.scTextSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(track.duration)
                        .font(SCFont.caption(12))
                        .foregroundColor(.scTextSecondary)
                    if isCurrentTrack && playerManager.isPlaying {
                        Text("Spielt")
                            .font(SCFont.caption(10))
                            .foregroundColor(.scSignal)
                    }
                }
            }
            .padding(SCSpacing.sm)
            .background(isCurrentTrack ? track.swiftColor.opacity(0.1) : Color.clear)
            .cornerRadius(SCRadius.sm)
        }
    }
}

// MARK: - Waveform Animation
struct WaveformIcon: View {
    @State private var animate = false
    let bars = [0.5, 1.0, 0.7, 1.0, 0.4]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<bars.count, id: \.self) { i in
                Capsule()
                    .fill(Color.scSignal)
                    .frame(width: 3, height: CGFloat(12 * (animate ? bars[i] : 0.3)))
                    .animation(
                        .easeInOut(duration: 0.4 + Double(i) * 0.1).repeatForever(autoreverses: true),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}

// MARK: - Full Audio Player Sheet
struct FullAudioPlayerView: View {
    let track: AudioTrack
    @ObservedObject var playerManager = AudioPlayerManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showSleepTimer = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [track.swiftColor.opacity(0.3), Color.scBackground],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: SCSpacing.xl) {
                // Drag handle
                Capsule()
                    .fill(Color.scBorder)
                    .frame(width: 40, height: 4)
                    .padding(.top)

                Spacer()

                // Album art / Waveform
                ZStack {
                    RoundedRectangle(cornerRadius: SCRadius.xl)
                        .fill(track.swiftColor.opacity(0.2))
                        .frame(width: 220, height: 220)

                    if playerManager.isPlaying {
                        LargeWaveformAnimation(color: track.swiftColor)
                    } else {
                        Image(systemName: "waveform")
                            .font(.system(size: 70))
                            .foregroundColor(track.swiftColor.opacity(0.5))
                    }
                }

                // Track info
                VStack(spacing: 8) {
                    Text(track.title)
                        .font(SCFont.display(24))
                        .foregroundColor(.white)
                    Text(track.frequency)
                        .font(SCFont.body(15))
                        .foregroundColor(.scTextSecondary)
                    Text(track.description)
                        .font(SCFont.caption(13))
                        .foregroundColor(.scTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                // Feature 5: Sleep Timer badge
                if playerManager.sleepTimerActive {
                    HStack(spacing: 6) {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.scSignal)
                        Text("Sleep Timer: \(playerManager.sleepTimerDisplay)")
                            .font(SCFont.caption(13))
                            .foregroundColor(.scSignal)
                        Button("Abbrechen") { playerManager.cancelSleepTimer() }
                            .font(SCFont.caption(12))
                            .foregroundColor(.scError)
                    }
                    .padding(.horizontal, SCSpacing.md)
                    .padding(.vertical, 8)
                    .background(Color.scCard)
                    .cornerRadius(SCRadius.md)
                }

                // Progress slider
                VStack(spacing: 8) {
                    Slider(value: Binding(
                        get: { playerManager.currentTime },
                        set: { playerManager.seek(to: $0) }
                    ), in: 0...max(1, playerManager.duration))
                    .tint(track.swiftColor)

                    HStack {
                        Text(formatTime(playerManager.currentTime))
                            .font(SCFont.mono(12))
                            .foregroundColor(.scTextSecondary)
                        Spacer()
                        Text(formatTime(playerManager.duration))
                            .font(SCFont.mono(12))
                            .foregroundColor(.scTextSecondary)
                    }
                }
                .padding(.horizontal, SCSpacing.lg)

                // Controls
                HStack(spacing: SCSpacing.xl) {
                    Button { playerManager.skip(seconds: -15) } label: {
                        Image(systemName: "gobackward.15")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }

                    Button { playerManager.togglePlayPause() } label: {
                        ZStack {
                            Circle()
                                .fill(track.swiftColor)
                                .frame(width: 72, height: 72)
                            if playerManager.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                        }
                    }

                    Button { playerManager.skip(seconds: 15) } label: {
                        Image(systemName: "goforward.15")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                }

                // Bottom controls: Sleep Timer + Stop
                HStack(spacing: SCSpacing.xl) {
                    // Feature 5: Sleep Timer button
                    Button {
                        showSleepTimer = true
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "moon.zzz.fill")
                                .font(.system(size: 20))
                                .foregroundColor(playerManager.sleepTimerActive ? .scSignal : .scTextSecondary)
                            Text("Sleep Timer")
                                .font(SCFont.caption(10))
                                .foregroundColor(.scTextSecondary)
                        }
                    }

                    Button {
                        playerManager.stop()
                        dismiss()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "stop.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.scTextSecondary)
                            Text("Stopp")
                                .font(SCFont.caption(10))
                                .foregroundColor(.scTextSecondary)
                        }
                    }
                }
                .padding(.bottom, SCSpacing.xl)

                Spacer()
            }
        }
        .sheet(isPresented: $showSleepTimer) {
            SleepTimerView(playerManager: playerManager)
        }
    }

    func formatTime(_ secs: Double) -> String {
        guard !secs.isNaN, !secs.isInfinite else { return "0:00" }
        let total = Int(secs)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

// MARK: - Large Waveform Animation
struct LargeWaveformAnimation: View {
    let color: Color
    @State private var animate = false
    let barCount = 20
    let heights: [CGFloat] = [0.4, 0.7, 0.5, 1.0, 0.6, 0.9, 0.4, 0.8, 0.5, 0.7,
                              0.9, 0.4, 1.0, 0.6, 0.8, 0.5, 0.7, 0.3, 0.9, 0.6]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<barCount, id: \.self) { i in
                Capsule()
                    .fill(color.opacity(0.7))
                    .frame(width: 6, height: animate ? 80 * heights[i % heights.count] : 20)
                    .animation(
                        .easeInOut(duration: 0.5 + Double(i) * 0.07).repeatForever(autoreverses: true),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}
