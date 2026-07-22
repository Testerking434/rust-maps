// Views/Courses/CourseUnlockAnimation.swift — Feature 8: Entsperr-Animationen
import SwiftUI

struct CourseUnlockAnimation: View {
    let courseName: String
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    @State private var ringScale: CGFloat = 1.0
    @State private var ringOpacity: Double = 0.8

    var body: some View {
        ZStack {
            // Blurred backdrop
            RoundedRectangle(cornerRadius: SCRadius.lg)
                .fill(Color.black.opacity(0.85))

            VStack(spacing: SCSpacing.md) {
                ZStack {
                    // Pulsing ring
                    Circle()
                        .stroke(Color.scGold.opacity(ringOpacity), lineWidth: 3)
                        .frame(width: 70 * ringScale, height: 70 * ringScale)
                        .animation(
                            .easeOut(duration: 1.0).repeatForever(autoreverses: false),
                            value: ringScale
                        )

                    // Main icon
                    ZStack {
                        Circle()
                            .fill(Color.scGold.opacity(0.2))
                            .frame(width: 64, height: 64)
                        Image(systemName: "star.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.scGold)
                    }
                }

                VStack(spacing: 6) {
                    Text("Meilenstein!")
                        .font(SCFont.headline(18))
                        .foregroundColor(.scGold)
                    Text(courseName)
                        .font(SCFont.subheadline(14))
                        .foregroundColor(.white)
                    Text("Du machst außergewöhnliche Fortschritte.")
                        .font(SCFont.body(13))
                        .foregroundColor(.scTextSecondary)
                        .multilineTextAlignment(.center)
                }

                ParticlesBurst()
                    .frame(height: 60)

                Button("Weiter") { onDismiss() }
                    .font(SCFont.subheadline(14))
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 10)
                    .background(Color.scGold)
                    .cornerRadius(SCRadius.md)
            }
            .padding(SCSpacing.lg)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: false)) {
                ringScale = 1.5
                ringOpacity = 0
            }
            // Auto dismiss after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                onDismiss()
            }
        }
    }
}
