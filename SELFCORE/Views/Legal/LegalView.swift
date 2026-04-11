// Views/Legal/LegalView.swift
import SwiftUI

// MARK: - Datenschutzerklärung
struct PrivacyPolicyView: View {
    var body: some View {
        LegalTextView(
            title: "Datenschutzerklärung",
            content: """
**Datenschutzerklärung**

Stand: April 2026

**Verantwortlicher**
[Dein Name]
[Straße, PLZ Ort]
[deine@email.de]

**1. Datenerhebung**
Diese App erhebt folgende Daten:
- E-Mail-Adresse und Passwort (für Login)
- Tägliche Check-ins und Stimmungsdaten
- Kursfortschritt
- Gerätedaten (iOS-Version, Gerätetyp)

**2. Zweck der Verarbeitung**
Die Daten werden ausschließlich für die Bereitstellung der App-Funktionen verwendet:
- Authentifizierung
- Fortschrittsverfolgung
- Personalisierung der Inhalte

**3. Speicherung**
Daten werden auf unserem Server (api.genselfcore.de) gespeichert. Lokale Daten werden im App-Speicher deines Geräts gesichert.

**4. Apple Health**
Mit deiner Zustimmung werden Mindful-Minuten in Apple Health geschrieben. Diese Daten verlassen dein Gerät nicht in Richtung unserer Server.

**5. StoreKit / Apple**
Abonnements werden über Apple's App Store abgewickelt. GEN:SELFCORE hat keinen Zugriff auf Zahlungsdaten.

**6. Deine Rechte**
Du hast das Recht auf Auskunft, Berichtigung, Löschung und Datenübertragbarkeit. Kontaktiere uns unter der oben genannten Adresse.

**7. Kontakt**
[deine@email.de]
"""
        )
    }
}

// MARK: - Impressum
struct ImpressumView: View {
    var body: some View {
        LegalTextView(
            title: "Impressum",
            content: """
**Impressum**

Angaben gemäß § 5 TMG

**Betreiber**
[Dein vollständiger Name]
[Straße und Hausnummer]
[PLZ und Ort]
Deutschland

**Kontakt**
E-Mail: [deine@email.de]
Website: https://genselfcore.de

**Verantwortlich für den Inhalt nach § 55 Abs. 2 RStV**
[Dein Name]
[Adresse wie oben]

**Hinweis**
Die GEN:SELFCORE App ist ein Begleiter-Produkt zu genselfcore.de. Alle Inhalte dienen der persönlichen Entwicklung und stellen keine psychologische oder medizinische Beratung dar.
"""
        )
    }
}

// MARK: - Nutzungsbedingungen
struct NutzungsbedingungenView: View {
    var body: some View {
        LegalTextView(
            title: "Nutzungsbedingungen",
            content: """
**Nutzungsbedingungen**

Stand: April 2026

**1. Geltungsbereich**
Diese Bedingungen gelten für die Nutzung der GEN:SELFCORE iOS-App.

**2. Leistungsbeschreibung**
Die App bietet:
- Tägliche Check-ins und Micro-Aktionen
- Zugang zu SELFCORE-Kursinhalten
- GEN:SIGNAL Audio-Inhalte (mit Abo)
- Fortschrittsanalyse

**3. Abonnement (GEN:SIGNAL)**
- Monatliches Abo: 4,99 € / Monat
- Jahres-Abo: 34,99 € / Jahr
- Automatische Verlängerung, wenn nicht 24h vor Ablauf gekündigt
- Kündigung über Apple ID Einstellungen

**4. Kostenlose Inhalte**
Die App-Grundfunktionen (Check-in, Kurszugang, Profil) sind nach Registrierung auf genselfcore.de kostenlos nutzbar.

**5. Nutzungsrechte**
Die Inhalte sind ausschließlich für den persönlichen Gebrauch. Weiterverbreitung, Kopie oder kommerzielle Nutzung ist nicht gestattet.

**6. Haftungsausschluss**
Die Inhalte dienen der Selbstentwicklung. Sie ersetzen keine professionelle psychologische oder medizinische Beratung. Bei ernsthaften Problemen wende dich an Fachleute.

**7. Änderungen**
Wir behalten uns vor, diese Bedingungen jederzeit zu ändern. Änderungen werden in der App kommuniziert.

**8. Kontakt**
[deine@email.de]
"""
        )
    }
}

// MARK: - Shared Legal Text View
struct LegalTextView: View {
    let title: String
    let content: String

    var body: some View {
        ZStack {
            Color.scBackground.ignoresSafeArea()
            ScrollView {
                Text(try! AttributedString(markdown: content))
                    .font(SCFont.body(14))
                    .foregroundColor(.scTextSecondary)
                    .lineSpacing(6)
                    .padding(SCSpacing.lg)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
