// Views/Auth/LoginView.swift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showReset = false

    var body: some View {
        ZStack {
            Color.scBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: SCSpacing.xl) {
                    // Logo
                    VStack(spacing: SCSpacing.sm) {
                        Text("GEN:SELFCORE")
                            .font(SCFont.display(32))
                            .foregroundColor(.scGold)
                        Text("Dein täglicher Begleiter")
                            .font(SCFont.body(15))
                            .foregroundColor(.scTextSecondary)
                    }
                    .padding(.top, 80)

                    // Form
                    VStack(spacing: SCSpacing.md) {
                        VStack(alignment: .leading, spacing: SCSpacing.xs) {
                            Text("E-Mail")
                                .font(SCFont.caption(13))
                                .foregroundColor(.scTextSecondary)
                            TextField("deine@email.de", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .padding()
                                .background(Color.scCard)
                                .cornerRadius(SCRadius.md)
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: SCSpacing.xs) {
                            Text("Passwort")
                                .font(SCFont.caption(13))
                                .foregroundColor(.scTextSecondary)
                            SecureField("••••••••", text: $password)
                                .padding()
                                .background(Color.scCard)
                                .cornerRadius(SCRadius.md)
                                .foregroundColor(.white)
                        }

                        if let err = errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.scError)
                                Text(err)
                                    .font(SCFont.caption(13))
                                    .foregroundColor(.scError)
                            }
                            .padding(.horizontal)
                        }

                        Button(action: performLogin) {
                            HStack {
                                if isLoading {
                                    ProgressView().tint(.black)
                                } else {
                                    Text("Anmelden")
                                }
                            }
                        }
                        .buttonStyle(SCGoldButtonStyle())
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        .opacity((isLoading || email.isEmpty || password.isEmpty) ? 0.6 : 1)

                        Button("Passwort vergessen?") { showReset = true }
                            .font(SCFont.caption(14))
                            .foregroundColor(.scTextSecondary)
                    }
                    .padding(.horizontal, SCSpacing.lg)

                    Spacer()

                    // Legal note
                    Text("Mit der Anmeldung akzeptierst du unsere Nutzungsbedingungen und Datenschutzerklärung.")
                        .font(SCFont.caption(11))
                        .foregroundColor(.scTextSecondary.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, SCSpacing.xl)
                }
            }
        }
        .sheet(isPresented: $showReset) {
            PasswordResetSheet()
        }
    }

    func performLogin() {
        errorMessage = nil
        isLoading = true
        Task {
            do {
                try await appState.login(email: email, password: password)
            } catch let err as APIError {
                errorMessage = err.errorDescription
            } catch {
                errorMessage = "Anmeldung fehlgeschlagen. Versuche es erneut."
            }
            isLoading = false
        }
    }
}

struct PasswordResetSheet: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var isSent = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.scBackground.ignoresSafeArea()
            VStack(spacing: SCSpacing.lg) {
                Capsule()
                    .fill(Color.scBorder)
                    .frame(width: 40, height: 4)
                    .padding(.top)

                if isSent {
                    VStack(spacing: SCSpacing.md) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.scSuccess)
                        Text("E-Mail gesendet")
                            .font(SCFont.headline(22))
                            .foregroundColor(.white)
                        Text("Prüfe dein Postfach für den Reset-Link.")
                            .font(SCFont.body(15))
                            .foregroundColor(.scTextSecondary)
                            .multilineTextAlignment(.center)
                        Button("Fertig") { dismiss() }
                            .buttonStyle(SCGoldButtonStyle())
                            .padding(.horizontal, 40)
                    }
                } else {
                    VStack(alignment: .leading, spacing: SCSpacing.sm) {
                        Text("Passwort zurücksetzen")
                            .font(SCFont.headline(22))
                            .foregroundColor(.white)
                        Text("Gib deine E-Mail-Adresse ein.")
                            .font(SCFont.body(15))
                            .foregroundColor(.scTextSecondary)

                        TextField("deine@email.de", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.scCard)
                            .cornerRadius(SCRadius.md)
                            .foregroundColor(.white)

                        if let err = errorMessage {
                            Text(err).font(SCFont.caption(13)).foregroundColor(.scError)
                        }

                        Button(action: sendReset) {
                            HStack {
                                if isLoading { ProgressView().tint(.black) }
                                else { Text("Reset-E-Mail senden") }
                            }
                        }
                        .buttonStyle(SCGoldButtonStyle())
                        .disabled(isLoading || email.isEmpty)
                    }
                    .padding(.horizontal, SCSpacing.lg)
                }
                Spacer()
            }
        }
        .presentationDetents([.medium])
    }

    func sendReset() {
        isLoading = true
        Task {
            do {
                try await APIService.shared.resetPassword(email: email)
                isSent = true
            } catch let e as APIError {
                errorMessage = e.errorDescription
            } catch {
                errorMessage = "Fehler aufgetreten."
            }
            isLoading = false
        }
    }
}
