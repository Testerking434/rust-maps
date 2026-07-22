# SELFCORE Backend Server – Komplette Anleitung
## Wie du Kurse, Lektionen, Workbooks und Audiodateien in die App bekommst

---

## ARCHITEKTUR ÜBERBLICK

```
iPhone App
    │
    ├── GET /user/courses         → Liste aller Kurse + Fortschritt
    ├── GET /courses/awakening/lessons → Alle Lektionen
    ├── GET /courses/awakening/lessons/awakening-l1 → Lektion mit Inhalt
    ├── POST /content/workbook/awakening-l1/signed-url → Sichere PDF-URL
    └── POST /content/audio/deep-sleep-delta/signed-url → Sichere Audio-URL

Cloudflare R2 / AWS S3 (Dateispeicher)
    ├── workbooks/awakening-l1.pdf
    ├── workbooks/awakening-l2.pdf
    ├── audio/deep-sleep-delta.mp3
    └── audio/hyperfocus-alpha.mp3
```

---

## OPTION A: Node.js + Express (Empfohlen – einfach)

### 1. Installation (auf deinem Server)

```bash
npm init -y
npm install express jsonwebtoken bcrypt multer aws-sdk cors dotenv
```

### 2. Datenbankstruktur (JSON-Dateien reichen für den Start)

Erstelle diese Ordner auf deinem Server:
```
server/
├── data/
│   ├── courses.json        ← Kursdaten
│   ├── lessons/
│   │   ├── awakening.json  ← Alle Lektionen für AWAKENING
│   │   ├── origin.json
│   │   ├── genesis.json
│   │   ├── foundation.json
│   │   └── core-journey.json
│   └── users/
│       └── {userId}.json   ← Fortschritt pro User
├── audio/                  ← MP3 Dateien (oder S3-Links)
│   ├── deep-sleep-delta.mp3
│   └── hyperfocus-alpha.mp3
└── workbooks/              ← PDF Dateien
    ├── awakening-l1.pdf
    └── awakening-l2.pdf
```

### 3. courses.json Beispiel

```json
[
  {
    "id": "awakening",
    "title": "AWAKENING",
    "subtitle": "Erwache zu dir selbst",
    "description": "Der erste Schritt: Erkenne wer du wirklich bist.",
    "totalLessons": 42,
    "color": "#F5A623",
    "icon": "sun.rise.fill",
    "isUnlocked": true
  },
  {
    "id": "origin",
    "title": "ORIGIN",
    "subtitle": "Verstehe deine Wurzeln",
    "description": "Deine Vergangenheit erklärt deine Gegenwart.",
    "totalLessons": 36,
    "color": "#FF6B9D",
    "icon": "tree.fill",
    "isUnlocked": false
  }
]
```

### 4. lessons/awakening.json Beispiel

```json
[
  {
    "id": "awakening-l1",
    "courseId": "awakening",
    "title": "Wer du wirklich bist",
    "subtitle": "Die Maske und das wahre Gesicht",
    "order": 1,
    "contentMarkdown": "# Wer du wirklich bist\n\nBevor wir beginnen...\n\n## Die Maske\n\nJeder von uns trägt Masken...",
    "workbookUrl": "awakening-l1.pdf",
    "durationMinutes": 8,
    "isLocked": false,
    "keyInsights": [
      "Jeder trägt Masken — das ist normal",
      "Die Maske entsteht als Schutz in der Kindheit",
      "Das wahre Ich ist nie verschwunden"
    ],
    "exercise": {
      "title": "Die Masken-Übung",
      "description": "Schreibe 3 Situationen auf...",
      "type": "journaling",
      "prompt": "In welchen Situationen trage ich eine Maske?"
    }
  }
]
```

### 5. Express Server (server.js)

```javascript
const express = require('express');
const jwt = require('jsonwebtoken');
const fs = require('fs');
const path = require('path');
const app = express();

app.use(express.json());
app.use(require('cors')());

const JWT_SECRET = process.env.JWT_SECRET || 'dein-geheimer-schluessel-hier';
const BASE_URL = 'https://api.genselfcore.de';

// ─── MIDDLEWARE: Auth ───────────────────────────────────────────
function authMiddleware(req, res, next) {
  const header = req.headers.authorization;
  if (!header) return res.status(401).json({ error: 'Unauthorized' });
  try {
    const token = header.replace('Bearer ', '');
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ error: 'Invalid token' });
  }
}

// ─── AUTH ───────────────────────────────────────────────────────
app.post('/v1/auth/login', (req, res) => {
  const { email, password } = req.body;
  // TODO: Deine User-Datenbank prüfen
  // Beispiel: Nur für Tests
  if (email === 'test@genselfcore.de' && password === 'test123') {
    const token = jwt.sign({ userId: '1', email }, JWT_SECRET, { expiresIn: '30d' });
    res.json({
      token,
      user: {
        id: '1',
        name: 'Max Mustermann',
        email,
        selfcoreType: 'ACHIEVER',
        dimensions: {
          selbstkenntnis: 7.2,
          authentizitaet: 5.8,
          klarheit: 8.1,
          mut: 4.3,
          verbindung: 6.9
        }
      }
    });
  } else {
    res.status(401).json({ error: 'E-Mail oder Passwort falsch' });
  }
});

app.post('/v1/auth/logout', authMiddleware, (req, res) => {
  res.json({});
});

app.post('/v1/auth/reset-password', (req, res) => {
  // TODO: E-Mail senden (z.B. mit Nodemailer)
  res.json({});
});

// ─── USER ───────────────────────────────────────────────────────
app.get('/v1/user/profile', authMiddleware, (req, res) => {
  // TODO: Aus echter Datenbank laden
  res.json({
    id: req.user.userId,
    name: 'Max Mustermann',
    email: req.user.email,
    selfcoreType: 'ACHIEVER',
    dimensions: {
      selbstkenntnis: 7.2,
      authentizitaet: 5.8,
      klarheit: 8.1,
      mut: 4.3,
      verbindung: 6.9
    }
  });
});

// ─── COURSES ───────────────────────────────────────────────────
app.get('/v1/user/courses', authMiddleware, (req, res) => {
  const courses = JSON.parse(fs.readFileSync('./data/courses.json'));
  // TODO: Fortschritt aus user-Datei laden
  res.json(courses.map(c => ({ ...c, completedLessons: 0 })));
});

app.get('/v1/courses/:courseId/lessons', authMiddleware, (req, res) => {
  const { courseId } = req.params;
  const filePath = `./data/lessons/${courseId}.json`;
  if (!fs.existsSync(filePath)) {
    return res.status(404).json({ error: 'Kurs nicht gefunden' });
  }
  const lessons = JSON.parse(fs.readFileSync(filePath));
  res.json(lessons);
});

app.get('/v1/courses/:courseId/lessons/:lessonId', authMiddleware, (req, res) => {
  const { courseId, lessonId } = req.params;
  const filePath = `./data/lessons/${courseId}.json`;
  if (!fs.existsSync(filePath)) return res.status(404).json({ error: 'Nicht gefunden' });
  const lessons = JSON.parse(fs.readFileSync(filePath));
  const lesson = lessons.find(l => l.id === lessonId);
  if (!lesson) return res.status(404).json({ error: 'Lektion nicht gefunden' });
  res.json(lesson);
});

app.post('/v1/courses/:courseId/lessons/:lessonId/complete', authMiddleware, (req, res) => {
  // TODO: Fortschritt in Datenbank speichern
  res.json({});
});

// ─── WORKBOOK PDF (signierte URL) ──────────────────────────────
app.get('/v1/content/workbook/:lessonId/signed-url', authMiddleware, (req, res) => {
  const { lessonId } = req.params;
  // Option 1: Direkte Datei-URL (einfach)
  const url = `${BASE_URL}/v1/files/workbooks/${lessonId}.pdf`;
  // Option 2: S3 Signed URL (sicherer) — siehe unten
  res.json({
    url,
    expiresAt: new Date(Date.now() + 3600000).toISOString() // 1 Stunde
  });
});

// PDF Datei direkt ausliefern (nur wenn authorisiert)
app.get('/v1/files/workbooks/:filename', authMiddleware, (req, res) => {
  const filePath = path.join('./workbooks', req.params.filename);
  if (!fs.existsSync(filePath)) return res.status(404).send('Nicht gefunden');
  res.setHeader('Content-Type', 'application/pdf');
  res.sendFile(path.resolve(filePath));
});

// ─── AUDIO (signierte URL) ─────────────────────────────────────
app.get('/v1/signal/:trackId', authMiddleware, (req, res) => {
  // Prüfe ob User Subscriber ist
  // TODO: Abo-Status aus Datenbank prüfen
  const { trackId } = req.params;
  const filePath = path.join('./audio', `${trackId}.mp3`);
  if (!fs.existsSync(filePath)) return res.status(404).send('Track nicht gefunden');
  
  // Streaming mit Range-Support (wichtig für iOS)
  const stat = fs.statSync(filePath);
  const range = req.headers.range;

  if (range) {
    const parts = range.replace(/bytes=/, '').split('-');
    const start = parseInt(parts[0], 10);
    const end = parts[1] ? parseInt(parts[1], 10) : stat.size - 1;
    const chunkSize = end - start + 1;
    const stream = fs.createReadStream(filePath, { start, end });
    res.writeHead(206, {
      'Content-Range': `bytes ${start}-${end}/${stat.size}`,
      'Accept-Ranges': 'bytes',
      'Content-Length': chunkSize,
      'Content-Type': 'audio/mpeg',
    });
    stream.pipe(res);
  } else {
    res.writeHead(200, {
      'Content-Length': stat.size,
      'Content-Type': 'audio/mpeg',
      'Accept-Ranges': 'bytes',
    });
    fs.createReadStream(filePath).pipe(res);
  }
});

// ─── CHECK-INS ─────────────────────────────────────────────────
app.post('/v1/checkins', authMiddleware, (req, res) => {
  // TODO: In Datenbank speichern
  res.json({});
});

// ─── START ─────────────────────────────────────────────────────
app.listen(3000, () => {
  console.log('SELFCORE API läuft auf Port 3000');
});
```

---

## OPTION B: Cloudflare R2 für Dateien (Empfohlen für Audio + PDFs)

### Warum Cloudflare R2?
- **5 GB gratis** pro Monat
- **Kein Egress-Preis** (im Vergleich zu AWS)
- **Weltweites CDN** — Audio lädt schnell weltweit
- Audio-Streaming funktioniert perfekt

### Setup

1. cloudflare.com → R2 → Bucket erstellen: `genselfcore-content`
2. Folder erstellen: `audio/` und `workbooks/`
3. MP3s und PDFs hochladen
4. API-Token erstellen (R2 Token)
5. Im Node.js Server:

```javascript
const { S3Client, GetObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');

const r2 = new S3Client({
  region: 'auto',
  endpoint: 'https://DEINE_ACCOUNT_ID.r2.cloudflarestorage.com',
  credentials: {
    accessKeyId: process.env.R2_ACCESS_KEY,
    secretAccessKey: process.env.R2_SECRET_KEY,
  },
});

// Signierte URL für Audio
async function getSignedAudioUrl(trackId) {
  const command = new GetObjectCommand({
    Bucket: 'genselfcore-content',
    Key: `audio/${trackId}.mp3`,
  });
  return await getSignedUrl(r2, command, { expiresIn: 3600 }); // 1 Stunde
}

// Signierte URL für Workbook
async function getSignedWorkbookUrl(lessonId) {
  const command = new GetObjectCommand({
    Bucket: 'genselfcore-content',
    Key: `workbooks/${lessonId}.pdf`,
  });
  return await getSignedUrl(r2, command, { expiresIn: 3600 });
}
```

---

## WIE DU INHALTE ERSTELLST

### Lektions-Texte (Markdown)
- Schreibe die Texte in Notion, exportiere als Markdown
- Füge sie in `data/lessons/awakening.json` ein
- Pro Lektion ca. 400-800 Wörter

### Workbook PDFs
- Erstelle PDFs in Canva, Notion oder Word
- Design: Schwarzer Hintergrund, Gold-Akzente (passt zur App)
- Speichere als `awakening-l1.pdf`, `awakening-l2.pdf` etc.
- Lade in R2 oder `server/workbooks/` hoch

### Audio-Dateien (Binaural Beats)
- Du hast bereits die GEN:SIGNAL Audios
- Format: MP3, min. 192kbps
- Namen: `deep-sleep-delta.mp3`, `hyperfocus-alpha.mp3` etc.
- Lade in R2 oder `server/audio/` hoch

---

## DEPLOYMENT (Server online bringen)

### Option 1: Railway.app (einfachste)
1. railway.app → New Project
2. GitHub Repo mit server.js verbinden
3. Automatisches Deployment
4. Custom Domain: api.genselfcore.de → Railway URL

### Option 2: Hetzner (dein eigener Server)
```bash
# Auf dem Server:
git clone dein-repo
npm install
npm install pm2 -g
pm2 start server.js
pm2 save
```

### Option 3: Vercel (für serverless)
- Funktioniert für API-Routes
- Kostenfrei für kleine Apps

---

## KURZFASSUNG: WAS DU TUN MUSST

1. ✅ **Node.js Server starten** (server.js oben kopieren)
2. ✅ **courses.json + lessons/*.json** befüllen (deine Texte einfügen)
3. ✅ **Workbook PDFs** erstellen und hochladen
4. ✅ **Audio MP3s** in R2 oder Server hochladen
5. ✅ **Domain api.genselfcore.de** → Server zeigen
6. ✅ App testet → Inhalte erscheinen automatisch

**Ohne Server:** Die App zeigt automatisch die Preview-Daten aus `Lesson.swift` an.
Du kannst also erst die App launchen und den Server später aufbauen!
