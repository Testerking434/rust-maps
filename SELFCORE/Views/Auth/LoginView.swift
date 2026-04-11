// Views/Auth/LoginView.swift
import SwiftUI

// MARK: - Auth root (Login ↔ Register toggle)

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var showRegister = false

    var body: some View {
        ZStack {
            Color.scBackground.ignoresSafeArea()

            if showRegister {
                RegisterFormView(onSwitchToLogin: { showRegister = false })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal:   .move(edge: .leading)
                    ))
            } else {
                LoginFormView(onSwitchToRegister: { showRegister = true })
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading),
                        removal:   .move(edge: .trailing)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showRegister)
    }
}

// MARK: - Login form

private struct LoginFormView: View {
    @EnvironmentObject var appState: AppState
    var onSwitchToRegister: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showReset = false

    var body: some View {
        ScrollView {
            VStack(spacing: SCSpacing.xl) {
                brandHeader.padding(.top, 80)

                VStack(spacing: SCSpacing.md) {
                    SCTextField(label: "E-Mail", placeholder: "deine@email.de", text: $email)
                        .keyboardType(.emailAddress).autocapitalization(.none).autocorrectionDisabled()

                    SCSecureField(label: "Passwort", placeholder: "••••••••", text: $password)

                    if let err = errorMessage { errorBanner(err) }

                    Button(action: performLogin) {
                        Group {
                            if isLoading { ProgressView().tint(.black) }
                            else { Text("Anmelden") }
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

                dividerOr

                Button(action: onSwitchToRegister) {
                    Text("Noch kein Account? **Jetzt registrieren**")
                        .font(SCFont.body(15))
                        .foregroundColor(.scGold)
                }

                legalNote
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

// MARK: - Register form

private struct RegisterFormView: View {
    @EnvironmentObject var appState: AppState
    var onSwitchToLogin: () -> Void

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirm = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    /// Pre-filled from Universal Link / deep link (stored by SELFCOREApp on launch)
    @State private var referralCode: String = UserDefaults.standard.string(forKey: "pendingReferralCode") ?? ""
    @State private var showReferralField = false

    private var canSubmit: Bool {
        !name.isEmpty && !email.isEmpty && password.count >= 6 && password == passwordConfirm && !isLoading
    }

    var body: some View {
        ScrollView {
            VStack(spacing: SCSpacing.xl) {
                // Back button + header
                HStack {
                    Button(action: onSwitchToLogin) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Anmelden")
                                .font(SCFont.body(15))
                        }
                        .foregroundColor(.scGold)
                    }
                    Spacer()
                }
                .padding(.horizontal, SCSpacing.lg)
                .padding(.top, SCSpacing.xl)

                brandHeader

                VStack(spacing: SCSpacing.md) {
                    SCTextField(label: "Dein Name", placeholder: "Max Mustermann", text: $name)
                        .autocorrectionDisabled()

                    SCTextField(label: "E-Mail", placeholder: "deine@email.de", text: $email)
                        .keyboardType(.emailAddress).autocapitalization(.none).autocorrectionDisabled()

                    SCSecureField(label: "Passwort (min. 6 Zeichen)", placeholder: "••••••••", text: $password)

                    SCSecureField(label: "Passwort bestätigen", placeholder: "••••••••", text: $passwordConfirm)

                    // Password mismatch hint
                    if !passwordConfirm.isEmpty && password != passwordConfirm {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.scError)
                            Text("Passwörter stimmen nicht überein.")
                                .font(SCFont.caption(12))
                                .foregroundColor(.scError)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                    }

                    // Referral code section
                    referralSection

                    if let err = errorMessage { errorBanner(err) }

                    Button(action: performRegister) {
                        Group {
                            if isLoading { ProgressView().tint(.black) }
                            else { Text("Kostenlos registrieren") }
                        }
                    }
                    .buttonStyle(SCGoldButtonStyle())
                    .disabled(!canSubmit)
                    .opacity(canSubmit ? 1 : 0.6)
                }
                .padding(.horizontal, SCSpacing.lg)

                legalNote
            }
        }
        .onAppear {
            // Refresh from UserDefaults in case a deep link arrived after view init
            let pending = UserDefaults.standard.string(forKey: "pendingReferralCode") ?? ""
            if !pending.isEmpty {
                referralCode = pending
                showReferralField = true
            }
        }
    }

    // MARK: - Referral section

    @ViewBuilder
    private var referralSection: some View {
        VStack(alignment: .leading, spacing: SCSpacing.xs) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showReferralField.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: referralCode.isEmpty ? "gift" : "gift.fill")
                        .font(.system(size: 12))
                        .foregroundColor(referralCode.isEmpty ? .scTextSecondary : .scGold)
                    Text(referralCode.isEmpty
                         ? "Einladungscode eingeben (optional)"
                         : "Einladungscode: \(referralCode)")
                        .font(SCFont.caption(13))
                        .foregroundColor(referralCode.isEmpty ? .scTextSecondary : .scGold)
                    Spacer()
                    Image(systemName: showReferralField ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11))
                        .foregroundColor(.scTextSecondary)
                }
            }

            if showReferralField {
                HStack(spacing: SCSpacing.sm) {
                    TextField("Code z.B. MAX2K4", text: $referralCode)
                        .autocapitalization(.allCharacters)
                        .autocorrectionDisabled()
                        .font(SCFont.mono(14))
                        .foregroundColor(.scGold)
                        .padding()
                        .background(Color.scCard)
                        .cornerRadius(SCRadius.md)

                    if !referralCode.isEmpty {
                        Button {
                            withAnimation { referralCode = "" }
                            UserDefaults.standard.removeObject(forKey: "pendingReferralCode")
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.scTextSecondary)
                        }
                    }
                }

                if !referralCode.isEmpty {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.scSuccess)
                        Text("Du und dein Freund bekommt 3 Tage GEN:SIGNAL gratis!")
                            .font(SCFont.caption(12))
                            .foregroundColor(.scSuccess)
                    }
                }
            }
        }
        .padding(SCSpacing.md)
        .background(Color.scCard)
        .cornerRadius(SCRadius.md)
    }

    // MARK: - Action

    func performRegister() {
        errorMessage = nil
        isLoading = true
        let code = referralCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        Task {
            do {
                let response = try await APIService.shared.register(
                    name: name,
                    email: email,
                    password: password,
                    referralCode: code.isEmpty ? nil : code
                )
                // Clear pending referral code – it has been consumed
                UserDefaults.standard.removeObject(forKey: "pendingReferralCode")
                // Log in with the returned token
                await appState.loginWithToken(response.token, user: response.user)
            } catch APIError.conflict(_) {
                errorMessage = "Diese E-Mail ist bereits registriert. Bitte melde dich an."
            } catch let err as APIError {
                errorMessage = err.errorDescription
            } catch {
                errorMessage = "Registrierung fehlgeschlagen. Versuche es erneut."
            }
            isLoading = false
        }
    }
}

// MARK: - Shared sub-views

private var brandHeader: some View {
    VStack(spacing: SCSpacing.sm) {
        Text("GEN:SELFCORE")
            .font(SCFont.display(32))
            .foregroundColor(.scGold)
        Text("Dein täglicher Begleiter")
            .font(SCFont.body(15))
            .foregroundColor(.scTextSecondary)
    }
}

private var dividerOr: some View {
    HStack(spacing: SCSpacing.md) {
        Rectangle().fill(Color.scBorder).frame(height: 1)
        Text("oder").font(SCFont.caption(12)).foregroundColor(.scTextSecondary)
        Rectangle().fill(Color.scBorder).frame(height: 1)
    }
    .padding(.horizontal, SCSpacing.lg)
}

private var legalNote: some View {
    Text("Mit der Anmeldung akzeptierst du unsere Nutzungsbedingungen und Datenschutzerklärung.")
        .font(SCFont.caption(11))
        .foregroundColor(.scTextSecondary.opacity(0.6))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
        .padding(.bottom, SCSpacing.xl)
}

private func errorBanner(_ message: String) -> some View {
    HStack(spacing: 6) {
        Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(.scError)
        Text(message)
            .font(SCFont.caption(13))
            .foregroundColor(.scError)
    }
    .padding(.horizontal)
}

// MARK: - Reusable text-field wrappers

private struct SCTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: SCSpacing.xs) {
            Text(label)
                .font(SCFont.caption(13))
                .foregroundColor(.scTextSecondary)
            TextField(placeholder, text: $text)
                .padding()
                .background(Color.scCard)
                .cornerRadius(SCRadius.md)
                .foregroundColor(.white)
        }
    }
}

private struct SCSecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: SCSpacing.xs) {
            Text(label)
                .font(SCFont.caption(13))
                .foregroundColor(.scTextSecondary)
            SecureField(placeholder, text: $text)
                .padding()
                .background(Color.scCard)
                .cornerRadius(SCRadius.md)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Password Reset sheet

struct PasswordResetSheet: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var isSent = false
    @State private var isLoading = false
    @State private var errorMessage: String?
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
