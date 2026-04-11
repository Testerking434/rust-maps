// Views/Auth/LoginView.swift
import SwiftUI
import AuthenticationServices

// MARK: - Auth Root View

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var showEmailAuth = false
    @State private var showEmailRegister = false

    var body: some View {
        ZStack {
            Color.scBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: SCSpacing.xl) {
                    // Logo + Branding
                    VStack(spacing: SCSpacing.sm) {
                        Spacer().frame(height: 80)

                        Text("GEN:SELFCORE")
                            .font(SCFont.display(36))
                            .foregroundColor(.scGold)

                        Text("Entdecke wer du wirklich bist")
                            .font(SCFont.body(16))
                            .foregroundColor(.scTextSecondary)
                    }

                    Spacer().frame(height: 40)

                    // === SIGN IN WITH APPLE (Haupt-Button) ===
                    VStack(spacing: SCSpacing.md) {
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            handleAppleSignIn(result)
                        }
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 52)
                        .cornerRadius(SCRadius.md)
                        .padding(.horizontal, SCSpacing.lg)

                        // === SIGN IN WITH GOOGLE ===
                        Button(action: handleGoogleSignIn) {
                            HStack(spacing: 10) {
                                Image(systemName: "g.circle.fill")
                                    .font(.system(size: 20))
                                Text("Mit Google anmelden")
                                    .font(SCFont.headline(16))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.scCard)
                            .cornerRadius(SCRadius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: SCRadius.md)
                                    .stroke(Color.scBorder, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, SCSpacing.lg)
                    }

                    // Divider
                    HStack(spacing: SCSpacing.md) {
                        Rectangle().fill(Color.scBorder).frame(height: 1)
                        Text("oder").font(SCFont.caption(12)).foregroundColor(.scTextSecondary)
                        Rectangle().fill(Color.scBorder).frame(height: 1)
                    }
                    .padding(.horizontal, SCSpacing.lg)

                    // === E-MAIL (klein, ganz unten) ===
                    Button(action: { showEmailAuth = true }) {
                        Text("Mit E-Mail anmelden")
                            .font(SCFont.body(14))
                            .foregroundColor(.scTextSecondary)
                    }

                    // Referral-Hinweis
                    if let refCode = UserDefaults.standard.string(forKey: "pendingReferralCode"), !refCode.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "gift.fill")
                                .foregroundColor(.scGold)
                            Text("Einladungscode: \(refCode)")
                                .font(SCFont.caption(13))
                                .foregroundColor(.scGold)
                        }
                        .padding(SCSpacing.sm)
                        .background(Color.scGold.opacity(0.1))
                        .cornerRadius(SCRadius.sm)
                    }

                    // Legal
                    Text("Mit der Anmeldung akzeptierst du unsere Nutzungsbedingungen und Datenschutzerklärung.")
                        .font(SCFont.caption(11))
                        .foregroundColor(.scTextSecondary.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, SCSpacing.xl)
                }
            }
        }
        .sheet(isPresented: $showEmailAuth) {
            EmailAuthSheet()
        }
    }

    // MARK: - Apple Sign In

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                  let identityTokenData = credential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                return
            }

            let fullName = credential.fullName
            let email = credential.email // nur beim ersten Mal vorhanden

            let referralCode = UserDefaults.standard.string(forKey: "pendingReferralCode")

            Task {
                do {
                    try await appState.loginWithApple(
                        identityToken: identityToken,
                        fullName: fullName,
                        email: email,
                        referralCode: referralCode
                    )
                    UserDefaults.standard.removeObject(forKey: "pendingReferralCode")
                } catch {
                    print("Apple Sign In Fehler: \(error)")
                }
            }

        case .failure(let error):
            // User hat abgebrochen — kein Fehler anzeigen
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                print("Apple Sign In Fehler: \(error)")
            }
        }
    }

    // MARK: - Google Sign In (Placeholder)

    private func handleGoogleSignIn() {
        // TODO: Google Sign-In SDK einbinden
        // https://developers.google.com/identity/sign-in/ios/start
        // Für jetzt: Zeige E-Mail Auth als Fallback
        showEmailAuth = true
    }
}

// MARK: - E-Mail Auth Sheet

struct EmailAuthSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var isRegister = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirm = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var referralCode: String = UserDefaults.standard.string(forKey: "pendingReferralCode") ?? ""

    private var canLogin: Bool {
        !email.isEmpty && !password.isEmpty && !isLoading
    }

    private var canRegister: Bool {
        !name.isEmpty && !email.isEmpty && password.count >= 6 && password == passwordConfirm && !isLoading
    }

    var body: some View {
        ZStack {
            Color.scBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: SCSpacing.lg) {
                    Capsule()
                        .fill(Color.scBorder)
                        .frame(width: 40, height: 4)
                        .padding(.top)

                    Text(isRegister ? "Account erstellen" : "E-Mail Anmeldung")
                        .font(SCFont.headline(22))
                        .foregroundColor(.white)

                    VStack(spacing: SCSpacing.md) {
                        if isRegister {
                            SCTextField(label: "Dein Name", placeholder: "Max Mustermann", text: $name)
                                .autocorrectionDisabled()
                        }

                        SCTextField(label: "E-Mail", placeholder: "deine@email.de", text: $email)
                            .keyboardType(.emailAddress).autocapitalization(.none).autocorrectionDisabled()

                        SCSecureField(label: "Passwort", placeholder: "Min. 6 Zeichen", text: $password)

                        if isRegister {
                            SCSecureField(label: "Passwort bestätigen", placeholder: "Nochmal eingeben", text: $passwordConfirm)

                            if !passwordConfirm.isEmpty && password != passwordConfirm {
                                HStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 11))
                                    Text("Passwörter stimmen nicht überein.")
                                        .font(SCFont.caption(12))
                                }
                                .foregroundColor(.scError)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        if let err = errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(err).font(SCFont.caption(13))
                            }
                            .foregroundColor(.scError)
                        }

                        Button(action: isRegister ? performRegister : performLogin) {
                            Group {
                                if isLoading { ProgressView().tint(.black) }
                                else { Text(isRegister ? "Registrieren" : "Anmelden") }
                            }
                        }
                        .buttonStyle(SCGoldButtonStyle())
                        .disabled(isRegister ? !canRegister : !canLogin)
                        .opacity((isRegister ? canRegister : canLogin) ? 1 : 0.6)
                    }
                    .padding(.horizontal, SCSpacing.lg)

                    Button(action: { withAnimation { isRegister.toggle(); errorMessage = nil } }) {
                        Text(isRegister
                             ? "Schon einen Account? **Anmelden**"
                             : "Noch kein Account? **Registrieren**")
                            .font(SCFont.body(14))
                            .foregroundColor(.scGold)
                    }

                    Spacer()
                }
            }
        }
        .presentationDetents([.large])
    }

    func performLogin() {
        errorMessage = nil
        isLoading = true
        Task {
            do {
                try await appState.loginWithEmail(email: email, password: password)
                dismiss()
            } catch let err as APIError {
                errorMessage = err.errorDescription
            } catch {
                errorMessage = "Anmeldung fehlgeschlagen."
            }
            isLoading = false
        }
    }

    func performRegister() {
        errorMessage = nil
        isLoading = true
        let code = referralCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        Task {
            do {
                try await appState.registerWithEmail(
                    name: name, email: email, password: password,
                    referralCode: code.isEmpty ? nil : code
                )
                UserDefaults.standard.removeObject(forKey: "pendingReferralCode")
                dismiss()
            } catch APIError.conflict(_) {
                errorMessage = "Diese E-Mail ist bereits registriert."
            } catch let err as APIError {
                errorMessage = err.errorDescription
            } catch {
                errorMessage = "Registrierung fehlgeschlagen."
            }
            isLoading = false
        }
    }
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
