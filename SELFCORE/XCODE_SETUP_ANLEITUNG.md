# SELFCORE App – Xcode Setup Anleitung
## Schritt-für-Schritt für Nicht-Programmierer

---

## SCHRITT 1: Neues Xcode Projekt erstellen

1. Xcode öffnen → **"Create New Project"**
2. Wähle: **iOS → App**
3. Einstellungen:
   - **Product Name:** `SELFCORE`
   - **Organization Identifier:** `de.genselfcore`
   - **Bundle Identifier:** wird automatisch `de.genselfcore.SELFCORE`
   - **Interface:** `SwiftUI`
   - **Language:** `Swift`
4. Speichern (beliebiger Ort)

---

## SCHRITT 2: Dateien einfügen

Im Finder den Ordner `SELFCORE/` aus dem GitHub-Repo öffnen.
In Xcode links den Projektbaum sehen.

**Für jede Datei:**
1. In Xcode: Rechtsklick auf den Ordner → **"Add Files to SELFCORE"**
2. Oder: Dateien direkt in den Xcode-Navigator ziehen

**Ordnerstruktur im Xcode-Navigator:**
```
SELFCORE/
├── SELFCOREApp.swift
├── AppState.swift
├── DesignSystem.swift
├── Models/
│   ├── Profile.swift
│   ├── Course.swift
│   ├── CheckIn.swift
│   ├── StreakData.swift
│   ├── DailyQuote.swift
│   └── SignalProduct.swift
├── Services/
│   ├── APIService.swift
│   ├── NotificationService.swift
│   ├── SubscriptionService.swift
│   ├── StreakService.swift
│   ├── WeeklyReviewService.swift
│   ├── HealthKitService.swift
│   └── WidgetDataService.swift
├── Data/
│   └── MicroActionsData.swift
└── Views/
    ├── MainTabView.swift
    ├── Auth/LoginView.swift
    ├── Home/HomeView.swift
    ├── Home/DailyEnergyCard.swift
    ├── Home/StreakBannerView.swift
    ├── Home/DailyQuoteCard.swift
    ├── Profile/ProfileView.swift
    ├── Profile/DimensionGrowthView.swift
    ├── Courses/CoursesView.swift
    ├── Courses/CourseUnlockAnimation.swift
    ├── Signal/GenSignalView.swift
    ├── Signal/AudioPlayerView.swift
    ├── Signal/AudioRecommendationCard.swift
    ├── Signal/SleepTimerView.swift
    ├── Signal/PaywallView.swift
    ├── History/HistoryView.swift
    ├── History/WeeklyReviewView.swift
    ├── Settings/SettingsView.swift
    └── Legal/LegalView.swift
```

---

## SCHRITT 3: Capabilities aktivieren

Im Xcode:
1. Klicke auf **"SELFCORE"** (ganz oben links im Navigator)
2. Wähle **"Signing & Capabilities"**
3. Klicke **"+ Capability"** und füge hinzu:

✅ **Background Modes** → Haken bei "Audio, AirPlay, and Picture in Picture"
✅ **Push Notifications**
✅ **HealthKit**
✅ **App Groups** → Gruppe hinzufügen: `group.de.genselfcore.app`

---

## SCHRITT 4: Info.plist aktualisieren

In Xcode: SELFCORE → Info → füge diese Keys hinzu (Rechtsklick → Add Row):

| Key | Wert |
|-----|------|
| `NSUserNotificationUsageDescription` | "Für tägliche Check-in Erinnerungen" |
| `NSHealthShareUsageDescription` | "Um deine Stimmungsdaten in Apple Health zu speichern" |
| `NSHealthUpdateUsageDescription` | "Um Mindful Minutes aus Check-ins und Audio zu speichern" |
| `CFBundleDisplayName` | SELFCORE |
| `UIRequiresFullScreen` | YES |

---

## SCHRITT 5: StoreKit Produkte anlegen (App Store Connect)

1. Gehe zu: **appstoreconnect.apple.com**
2. Deine App → "In-App Purchases" → "+" → **Auto-Renewable Subscription**
3. Erstelle:
   - **Monatlich:** ID = `de.genselfcore.signal.monthly`, Preis: 4,99 €
   - **Jährlich:** ID = `de.genselfcore.signal.yearly`, Preis: 34,99 €
4. Subscription Group anlegen: Name = "GEN:SIGNAL Premium"

---

## SCHRITT 6: Widget Target hinzufügen (Feature 4)

1. Xcode → File → New → **Target**
2. Wähle: **Widget Extension**
3. Name: `SELFCOREWidget`
4. **KEIN** "Include Configuration Intent"
5. Die Dateien aus `SELFCOREWidget/` in den neuen Target ziehen

---

## SCHRITT 7: App Icon erstellen

1. Gehe zu: **appicon.ai**
2. Lade ein quadratisches Bild hoch (z.B. dein GEN:SELFCORE Logo auf schwarzem Hintergrund)
3. Lade das generierte ZIP herunter
4. In Xcode: `Assets.xcassets` → `AppIcon` → alle Slots füllen

---

## SCHRITT 8: Simulator Test

1. Oben in Xcode: Simulator wählen (z.B. **iPhone 16 Pro**)
2. ▶ Play drücken
3. App öffnet sich im Simulator

**Was du siehst (ohne Server):**
- Login-Screen
- ⚠️ Login schlägt fehl weil kein Server → normal
- Alle UI-Elemente sind sichtbar

---

## SCHRITT 9: Echtes Gerät testen

1. iPhone per USB verbinden
2. Xcode → Signing → dein Apple ID Konto auswählen
3. Gerät in der Leiste wählen
4. ▶ Play drücken
5. iPhone: Einstellungen → Allgemein → VPN & Geräteverwaltung → App vertrauen

---

## SCHRITT 10: App Store Einreichung

1. Apple Developer Account: **developer.apple.com** (99 €/Jahr)
2. App Store Connect: App anlegen
3. Screenshots erstellen (Simulator → Screenshot-Button)
4. Xcode → Product → **Archive**
5. Xcode Organizer → **Distribute App**

---

## BACKEND API (für später)

Dein Server muss folgende Endpoints haben:

```
POST /auth/login          → { token, user }
POST /auth/logout         → {}
POST /auth/reset-password → {}
GET  /user/profile        → UserProfile
GET  /user/courses        → [Course]
POST /checkins            → {}
GET  /user/weekly-stats   → WeeklyStats
```

---

## PREISGESTALTUNG

| Produkt | Einzelpreis | Abo |
|---------|------------|-----|
| DNA Test (genselfcore.de) | 50 € | — |
| Eine Audio (einzeln) | 99 € | — |
| **GEN:SIGNAL Abo (monatlich)** | — | **4,99 € / Mo** |
| **GEN:SIGNAL Abo (jährlich)** | — | **34,99 € / Jahr** |

**→ Nutzer sehen: "Für 4,99 € bekomme ich alles, was sonst 792 € kostet. Kein Verzicht."**

---

## FERTIGE FEATURES

| # | Feature | Status |
|---|---------|--------|
| 1 | Personalisierte Tagesenergie-Analyse | ✅ |
| 2 | Streak-System mit Meilensteinen + Animationen | ✅ |
| 3 | Dimension-Wachstum Visualisierung | ✅ |
| 4 | iOS Home Screen Widget (Klein + Mittel) | ✅ |
| 5 | Sleep Timer für Audio | ✅ |
| 6 | Tagesquote nach SELFCORE-Typ (30+ Quotes) | ✅ |
| 7 | Audio-Empfehlung basierend auf schwächster Dimension | ✅ |
| 8 | Entsperr-Animationen bei Kursfortschritt | ✅ |
| 9 | Wochenrückblick (Freitag 18 Uhr Notification) | ✅ |
| 10 | Apple Health Integration (Mindful Minutes) | ✅ |

---

**Füllen musst du noch:**
- `[Dein Name]` in LegalView.swift ersetzen
- `[Adresse]` und `[deine@email.de]` ersetzen
- App Icon erstellen
- Server-Backend aufbauen
