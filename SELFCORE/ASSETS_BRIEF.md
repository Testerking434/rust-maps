# GEN:SELFCORE — Visual Assets Brief
> Dieses Dokument enthält alle nötigen Infos um sämtliche App-Grafiken zu erstellen.
> Einfach die Prompts kopieren und bei den genannten Tools einfügen.

---

## Brand-Farben (für alle Grafiken verwenden)

| Name | Hex | Verwendung |
|---|---|---|
| Hintergrund | `#0A0A0A` | Überall als BG |
| Card | `#141414` | Karten-BG |
| Gold | `#F5A623` | Primär-Akzent, Highlights |
| Signal Cyan | `#00C9C9` | Audio, sekundärer Akzent |
| Selbstkenntnis | `#F5A623` | Dimension 1 (Gold) |
| Authentizität | `#FF6B9D` | Dimension 2 (Pink) |
| Klarheit | `#4A90D9` | Dimension 3 (Blau) |
| Mut | `#FF6B35` | Dimension 4 (Orange) |
| Verbindung | `#5CB85C` | Dimension 5 (Grün) |

---

## 1. APP ICON (höchste Priorität)

**Größe:** 1024 × 1024 px, PNG, keine Transparenz, keine abgerundeten Ecken (macht Xcode selbst)

### Tool: bing.com/images/create (kostenlos, kein Account nötig)

**Prompt Option A — Geometrischer Kern:**
```
App icon for a premium personal growth app.
Solid dark background #0A0A0A.
A minimal geometric symbol: five thin lines radiating
outward from a central glowing gold hexagonal core,
like a compass rose meets DNA. Gold color #F5A623,
subtle cyan glow #00C9C9 at center.
Ultra clean flat design, no text, no letters,
rounded square format 1024x1024. Apple App Store style.
Modern minimal luxury aesthetic.
```

**Prompt Option B — DNA Spiral:**
```
Minimal app icon, pure black background,
single golden double-helix DNA spiral forming
a perfect circle, glowing cyan center point,
premium luxury aesthetic, flat vector art,
no text, no letters, square format 1024x1024,
ultra clean modern design.
```

**Prompt Option C — SC Monogramm:**
```
Premium app icon, black background #0A0A0A,
geometric monogram letters SC interlocked,
gold gradient color #F5A623 to #FFD700,
sharp angular design, minimal luxury,
no extra elements, square format, 1024x1024.
```

### Nächste Schritte nach Download:
1. Bestes Bild downloaden (rechtsklick → speichern)
2. Auf **appicon.ai** hochladen
3. "Generate" klicken → ZIP mit allen Xcode-Größen downloaden
4. `AppIcon.xcassets` Ordner ins Xcode-Projekt ziehen (ersetzt den bestehenden)

---

## 2. KURS-COVER (je Kurs ein Bild)

**Größe:** 800 × 450 px (16:9), PNG oder JPG

### AWAKENING — Kurs 1
```
Abstract digital art for a personal development course
called AWAKENING. Dark background #0A0A0A.
A human silhouette emerging from darkness into golden light,
geometric rays of gold (#F5A623) breaking through,
cinematic minimal luxury aesthetic, no text, no letters,
16:9 aspect ratio, ultra HD photorealistic.
```

### ORIGIN — Kurs 2 (DNA-Test / Persönlichkeit)
```
Abstract art for a personality DNA test course called ORIGIN.
Dark background #0A0A0A. Glowing double helix DNA strand,
gold (#F5A623) and cyan (#00C9C9) colors,
scientific luxury aesthetic, no text, no letters,
16:9 aspect ratio, ultra clean futuristic minimal.
```

### VERBINDUNG — Kurs 3 (Beziehungen)
```
Abstract art for a relationships course.
Dark background, two geometric shapes (circles or hexagons)
connected by glowing lines, green color #5CB85C,
warm and connected feeling, minimal luxury, no text, 16:9.
```

### MUT — Kurs 4
```
Abstract art for a courage course called MUT.
Dark background, upward-pointing geometric arrow or flame shape,
orange-red color #FF6B35, bold dynamic energy,
minimal luxury, no text, 16:9 aspect ratio.
```

---

## 3. GEN:SIGNAL — AUDIO TRACK COVER ART

**Größe:** 600 × 600 px (quadratisch), PNG

### Standard Track Cover (für alle Tracks als Template):
```
Abstract sound wave visualization for a mindfulness
audio app. Pure black background #0A0A0A.
Glowing cyan waveform #00C9C9, smooth flowing curves,
meditation zen aesthetic, minimal premium design,
no text, no letters, perfect square 600x600.
```

### Gratitude Flow (Exklusiver Referral-Reward Track):
```
Abstract art for an exclusive gratitude meditation track.
Dark background, soft golden particles floating upward,
warm glowing atmosphere, luxury spiritual aesthetic,
no text, square 600x600, premium minimal.
```

### Morning Focus (Morgen-Track):
```
Abstract sunrise visualization, dark to gold gradient,
geometric sun rays, energizing premium aesthetic,
meditation app cover art, no text, square 600x600.
```

### Deep Sleep (Nacht-Track):
```
Abstract night sky with subtle geometric star patterns,
deep blue #0A1628 to black background, calming cyan glow,
sleep meditation aesthetic, no text, square 600x600.
```

---

## 4. ONBOARDING-ILLUSTRATIONEN (3 Screens)

**Größe:** 1125 × 800 px, PNG

### Screen 1 — DNA Test:
```
Abstract illustration for a personality test onboarding screen.
Dark background #0A0A0A. Human silhouette with 5 glowing
geometric points on body (like chakras), each a different color:
gold, pink, blue, orange, green. DNA helix in background.
Minimal luxury style, no text, wide format 16:9.
```

### Screen 2 — GEN:SIGNAL Audio:
```
Abstract illustration for an audio meditation app onboarding.
Dark background, person silhouette with headphones,
sound waves visualized as golden geometric patterns
radiating outward, cyan glow, premium aesthetic,
no text, wide format 16:9.
```

### Screen 3 — Wachstum / Streak:
```
Abstract growth visualization for a personal development app.
Dark background, 5 vertical bars rising upward,
each a different color (gold, pink, blue, orange-red, green),
upward momentum energy, minimal luxury, no text, wide 16:9.
```

---

## 5. APP STORE SCREENSHOTS (6 Stück)

**Größe:** 1290 × 2796 px (iPhone 15 Pro Max), PNG

> Diese machst du selbst mit dem iPhone Simulator in Xcode.
> Dann in Canva eine schöne Rahmengrafik drumherum bauen.

**Welche 6 Screens zeigen:**
1. **Home** — Streak + Tages-Energie-Card + Zitat
2. **DNA-Test Ergebnis** — Die 5 Dimensionen als Bars
3. **GEN:SIGNAL Player** — Audio-Player mit Waveform
4. **Kurse** — Kurs-Übersicht
5. **Freunde einladen** — Referral-View mit Code
6. **Widget** — iPhone Homescreen mit Widget

**Canva Template-Suche:** "App Store Screenshot Template" → Dark Theme wählen → eigene Screens einfügen

---

## 6. OG:IMAGE (Link-Vorschau beim Teilen)

**Größe:** 1200 × 630 px (für genselfcore.de/join)
**Tool:** Canva

**Inhalt:**
- Hintergrund: `#0A0A0A`
- Links: App Icon groß
- Rechts: "GEN:SELFCORE" in Gold + Tagline "Erkenne dich selbst. Wachse täglich."
- Kleiner Text unten: "Kostenlos starten — 3 Tage GEN:SIGNAL gratis"

---

## 7. ZUSAMMENFASSUNG — Was zuerst erledigen

```
Priorität 1 (vor App Store Submit):
  ✅ App Icon → bing.com/images/create → appicon.ai
  ✅ 6 App Store Screenshots → Simulator + Canva

Priorität 2 (vor Launch):
  ✅ 4 Kurs-Cover → bing.com/images/create
  ✅ 3-5 Signal Track Covers → bing.com/images/create
  ✅ OG:Image für Referral-Link → Canva

Priorität 3 (nice to have):
  ✅ Onboarding-Illustrationen × 3
  ✅ App Preview Video (30 Sek)
```

---

## Tools Übersicht

| Tool | URL | Kosten | Wofür |
|---|---|---|---|
| DALL-E (Bing) | bing.com/images/create | Kostenlos | Icon + Illustrations |
| Midjourney | midjourney.com | ab 10$/Mo | Hochwertigere Bilder |
| appicon.ai | appicon.ai | Kostenlos | Icon → alle Xcode-Größen |
| Canva | canva.com | Kostenlos | Screenshots, OG:Image |
| Xcode Simulator | In Xcode | Kostenlos | App Store Screenshots |
