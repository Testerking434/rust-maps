// ============================================================
// GEN:SELFCORE — server.js
// Läuft auf Port 3001 (deine andere App läuft auf 3000)
// ============================================================

'use strict';

const express    = require('express');
const bcrypt     = require('bcryptjs');
const jwt        = require('jsonwebtoken');
const cors       = require('cors');
const path       = require('path');
const fs         = require('fs');
const crypto     = require('crypto');
const nodemailer = require('nodemailer');

const app  = express();
const PORT = process.env.PORT || 8001;
const JWT_SECRET = process.env.JWT_SECRET || 'AENDER_MICH_VOR_PRODUKTIONSSTART';

// ============================================================
// CLOUDFLARE R2 KONFIGURATION (für Audio-Streaming)
// ============================================================
const R2_ACCOUNT_ID   = process.env.R2_ACCOUNT_ID || '';
const R2_ACCESS_KEY   = process.env.R2_ACCESS_KEY || '';
const R2_SECRET_KEY   = process.env.R2_SECRET_KEY || '';
const R2_BUCKET       = process.env.R2_BUCKET || 'selfcore-audio';
const R2_PUBLIC_URL   = process.env.R2_PUBLIC_URL || `https://${R2_BUCKET}.${R2_ACCOUNT_ID}.r2.cloudflarestorage.com`;

// ============================================================
// E-MAIL KONFIGURATION (Passwort-Reset)
// ============================================================
const SMTP_HOST = process.env.SMTP_HOST || 'smtp.gmail.com';
const SMTP_PORT = process.env.SMTP_PORT || 587;
const SMTP_USER = process.env.SMTP_USER || '';
const SMTP_PASS = process.env.SMTP_PASS || '';
const SMTP_FROM = process.env.SMTP_FROM || 'noreply@genselfcore.de';

const mailTransporter = SMTP_USER ? nodemailer.createTransport({
  host: SMTP_HOST,
  port: SMTP_PORT,
  secure: false,
  auth: { user: SMTP_USER, pass: SMTP_PASS }
}) : null;

// ============================================================
// DATENPERSISTENZ — JSON-Dateien statt In-Memory
// ============================================================
const DB_DIR = path.join(__dirname, 'db');
if (!fs.existsSync(DB_DIR)) fs.mkdirSync(DB_DIR, { recursive: true });

function loadDB(name) {
  const p = path.join(DB_DIR, `${name}.json`);
  try {
    if (fs.existsSync(p)) return JSON.parse(fs.readFileSync(p, 'utf8'));
  } catch (e) { console.error(`DB load error (${name}):`, e.message); }
  return null;
}

function saveDB(name, data) {
  const p = path.join(DB_DIR, `${name}.json`);
  try {
    fs.writeFileSync(p, JSON.stringify(data, null, 2), 'utf8');
  } catch (e) { console.error(`DB save error (${name}):`, e.message); }
}

// Periodisch speichern (alle 30 Sekunden)
setInterval(() => {
  saveDB('users', users);
  saveDB('userById', userById);
  saveDB('referrals_simple', Object.fromEntries(
    Object.entries(referrals).map(([k, v]) => [k, { ...v, badgeTitles: [...(v.badgeTitles || [])] }])
  ));
  saveDB('codeToUser', codeToUser);
  saveDB('signalExtensions', signalExtensions);
  saveDB('userReferredBy', userReferredBy);
  saveDB('userSubscriptions', userSubscriptions);
  saveDB('userDnaResults', userDnaResults);
  saveDB('userProgress', userProgress);
  saveDB('passwordResetTokens', passwordResetTokens);
}, 30000);

app.use(cors());
app.use(express.json());

// ============================================================
// IN-MEMORY DATENBANK
// Für Produktion: PostgreSQL (Anleitung am Ende der Datei)
// ============================================================

// Daten laden (oder leer starten)
const users             = loadDB('users')             || {};
const userById          = loadDB('userById')          || {};
const codeToUser        = loadDB('codeToUser')        || {};
const signalExtensions  = loadDB('signalExtensions')  || {};
const userReferredBy    = loadDB('userReferredBy')    || {};
const userSubscriptions = loadDB('userSubscriptions') || {};
const userDnaResults    = loadDB('userDnaResults')    || {};
const userProgress      = loadDB('userProgress')      || {}; // { userId: { lessonId: { completed, completedAt } } }
const passwordResetTokens = loadDB('passwordResetTokens') || {}; // { token: { email, expiresAt } }

// Referrals mit Set-Wiederherstellung
const referrals_raw = loadDB('referrals_simple') || {};
const referrals     = {};
for (const [k, v] of Object.entries(referrals_raw)) {
  referrals[k] = { ...v, badgeTitles: new Set(v.badgeTitles || []) };
}

// Flüchtige Daten (brauchen keine Persistenz)
const processedReferrals = new Set(); // "newUserId:referralCode"
const rewardIDs         = new Set();
const registrationLocks = new Set();
const idempotencyCache  = {};   // { key: { response, expiresAt } }

console.log(`📂 Datenbank geladen: ${Object.keys(users).length} User, ${Object.keys(userSubscriptions).length} Abos`);

// ============================================================
// ABO-STUFEN / SUBSCRIPTION TIERS
// ============================================================

const ABO_TIERS = {
  FREE: {
    id: 'FREE',
    name: 'Kostenlos',
    price: 0,
    features: ['Profil erstellen', 'DNA-Test machen', '1 Probe-Lektion pro Kurs'],
    maxCourses: 0,
    signalAccess: false
  },
  START: {
    id: 'START',
    name: 'START',
    priceMonthly: 9.99,
    priceYearly: 89.99,
    features: ['1 Kurs nach Wahl (DNA-Empfehlung)', 'Alle Lektionen des Kurses', 'PDF-Workbooks'],
    maxCourses: 1,
    signalAccess: false
  },
  PRO: {
    id: 'PRO',
    name: 'PRO',
    priceMonthly: 19.99,
    priceYearly: 179.99,
    features: ['3 Kurse nach Wahl', 'Alle Lektionen', 'PDF-Workbooks', 'GEN:SIGNAL Basic (3 Tracks)'],
    maxCourses: 3,
    signalAccess: true,
    signalTrackLimit: 3
  },
  COMPLETE: {
    id: 'COMPLETE',
    name: 'COMPLETE',
    priceMonthly: 29.99,
    priceYearly: 249.99,
    features: ['Alle 5 Kurse', 'Alle Lektionen', 'PDF-Workbooks', 'GEN:SIGNAL Komplett (alle Tracks)', 'Priority Support'],
    maxCourses: 5,
    signalAccess: true,
    signalTrackLimit: -1 // unlimited
  }
};

// Einmalzahlung-Preise (one-time purchase)
const EINMALZAHLUNG = {
  course: {
    price: 49.99,
    description: 'Einzelner Kurs — einmaliger Kauf, lebenslanger Zugang'
  },
  signal_bundle: {
    price: 79.99,
    description: 'GEN:SIGNAL Komplett — alle Tracks, einmaliger Kauf',
    notice: 'Digitales Produkt — kein Widerrufsrecht nach Freischaltung (§ 356 Abs. 5 BGB). Mit dem Kauf stimmst du zu, dass die Bereitstellung sofort beginnt und du auf dein Widerrufsrecht verzichtest.'
  },
  signal_single: {
    price: 14.99,
    description: 'Einzelner GEN:SIGNAL Track — einmaliger Kauf',
    notice: 'Digitales Produkt — kein Widerrufsrecht nach Freischaltung (§ 356 Abs. 5 BGB). Mit dem Kauf stimmst du zu, dass die Bereitstellung sofort beginnt und du auf dein Widerrufsrecht verzichtest.'
  }
};

// Alle 5 Kurse
const ALL_COURSES = [
  {
    id: 'awakening',
    title: 'AWAKENING',
    subtitle: 'Erwache zu dir selbst',
    description: 'Der erste Schritt: Erkenne wer du wirklich bist und lege falsche Masken ab.',
    lessonCount: 42,
    color: '#F5A623',
    icon: 'sun.rise.fill',
    dimension: 'selbstkenntnis',
    coverImageURL: ''
  },
  {
    id: 'origin',
    title: 'ORIGIN',
    subtitle: 'Verstehe deine Wurzeln',
    description: 'Deine Vergangenheit erklärt deine Gegenwart. Verarbeite, was dich geformt hat.',
    lessonCount: 36,
    color: '#FF6B9D',
    icon: 'tree.fill',
    dimension: 'authentizitaet',
    coverImageURL: ''
  },
  {
    id: 'genesis',
    title: 'GENESIS',
    subtitle: 'Erschaffe neu',
    description: 'Aus den Trümmern alter Muster entsteht eine neue Version von dir.',
    lessonCount: 38,
    color: '#4A90D9',
    icon: 'sparkles',
    dimension: 'klarheit',
    coverImageURL: ''
  },
  {
    id: 'foundation',
    title: 'FOUNDATION',
    subtitle: 'Baue unerschütterlich',
    description: 'Fundamentale Gewohnheiten und Überzeugungen die dich tragen.',
    lessonCount: 35,
    color: '#FF6B35',
    icon: 'building.columns.fill',
    dimension: 'mut',
    coverImageURL: ''
  },
  {
    id: 'core-journey',
    title: 'CORE JOURNEY',
    subtitle: 'Deine finale Transformation',
    description: 'Alles kommt zusammen. Du wirst nicht derselbe sein wie vorher.',
    lessonCount: 40,
    color: '#5CB85C',
    icon: 'star.fill',
    dimension: 'verbindung',
    coverImageURL: ''
  }
];

// DNA-Test → Persönlichkeitstyp-Zuordnung und Kurs-Empfehlung
const DNA_TYPE_MAP = {
  PIONEER:   { dimension: 'mut',            recommendedCourse: 'foundation', description: 'Du siehst Wege, die andere nicht sehen.' },
  GUARDIAN:  { dimension: 'klarheit',       recommendedCourse: 'genesis',    description: 'Deine Stärke liegt im Schutz des Wesentlichen.' },
  CREATOR:   { dimension: 'authentizitaet', recommendedCourse: 'origin',     description: 'Du erschaffst Welten aus reiner Vorstellungskraft.' },
  CONNECTOR: { dimension: 'verbindung',     recommendedCourse: 'core-journey', description: 'Deine Energie verbindet Menschen mit Tiefe.' },
  ACHIEVER:  { dimension: 'selbstkenntnis', recommendedCourse: 'awakening',  description: 'Du verwandelst Ziele in Realität.' }
};

// ============================================================
// HILFSFUNKTIONEN
// ============================================================

function generateReferralCode(name = '') {
  const base = (name.substring(0, 3).toUpperCase().replace(/[^A-Z]/g, 'X')) || 'REF';
  const suffix = Math.random().toString(36).substring(2, 5).toUpperCase();
  const code = base + suffix;
  return codeToUser[code] ? generateReferralCode(name) : code; // Kollision vermeiden
}

function createRewardId(prefix = 'reward') {
  let id;
  do { id = prefix + '_' + Date.now() + '_' + Math.random().toString(36).substring(2, 7); }
  while (rewardIDs.has(id));
  rewardIDs.add(id);
  return id;
}

function authMiddleware(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Nicht autorisiert.' });
  }
  try {
    req.user = jwt.verify(header.split(' ')[1], JWT_SECRET);
    next();
  } catch {
    return res.status(401).json({ error: 'Token ungültig oder abgelaufen.' });
  }
}

// Idempotency-Cache prüfen & setzen
function checkIdempotency(req, res, next) {
  const key = req.headers['idempotency-key'];
  if (!key) return next();
  const now = Date.now();
  // Abgelaufene Einträge löschen
  Object.keys(idempotencyCache).forEach(k => {
    if (idempotencyCache[k].expiresAt < now) delete idempotencyCache[k];
  });
  if (idempotencyCache[key]) {
    return res.status(200).json(idempotencyCache[key].response);
  }
  res.sendCachedResponse = (data) => {
    idempotencyCache[key] = { response: data, expiresAt: now + 30 * 60 * 1000 }; // 30 Min TTL
  };
  next();
}

// ============================================================
// HEALTH CHECK
// ============================================================

app.get('/health', (_, res) => res.json({ status: 'ok', app: 'GEN:SELFCORE', port: PORT }));

// ============================================================
// AUTH — REGISTRIERUNG
// ============================================================

app.post('/v1/auth/register', checkIdempotency, async (req, res) => {
  const { name, email, password, referralCode } = req.body;

  if (!email || !password || !name) {
    return res.status(400).json({ error: 'Name, E-Mail und Passwort erforderlich.' });
  }

  const normEmail = email.toLowerCase().trim();

  // Race Condition verhindern
  if (registrationLocks.has(normEmail)) {
    return res.status(429).json({ error: 'Registrierung läuft bereits. Bitte warten.' });
  }
  registrationLocks.add(normEmail);

  try {
    // E-Mail bereits registriert?
    if (users[normEmail]) {
      return res.status(409).json({ error: 'Diese E-Mail ist bereits registriert.' });
    }

    const passwordHash = await bcrypt.hash(password, 12);
    const newUserId    = 'u_' + Date.now() + '_' + Math.random().toString(36).substring(2, 7);
    const token        = jwt.sign({ userId: newUserId, email: normEmail }, JWT_SECRET, { expiresIn: '90d' });

    const userData = {
      id: newUserId,
      name: name.trim(),
      email: normEmail,
      passwordHash,
      selfcoreType: null,  // wird durch DNA-Test gesetzt
      dimensions: { selbstkenntnis: 5, authentizitaet: 5, klarheit: 5, mut: 5, verbindung: 5 },
      createdAt: new Date().toISOString(),
      avatarColor: '#F5A623',
      bio: ''
    };

    users[normEmail] = userData;
    userById[newUserId] = userData;

    // Abo: Start als FREE
    userSubscriptions[newUserId] = {
      tier: 'FREE',
      activeSince: new Date().toISOString(),
      expiresAt: null,
      selectedCourseIds: [],
      purchasedCourseIds: [],
      purchasedSignalTrackIds: [],
      purchasedSignalBundle: false,
      billingType: null  // 'monthly', 'yearly', oder 'einmalig'
    };

    // Referral verarbeiten
    let signalFreeDays = 0;
    if (referralCode) {
      const result = processReferral(newUserId, referralCode.toUpperCase().trim(), name.trim());
      if (result.success) {
        signalExtensions[newUserId] = (signalExtensions[newUserId] || 0) + 3;
        signalFreeDays = 3;
      }
    }

    const sub = userSubscriptions[newUserId];
    const responseData = {
      token,
      user: {
        id: newUserId,
        name: userData.name,
        email: normEmail,
        selfcoreType: userData.selfcoreType,
        dimensions: userData.dimensions,
        avatarColor: userData.avatarColor,
        bio: userData.bio
      },
      subscription: {
        tier: sub.tier,
        tierInfo: ABO_TIERS[sub.tier],
        selectedCourseIds: sub.selectedCourseIds,
        purchasedCourseIds: sub.purchasedCourseIds,
        purchasedSignalBundle: sub.purchasedSignalBundle
      },
      signalFreeDays,
      dnaTestCompleted: false
    };

    if (res.sendCachedResponse) res.sendCachedResponse(responseData);
    return res.status(201).json(responseData);

  } finally {
    registrationLocks.delete(normEmail);
  }
});

// ============================================================
// AUTH — LOGIN
// ============================================================

app.post('/v1/auth/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'E-Mail und Passwort erforderlich.' });

  const normEmail = email.toLowerCase().trim();
  const userData  = users[normEmail];

  if (!userData) return res.status(401).json({ error: 'E-Mail oder Passwort falsch.' });

  const valid = await bcrypt.compare(password, userData.passwordHash);
  if (!valid)  return res.status(401).json({ error: 'E-Mail oder Passwort falsch.' });

  const token = jwt.sign({ userId: userData.id, email: normEmail }, JWT_SECRET, { expiresIn: '90d' });

  const sub = userSubscriptions[userData.id] || { tier: 'FREE', selectedCourseIds: [], purchasedCourseIds: [], purchasedSignalBundle: false };
  const dna = userDnaResults[userData.id];

  return res.json({
    token,
    user: {
      id: userData.id,
      name: userData.name,
      email: normEmail,
      selfcoreType: userData.selfcoreType,
      dimensions: userData.dimensions,
      avatarColor: userData.avatarColor || '#F5A623',
      bio: userData.bio || ''
    },
    subscription: {
      tier: sub.tier,
      tierInfo: ABO_TIERS[sub.tier],
      selectedCourseIds: sub.selectedCourseIds,
      purchasedCourseIds: sub.purchasedCourseIds,
      purchasedSignalBundle: sub.purchasedSignalBundle
    },
    dnaTestCompleted: !!dna
  });
});

// ============================================================
// AUTH — PASSWORT RESET (E-Mail senden — TODO: echten Mailer einbauen)
// ============================================================

app.post('/v1/auth/reset-password', async (req, res) => {
  const email = (req.body.email || '').toLowerCase().trim();
  // Security: immer 200 zurückgeben, egal ob E-Mail existiert
  const response = { message: 'Falls diese E-Mail registriert ist, wurde ein Link gesendet.' };

  if (!email) return res.json(response);

  const user = users[email];
  if (!user) return res.json(response); // nicht verraten ob E-Mail existiert

  // Reset-Token generieren (gültig 1 Stunde)
  const token = crypto.randomBytes(32).toString('hex');
  passwordResetTokens[token] = {
    email,
    expiresAt: Date.now() + 60 * 60 * 1000 // 1 Stunde
  };

  const resetLink = `https://genselfcore.de/reset?token=${token}`;
  console.log(`🔑 Password reset for ${email}: ${resetLink}`);

  // E-Mail senden (falls konfiguriert)
  if (mailTransporter) {
    try {
      await mailTransporter.sendMail({
        from: SMTP_FROM,
        to: email,
        subject: 'GEN:SELFCORE — Passwort zurücksetzen',
        html: `
          <div style="background:#0A0A0A;color:white;padding:40px;font-family:Arial,sans-serif;">
            <h1 style="color:#F5A623;">GEN:SELFCORE</h1>
            <p>Du hast ein neues Passwort angefordert.</p>
            <p><a href="${resetLink}" style="display:inline-block;padding:12px 30px;background:#F5A623;color:#000;border-radius:8px;text-decoration:none;font-weight:bold;">Passwort zurücksetzen</a></p>
            <p style="color:#888;font-size:12px;">Dieser Link ist 1 Stunde gültig. Falls du keinen Reset angefordert hast, ignoriere diese E-Mail.</p>
          </div>
        `
      });
      console.log(`✅ Reset-E-Mail gesendet an ${email}`);
    } catch (e) {
      console.error(`❌ E-Mail-Fehler:`, e.message);
    }
  }

  return res.json(response);
});

// Passwort tatsächlich zurücksetzen
app.post('/v1/auth/reset-password/confirm', async (req, res) => {
  const { token, newPassword } = req.body;
  if (!token || !newPassword) return res.status(400).json({ error: 'Token und neues Passwort erforderlich.' });
  if (newPassword.length < 6) return res.status(400).json({ error: 'Passwort muss mindestens 6 Zeichen lang sein.' });

  const resetData = passwordResetTokens[token];
  if (!resetData || resetData.expiresAt < Date.now()) {
    return res.status(400).json({ error: 'Token ungültig oder abgelaufen.' });
  }

  const user = users[resetData.email];
  if (!user) return res.status(400).json({ error: 'User nicht gefunden.' });

  user.passwordHash = await bcrypt.hash(newPassword, 12);
  delete passwordResetTokens[token];

  console.log(`✅ Passwort geändert für ${resetData.email}`);
  return res.json({ message: 'Passwort erfolgreich geändert. Du kannst dich jetzt einloggen.' });
});

// ============================================================
// USER — PROFIL
// ============================================================

app.get('/v1/user/profile', authMiddleware, (req, res) => {
  const user = userById[req.user.userId];
  if (!user) return res.status(404).json({ error: 'User nicht gefunden.' });

  const sub = userSubscriptions[req.user.userId] || { tier: 'FREE', selectedCourseIds: [], purchasedCourseIds: [], purchasedSignalTrackIds: [], purchasedSignalBundle: false };
  const dna = userDnaResults[req.user.userId];

  return res.json({
    id: user.id,
    name: user.name,
    email: user.email,
    selfcoreType: user.selfcoreType,
    dimensions: user.dimensions,
    avatarColor: user.avatarColor || '#F5A623',
    bio: user.bio || '',
    createdAt: user.createdAt,
    subscription: {
      tier: sub.tier,
      tierInfo: ABO_TIERS[sub.tier],
      activeSince: sub.activeSince,
      expiresAt: sub.expiresAt,
      billingType: sub.billingType,
      selectedCourseIds: sub.selectedCourseIds,
      purchasedCourseIds: sub.purchasedCourseIds,
      purchasedSignalTrackIds: sub.purchasedSignalTrackIds,
      purchasedSignalBundle: sub.purchasedSignalBundle
    },
    dnaTestCompleted: !!dna,
    dnaResult: dna ? { type: dna.type, recommendedCourseId: dna.recommendedCourseId } : null
  });
});

// Profil bearbeiten (Name, Avatar, Bio)
app.put('/v1/user/profile', authMiddleware, (req, res) => {
  const user = userById[req.user.userId];
  if (!user) return res.status(404).json({ error: 'User nicht gefunden.' });

  const { name, avatarColor, bio } = req.body;
  if (name !== undefined) user.name = name.trim();
  if (avatarColor !== undefined) user.avatarColor = avatarColor;
  if (bio !== undefined) user.bio = bio.substring(0, 500); // max 500 Zeichen

  return res.json({
    id: user.id,
    name: user.name,
    email: user.email,
    selfcoreType: user.selfcoreType,
    dimensions: user.dimensions,
    avatarColor: user.avatarColor,
    bio: user.bio
  });
});

// Alle 5 Kurse — mit Zugangsinfo pro User
app.get('/v1/user/courses', authMiddleware, (req, res) => {
  const userId = req.user.userId;
  const sub = userSubscriptions[userId] || { tier: 'FREE', selectedCourseIds: [], purchasedCourseIds: [] };
  const dna = userDnaResults[userId];

  const courses = ALL_COURSES.map(course => {
    // Zugang prüfen: Abo-Tier ODER Einzelkauf
    const isSelectedInAbo = sub.selectedCourseIds.includes(course.id);
    const isPurchased = sub.purchasedCourseIds.includes(course.id);
    const isComplete = sub.tier === 'COMPLETE';
    const hasAccess = isComplete || isSelectedInAbo || isPurchased;

    // DNA-Empfehlung
    const isRecommended = dna && dna.recommendedCourseId === course.id;

    return {
      ...course,
      isUnlocked: hasAccess,
      accessType: isPurchased ? 'purchased' : (isComplete ? 'complete_tier' : (isSelectedInAbo ? 'abo_selected' : 'locked')),
      isRecommended,
      canPurchaseSingle: !hasAccess,
      singlePurchasePrice: EINMALZAHLUNG.course.price
    };
  });

  return res.json(courses);
});

app.get('/v1/user/signal-status', authMiddleware, (req, res) => {
  const userId = req.user.userId;
  const sub = userSubscriptions[userId] || { tier: 'FREE', purchasedSignalTrackIds: [], purchasedSignalBundle: false };
  const freeDays = signalExtensions[userId] || 0;
  const tierInfo = ABO_TIERS[sub.tier];
  const hasSignalViaTier = tierInfo && tierInfo.signalAccess;
  const hasSignalViaPurchase = sub.purchasedSignalBundle;

  return res.json({
    isSubscribed: hasSignalViaTier,
    hasPurchasedBundle: hasSignalViaPurchase,
    purchasedTrackIds: sub.purchasedSignalTrackIds || [],
    freeDaysRemaining: freeDays,
    hasAccess: hasSignalViaTier || hasSignalViaPurchase || freeDays > 0,
    trackLimit: tierInfo ? tierInfo.signalTrackLimit : 0,
    notice: EINMALZAHLUNG.signal_bundle.notice
  });
});

app.get('/v1/user/weekly-stats', authMiddleware, (req, res) => {
  return res.json({ checkInsCount: 0, actionsCompleted: 0, dominantMood: null, dimensionChanges: {} });
});

// ============================================================
// AUTH — LOGOUT
// ============================================================

app.post('/v1/auth/logout', authMiddleware, (req, res) => res.json({ message: 'Abgemeldet.' }));

// ============================================================
// CHECK-INS
// ============================================================

const checkIns = {}; // { userId: [CheckIn] }

app.post('/v1/checkins', authMiddleware, (req, res) => {
  const userId = req.user.userId;
  if (!checkIns[userId]) checkIns[userId] = [];
  checkIns[userId].push({ ...req.body, savedAt: new Date().toISOString() });
  return res.json({ message: 'Check-in gespeichert.' });
});

// ============================================================
// KURSE & LEKTIONEN
// ============================================================

app.get('/v1/courses/:courseId/lessons', authMiddleware, (req, res) => {
  try {
    const p = path.join(__dirname, 'data', 'lessons', `${req.params.courseId}.json`);
    if (fs.existsSync(p)) return res.json(JSON.parse(fs.readFileSync(p, 'utf8')));
  } catch {}
  return res.json([]);
});

app.get('/v1/courses/:courseId/lessons/:lessonId', authMiddleware, (req, res) => {
  try {
    const p = path.join(__dirname, 'data', 'lessons', req.params.courseId, `${req.params.lessonId}.json`);
    if (fs.existsSync(p)) return res.json(JSON.parse(fs.readFileSync(p, 'utf8')));
  } catch {}
  return res.status(404).json({ error: 'Lektion nicht gefunden.' });
});

app.get('/v1/lessons/:lessonId/workbook-url', authMiddleware, (req, res) => {
  const fileKey = `workbooks/${req.params.lessonId}.pdf`;
  const url = generateR2SignedUrl(fileKey);
  return res.json({ url });
});

// Lektion als abgeschlossen markieren (mit Persistenz)
app.post('/v1/lessons/:lessonId/complete', authMiddleware, (req, res) => {
  const userId = req.user.userId;
  const lessonId = req.params.lessonId;

  if (!userProgress[userId]) userProgress[userId] = {};

  if (userProgress[userId][lessonId]) {
    return res.json({ message: 'Lektion war bereits abgeschlossen.', alreadyCompleted: true });
  }

  userProgress[userId][lessonId] = {
    completed: true,
    completedAt: new Date().toISOString()
  };

  // Sofort speichern
  saveDB('userProgress', userProgress);

  const totalCompleted = Object.keys(userProgress[userId]).length;
  console.log(`✅ Lektion abgeschlossen: User ${userId} → ${lessonId} (gesamt: ${totalCompleted})`);

  return res.json({
    message: 'Lektion als abgeschlossen markiert!',
    lessonId,
    totalCompleted,
    completedAt: userProgress[userId][lessonId].completedAt
  });
});

// Fortschritt abrufen
app.get('/v1/user/progress', authMiddleware, (req, res) => {
  const userId = req.user.userId;
  const progress = userProgress[userId] || {};

  // Pro Kurs aufschlüsseln
  const courseProgress = {};
  for (const course of ALL_COURSES) {
    const prefix = course.id === 'awakening' ? 'aw-' :
                   course.id === 'origin' ? 'or-' :
                   course.id === 'genesis' ? 'ge-' :
                   course.id === 'foundation' ? 'fo-' :
                   course.id === 'core-journey' ? 'cj-' : '';

    const completedLessons = Object.keys(progress).filter(id => id.startsWith(prefix)).length;
    courseProgress[course.id] = {
      completedLessons,
      totalLessons: course.lessonCount,
      percent: course.lessonCount > 0 ? Math.round((completedLessons / course.lessonCount) * 100) : 0,
      isCompleted: completedLessons >= course.lessonCount
    };
  }

  return res.json({
    totalLessonsCompleted: Object.keys(progress).length,
    completedLessonIds: Object.keys(progress),
    courseProgress
  });
});

// ============================================================
// ABO — PREISE & OPTIONEN ABRUFEN
// ============================================================

app.get('/v1/abo/tiers', (req, res) => {
  return res.json({
    tiers: ABO_TIERS,
    einmalzahlung: EINMALZAHLUNG,
    courses: ALL_COURSES.map(c => ({ id: c.id, title: c.title, subtitle: c.subtitle, description: c.description, color: c.color, icon: c.icon, dimension: c.dimension }))
  });
});

// Aktuelles Abo des Users
app.get('/v1/abo/status', authMiddleware, (req, res) => {
  const sub = userSubscriptions[req.user.userId] || { tier: 'FREE', selectedCourseIds: [], purchasedCourseIds: [], purchasedSignalTrackIds: [], purchasedSignalBundle: false };
  return res.json({
    tier: sub.tier,
    tierInfo: ABO_TIERS[sub.tier],
    activeSince: sub.activeSince,
    expiresAt: sub.expiresAt,
    billingType: sub.billingType,
    selectedCourseIds: sub.selectedCourseIds,
    purchasedCourseIds: sub.purchasedCourseIds,
    purchasedSignalTrackIds: sub.purchasedSignalTrackIds,
    purchasedSignalBundle: sub.purchasedSignalBundle,
    availableUpgrades: getAvailableUpgrades(sub.tier)
  });
});

function getAvailableUpgrades(currentTier) {
  const order = ['FREE', 'START', 'PRO', 'COMPLETE'];
  const idx = order.indexOf(currentTier);
  return order.slice(idx + 1).map(t => ({ tier: t, ...ABO_TIERS[t] }));
}

// ============================================================
// ABO — ABONNIEREN / UPGRADEN
// ============================================================

app.post('/v1/abo/subscribe', checkIdempotency, authMiddleware, (req, res) => {
  const userId = req.user.userId;
  const { tier, billingType, selectedCourseIds } = req.body;

  // Validierung
  if (!ABO_TIERS[tier] || tier === 'FREE') {
    return res.status(400).json({ error: 'Ungültiges Abo-Tier.' });
  }
  if (!['monthly', 'yearly'].includes(billingType)) {
    return res.status(400).json({ error: 'billingType muss "monthly" oder "yearly" sein.' });
  }

  const tierInfo = ABO_TIERS[tier];

  // Kurs-Auswahl validieren
  const courseIds = selectedCourseIds || [];
  const validCourseIds = courseIds.filter(id => ALL_COURSES.some(c => c.id === id));
  if (tier !== 'COMPLETE' && validCourseIds.length > tierInfo.maxCourses) {
    return res.status(400).json({
      error: `Tier ${tier} erlaubt maximal ${tierInfo.maxCourses} Kurs(e). Du hast ${validCourseIds.length} ausgewählt.`
    });
  }

  // Abo aktivieren
  const sub = userSubscriptions[userId] || {};
  const now = new Date();
  const expiresAt = new Date(now);
  if (billingType === 'monthly') expiresAt.setMonth(expiresAt.getMonth() + 1);
  else expiresAt.setFullYear(expiresAt.getFullYear() + 1);

  userSubscriptions[userId] = {
    ...sub,
    tier,
    activeSince: now.toISOString(),
    expiresAt: expiresAt.toISOString(),
    billingType,
    selectedCourseIds: tier === 'COMPLETE' ? ALL_COURSES.map(c => c.id) : validCourseIds,
    purchasedCourseIds: sub.purchasedCourseIds || [],
    purchasedSignalTrackIds: sub.purchasedSignalTrackIds || [],
    purchasedSignalBundle: sub.purchasedSignalBundle || false
  };

  console.log(`✅ Abo: User ${userId} → ${tier} (${billingType}), Kurse: ${validCourseIds.join(', ')}`);

  const responseData = {
    message: `Abo ${tier} erfolgreich aktiviert!`,
    subscription: {
      tier,
      tierInfo: ABO_TIERS[tier],
      activeSince: userSubscriptions[userId].activeSince,
      expiresAt: userSubscriptions[userId].expiresAt,
      billingType,
      selectedCourseIds: userSubscriptions[userId].selectedCourseIds
    }
  };

  if (res.sendCachedResponse) res.sendCachedResponse(responseData);
  return res.json(responseData);
});

// Kurse im Abo ändern (z.B. nach DNA-Test anderen Kurs wählen)
app.put('/v1/abo/courses', authMiddleware, (req, res) => {
  const userId = req.user.userId;
  const sub = userSubscriptions[userId];
  if (!sub || sub.tier === 'FREE') {
    return res.status(403).json({ error: 'Du brauchst mindestens ein START-Abo um Kurse auszuwählen.' });
  }
  if (sub.tier === 'COMPLETE') {
    return res.json({ message: 'COMPLETE-Abo hat bereits alle Kurse.', selectedCourseIds: sub.selectedCourseIds });
  }

  const { selectedCourseIds } = req.body;
  const tierInfo = ABO_TIERS[sub.tier];
  const validIds = (selectedCourseIds || []).filter(id => ALL_COURSES.some(c => c.id === id));

  if (validIds.length > tierInfo.maxCourses) {
    return res.status(400).json({ error: `Tier ${sub.tier} erlaubt maximal ${tierInfo.maxCourses} Kurs(e).` });
  }

  sub.selectedCourseIds = validIds;
  return res.json({ message: 'Kurs-Auswahl aktualisiert.', selectedCourseIds: validIds });
});

// ============================================================
// EINMALZAHLUNG — KURS EINZELN KAUFEN
// ============================================================

app.post('/v1/purchase/course', checkIdempotency, authMiddleware, (req, res) => {
  const userId = req.user.userId;
  const { courseId, paymentToken } = req.body;

  // Kurs existiert?
  const course = ALL_COURSES.find(c => c.id === courseId);
  if (!course) return res.status(404).json({ error: 'Kurs nicht gefunden.' });

  // Bereits gekauft?
  const sub = userSubscriptions[userId] || {};
  if ((sub.purchasedCourseIds || []).includes(courseId)) {
    return res.status(409).json({ error: 'Kurs bereits gekauft.' });
  }

  // TODO: Echte Zahlungsvalidierung (Apple IAP Receipt / Stripe)
  // paymentToken wird hier vorerst akzeptiert

  if (!sub.purchasedCourseIds) sub.purchasedCourseIds = [];
  sub.purchasedCourseIds.push(courseId);
  userSubscriptions[userId] = { ...userSubscriptions[userId], ...sub };

  console.log(`✅ Einzelkauf: User ${userId} → Kurs "${courseId}" für ${EINMALZAHLUNG.course.price}€`);

  const responseData = {
    message: `Kurs "${course.title}" erfolgreich gekauft! Lebenslanger Zugang.`,
    courseId,
    price: EINMALZAHLUNG.course.price,
    accessType: 'purchased',
    purchasedCourseIds: sub.purchasedCourseIds
  };

  if (res.sendCachedResponse) res.sendCachedResponse(responseData);
  return res.json(responseData);
});

// ============================================================
// EINMALZAHLUNG — GEN:SIGNAL (Audio) KAUFEN
// ============================================================

app.post('/v1/purchase/signal', checkIdempotency, authMiddleware, (req, res) => {
  const userId = req.user.userId;
  const { type, trackId, paymentToken } = req.body;
  // type: 'bundle' oder 'single'

  const sub = userSubscriptions[userId] || {};

  if (type === 'bundle') {
    if (sub.purchasedSignalBundle) {
      return res.status(409).json({ error: 'GEN:SIGNAL Bundle bereits gekauft.' });
    }

    sub.purchasedSignalBundle = true;
    userSubscriptions[userId] = { ...userSubscriptions[userId], ...sub };

    console.log(`✅ Signal-Bundle: User ${userId} → Komplett-Paket für ${EINMALZAHLUNG.signal_bundle.price}€`);

    const responseData = {
      message: 'GEN:SIGNAL Komplett-Paket erfolgreich gekauft! Lebenslanger Zugang zu allen Tracks.',
      price: EINMALZAHLUNG.signal_bundle.price,
      notice: EINMALZAHLUNG.signal_bundle.notice,
      purchasedSignalBundle: true
    };

    if (res.sendCachedResponse) res.sendCachedResponse(responseData);
    return res.json(responseData);

  } else if (type === 'single') {
    if (!trackId) return res.status(400).json({ error: 'trackId erforderlich für Einzelkauf.' });

    if (!sub.purchasedSignalTrackIds) sub.purchasedSignalTrackIds = [];
    if (sub.purchasedSignalTrackIds.includes(trackId)) {
      return res.status(409).json({ error: 'Track bereits gekauft.' });
    }

    sub.purchasedSignalTrackIds.push(trackId);
    userSubscriptions[userId] = { ...userSubscriptions[userId], ...sub };

    console.log(`✅ Signal-Track: User ${userId} → Track "${trackId}" für ${EINMALZAHLUNG.signal_single.price}€`);

    const responseData = {
      message: `Track erfolgreich gekauft! Lebenslanger Zugang.`,
      trackId,
      price: EINMALZAHLUNG.signal_single.price,
      notice: EINMALZAHLUNG.signal_single.notice,
      purchasedSignalTrackIds: sub.purchasedSignalTrackIds
    };

    if (res.sendCachedResponse) res.sendCachedResponse(responseData);
    return res.json(responseData);

  } else {
    return res.status(400).json({ error: 'type muss "bundle" oder "single" sein.' });
  }
});

// ============================================================
// DNA-TEST — PERSÖNLICHKEITSTEST & KURS-EMPFEHLUNG
// ============================================================

app.post('/v1/dna-test/submit', authMiddleware, (req, res) => {
  const userId = req.user.userId;
  const { answers } = req.body;

  // answers: Array von { questionId, value (1-10) } — mindestens 10 Fragen
  if (!answers || !Array.isArray(answers) || answers.length < 10) {
    return res.status(400).json({ error: 'Mindestens 10 Antworten erforderlich.' });
  }

  // Dimensionen berechnen aus Antworten
  // Jede Antwort hat eine questionId die einer Dimension zugeordnet ist
  const dimScores = { selbstkenntnis: [], authentizitaet: [], klarheit: [], mut: [], verbindung: [] };
  const dimKeys = Object.keys(dimScores);

  answers.forEach((a, i) => {
    const dim = a.dimension || dimKeys[i % 5];
    if (dimScores[dim]) dimScores[dim].push(Math.max(1, Math.min(10, a.value || 5)));
  });

  const dimensions = {};
  for (const [dim, scores] of Object.entries(dimScores)) {
    dimensions[dim] = scores.length > 0
      ? Math.round((scores.reduce((a, b) => a + b, 0) / scores.length) * 10) / 10
      : 5;
  }

  // Stärkste Dimension → Persönlichkeitstyp
  const dimToType = {
    selbstkenntnis: 'ACHIEVER',
    authentizitaet: 'CREATOR',
    klarheit: 'GUARDIAN',
    mut: 'PIONEER',
    verbindung: 'CONNECTOR'
  };

  let maxDim = 'selbstkenntnis';
  let maxVal = 0;
  for (const [dim, val] of Object.entries(dimensions)) {
    if (val > maxVal) { maxVal = val; maxDim = dim; }
  }

  const selfcoreType = dimToType[maxDim];
  const typeInfo = DNA_TYPE_MAP[selfcoreType];
  const recommendedCourseId = typeInfo.recommendedCourse;
  const recommendedCourse = ALL_COURSES.find(c => c.id === recommendedCourseId);

  // User-Daten updaten
  const user = userById[userId];
  if (user) {
    user.selfcoreType = selfcoreType;
    user.dimensions = dimensions;
  }

  // DNA-Ergebnis speichern
  userDnaResults[userId] = {
    answers,
    type: selfcoreType,
    dimensions,
    recommendedCourseId,
    completedAt: new Date().toISOString()
  };

  console.log(`✅ DNA-Test: User ${userId} → Typ: ${selfcoreType}, Empfehlung: ${recommendedCourseId}`);

  return res.json({
    selfcoreType,
    typeDescription: typeInfo.description,
    dimensions,
    recommendedCourse: {
      id: recommendedCourse.id,
      title: recommendedCourse.title,
      subtitle: recommendedCourse.subtitle,
      description: recommendedCourse.description,
      color: recommendedCourse.color,
      reason: `Als ${selfcoreType} empfehlen wir dir "${recommendedCourse.title}" — dieser Kurs stärkt deine ${typeInfo.dimension === 'mut' ? 'Mut' : typeInfo.dimension === 'klarheit' ? 'Klarheit' : typeInfo.dimension === 'verbindung' ? 'Verbindung' : typeInfo.dimension === 'authentizitaet' ? 'Authentizität' : 'Selbstkenntnis'}-Dimension.`
    },
    allCourses: ALL_COURSES.map(c => ({
      id: c.id,
      title: c.title,
      subtitle: c.subtitle,
      description: c.description,
      color: c.color,
      dimension: c.dimension,
      isRecommended: c.id === recommendedCourseId
    }))
  });
});

// DNA-Test Ergebnis abrufen (falls schon gemacht)
app.get('/v1/dna-test/result', authMiddleware, (req, res) => {
  const dna = userDnaResults[req.user.userId];
  if (!dna) return res.status(404).json({ error: 'DNA-Test noch nicht absolviert.' });

  const typeInfo = DNA_TYPE_MAP[dna.type];
  const recommendedCourse = ALL_COURSES.find(c => c.id === dna.recommendedCourseId);

  return res.json({
    selfcoreType: dna.type,
    typeDescription: typeInfo.description,
    dimensions: dna.dimensions,
    recommendedCourse: recommendedCourse ? {
      id: recommendedCourse.id,
      title: recommendedCourse.title,
      subtitle: recommendedCourse.subtitle,
      color: recommendedCourse.color
    } : null,
    completedAt: dna.completedAt
  });
});

// DNA-Test Fragen laden
app.get('/v1/dna-test/questions', (req, res) => {
  // 20 Fragen, je 4 pro Dimension
  return res.json({
    totalQuestions: 20,
    estimatedMinutes: 5,
    questions: [
      { id: 'q1',  text: 'Ich kenne meine Stärken und Schwächen genau.',                dimension: 'selbstkenntnis', min: 1, max: 10 },
      { id: 'q2',  text: 'Ich handle nach meinen eigenen Werten, auch wenn es schwer ist.', dimension: 'authentizitaet', min: 1, max: 10 },
      { id: 'q3',  text: 'Ich habe eine klare Vorstellung davon, wo ich in 5 Jahren sein will.', dimension: 'klarheit', min: 1, max: 10 },
      { id: 'q4',  text: 'Ich traue mich, unbequeme Wahrheiten auszusprechen.',           dimension: 'mut', min: 1, max: 10 },
      { id: 'q5',  text: 'Ich pflege tiefe, bedeutungsvolle Beziehungen.',                dimension: 'verbindung', min: 1, max: 10 },
      { id: 'q6',  text: 'Ich weiß, was mich emotional triggert und warum.',              dimension: 'selbstkenntnis', min: 1, max: 10 },
      { id: 'q7',  text: 'Ich zeige mein wahres Ich, auch wenn ich mich verletzlich fühle.', dimension: 'authentizitaet', min: 1, max: 10 },
      { id: 'q8',  text: 'Meine täglichen Handlungen führen mich zu meinen Zielen.',      dimension: 'klarheit', min: 1, max: 10 },
      { id: 'q9',  text: 'Ich gehe bewusst Risiken ein für mein Wachstum.',               dimension: 'mut', min: 1, max: 10 },
      { id: 'q10', text: 'Ich kann anderen Menschen wirklich zuhören.',                    dimension: 'verbindung', min: 1, max: 10 },
      { id: 'q11', text: 'Ich verstehe, welche Muster mein Verhalten bestimmen.',         dimension: 'selbstkenntnis', min: 1, max: 10 },
      { id: 'q12', text: 'Ich sage Nein zu Dingen, die nicht zu meinen Werten passen.',   dimension: 'authentizitaet', min: 1, max: 10 },
      { id: 'q13', text: 'Ich kann Wichtiges von Unwichtigem unterscheiden.',              dimension: 'klarheit', min: 1, max: 10 },
      { id: 'q14', text: 'Ich stehe zu meinen Entscheidungen, auch bei Gegenwind.',       dimension: 'mut', min: 1, max: 10 },
      { id: 'q15', text: 'Ich investiere aktiv in meine wichtigsten Beziehungen.',        dimension: 'verbindung', min: 1, max: 10 },
      { id: 'q16', text: 'Ich kann meine Emotionen benennen und einordnen.',              dimension: 'selbstkenntnis', min: 1, max: 10 },
      { id: 'q17', text: 'Ich lebe nicht nach den Erwartungen anderer.',                  dimension: 'authentizitaet', min: 1, max: 10 },
      { id: 'q18', text: 'Ich habe klare Prioritäten und halte mich daran.',              dimension: 'klarheit', min: 1, max: 10 },
      { id: 'q19', text: 'Ich stelle mich meinen Ängsten statt ihnen auszuweichen.',      dimension: 'mut', min: 1, max: 10 },
      { id: 'q20', text: 'Ich fühle mich mit den Menschen in meinem Leben verbunden.',    dimension: 'verbindung', min: 1, max: 10 }
    ]
  });
});

// ============================================================
// SIGNAL — AUDIO (mit Zugangs-Check)
// ============================================================

app.get('/v1/signal/tracks', authMiddleware, (req, res) => {
  const userId = req.user.userId;
  const sub = userSubscriptions[userId] || { tier: 'FREE', purchasedSignalTrackIds: [], purchasedSignalBundle: false };
  const tierInfo = ABO_TIERS[sub.tier];

  // Tracks aus Datei oder hardcoded
  let allTracks = [];
  try {
    const p = path.join(__dirname, 'data', 'signal_tracks.json');
    if (fs.existsSync(p)) allTracks = JSON.parse(fs.readFileSync(p, 'utf8'));
  } catch {}

  if (allTracks.length === 0) {
    // Hardcoded Tracks
    allTracks = [
      { id: 'deep-sleep-delta',  title: 'Delta Depth',     duration: '60 Min', frequency: 'Delta 0.5–4 Hz',  category: 'DEEP SLEEP PROTOCOL',   coverColor: '#1A2980' },
      { id: 'deep-sleep-theta',  title: 'Theta Gate',      duration: '45 Min', frequency: 'Theta 4–8 Hz',    category: 'DEEP SLEEP PROTOCOL',   coverColor: '#26274B' },
      { id: 'burnout-alpha',     title: 'Alpha Reset',     duration: '30 Min', frequency: 'Alpha 8–13 Hz',   category: 'BURNOUT REVERSAL',      coverColor: '#4A0E0E' },
      { id: 'burnout-theta',     title: 'Stress Dissolve', duration: '20 Min', frequency: 'Theta 6 Hz',      category: 'BURNOUT REVERSAL',      coverColor: '#5C1A1A' },
      { id: 'burnout-recovery',  title: 'Recovery Mode',   duration: '45 Min', frequency: 'Alpha 10 Hz',     category: 'BURNOUT REVERSAL',      coverColor: '#3D1515' },
      { id: 'hyperfocus-alpha',  title: 'Flow State',      duration: '50 Min', frequency: 'Alpha 12 Hz',     category: 'HYPERFOCUS FREQUENCY',  coverColor: '#004D40' },
      { id: 'hyperfocus-beta',   title: 'Beta Peak',       duration: '40 Min', frequency: 'Beta 14–30 Hz',   category: 'HYPERFOCUS FREQUENCY',  coverColor: '#00695C' },
      { id: 'hyperfocus-gamma',  title: 'Gamma Insight',   duration: '25 Min', frequency: 'Gamma 40 Hz',     category: 'HYPERFOCUS FREQUENCY',  coverColor: '#007A7A' }
    ];
  }

  // Zugang pro Track berechnen
  const hasBundle = sub.purchasedSignalBundle;
  const hasSignalTier = tierInfo && tierInfo.signalAccess;
  const freeDays = signalExtensions[userId] || 0;

  const tracks = allTracks.map((track, idx) => {
    const isPurchased = (sub.purchasedSignalTrackIds || []).includes(track.id);
    const isInTierLimit = hasSignalTier && (tierInfo.signalTrackLimit === -1 || idx < tierInfo.signalTrackLimit);
    const hasAccess = hasBundle || isPurchased || isInTierLimit || freeDays > 0;

    return {
      ...track,
      hasAccess,
      accessType: hasBundle ? 'purchased_bundle' : isPurchased ? 'purchased_single' : isInTierLimit ? 'abo_included' : freeDays > 0 ? 'free_days' : 'locked',
      canPurchaseSingle: !hasAccess && !hasBundle,
      singlePurchasePrice: EINMALZAHLUNG.signal_single.price,
      notice: EINMALZAHLUNG.signal_single.notice
    };
  });

  return res.json(tracks);
});

app.get('/v1/signal/tracks/:trackId/url', authMiddleware, (req, res) => {
  // TODO: Cloudflare R2 Signed URL für MP3 generieren
  // Zugangs-Check
  const userId = req.user.userId;
  const sub = userSubscriptions[userId] || { tier: 'FREE', purchasedSignalTrackIds: [], purchasedSignalBundle: false };
  const tierInfo = ABO_TIERS[sub.tier];
  const freeDays = signalExtensions[userId] || 0;

  const hasAccess = sub.purchasedSignalBundle
    || (sub.purchasedSignalTrackIds || []).includes(req.params.trackId)
    || (tierInfo && tierInfo.signalAccess)
    || freeDays > 0;

  if (!hasAccess) {
    return res.status(403).json({
      error: 'Kein Zugang zu diesem Track.',
      canPurchase: true,
      singlePrice: EINMALZAHLUNG.signal_single.price,
      bundlePrice: EINMALZAHLUNG.signal_bundle.price,
      notice: EINMALZAHLUNG.signal_single.notice
    });
  }

  return res.json({ url: '' });
});

// ============================================================
// RECHTLICHE HINWEISE — Digitale Produkte
// ============================================================

app.get('/v1/legal/digital-purchase-notice', (req, res) => {
  return res.json({
    courseNotice: 'Digitaler Kurs — lebenslanger Zugang nach Kauf. Widerrufsrecht erlischt mit Beginn der Nutzung (§ 356 Abs. 5 BGB).',
    signalNotice: EINMALZAHLUNG.signal_bundle.notice,
    aboNotice: 'Abo verlängert sich automatisch. Kündigung jederzeit zum Ende der Laufzeit möglich. Zahlung über Apple ID (iOS) oder Stripe (Web).',
    refundPolicy: 'Für digitale Inhalte (Audio-Tracks, Kurse) besteht nach Freischaltung kein Widerrufsrecht gemäß § 356 Abs. 5 BGB. Bei Abo-Modellen ist eine Kündigung jederzeit zum Ende der aktuellen Laufzeit möglich.'
  });
});

// ============================================================
// REFERRAL — CODE ERSTELLEN / ABRUFEN
// ============================================================

app.get('/v1/referral/code', authMiddleware, (req, res) => {
  const userId = req.user.userId;
  const user   = userById[userId];
  if (!referrals[userId]) {
    const code = generateReferralCode(user?.name || '');
    referrals[userId] = { code, totalReferred: 0, pendingReferred: 0, earnedDays: 0, badges: [], rewards: [], friends: [], badgeTitles: new Set() };
    codeToUser[code] = userId;
  }
  return res.json(buildReferralResponse(userId));
});

app.post('/v1/referral/code', checkIdempotency, authMiddleware, (req, res) => {
  const userId = req.user.userId;
  const user   = userById[userId];
  if (!referrals[userId]) {
    const code = generateReferralCode(user?.name || '');
    referrals[userId] = { code, totalReferred: 0, pendingReferred: 0, earnedDays: 0, badges: [], rewards: [], friends: [], badgeTitles: new Set() };
    codeToUser[code] = userId;
  }
  const responseData = buildReferralResponse(userId);
  if (res.sendCachedResponse) res.sendCachedResponse(responseData);
  return res.json(responseData);
});

// ============================================================
// REFERRAL — DATEN LADEN
// ============================================================

app.get('/v1/referral/data', authMiddleware, (req, res) => {
  return res.json(buildReferralResponse(req.user.userId));
});

// ============================================================
// REFERRAL — REWARDS ALS GESEHEN MARKIEREN
// ============================================================

app.post('/v1/referral/rewards/seen', checkIdempotency, authMiddleware, (req, res) => {
  const data = referrals[req.user.userId];
  if (data) data.rewards = data.rewards.map(r => ({ ...r, isNew: false }));
  const responseData = {};
  if (res.sendCachedResponse) res.sendCachedResponse(responseData);
  return res.json(responseData);
});

// ============================================================
// REFERRAL — KERN-LOGIK (bulletproof, 7 Schutzebenen)
// ============================================================

function processReferral(newUserId, referralCode, newUserName) {
  // 1. Referral-Paar bereits verarbeitet?
  const pairKey = `${newUserId}:${referralCode}`;
  if (processedReferrals.has(pairKey)) return { alreadyProcessed: true };

  // 2. Code gültig?
  const referrerId = codeToUser[referralCode];
  if (!referrerId) return { invalidCode: true };

  // 3. Selbst-Einladung?
  if (referrerId === newUserId) return { selfReferral: true };

  // 4. Neuer User bereits durch anderen Code eingeladen?
  if (userReferredBy[newUserId]) return { alreadyReferred: true };

  // ATOMAR markieren — BEVOR Rewards vergeben werden
  processedReferrals.add(pairKey);
  userReferredBy[newUserId] = referralCode;

  // Referrer-Daten sicherstellen
  if (!referrals[referrerId]) {
    referrals[referrerId] = { code: referralCode, totalReferred: 0, pendingReferred: 0, earnedDays: 0, badges: [], rewards: [], friends: [], badgeTitles: new Set() };
  }
  const ref = referrals[referrerId];

  // 5. +1 Freund, +3 Tage für Referrer
  ref.totalReferred += 1;
  ref.earnedDays    += 3;
  signalExtensions[referrerId] = (signalExtensions[referrerId] || 0) + 3;

  const avatarColors = ['#F5A623','#FF6B9D','#4A90D9','#FF6B35','#5CB85C','#00C9C9'];
  ref.friends.push({
    id: newUserId,
    firstName: newUserName ? newUserName.split(' ')[0] : 'Freund',
    joinedAt: new Date().toISOString(),
    isActive: true,
    avatarColor: avatarColors[Math.floor(Math.random() * avatarColors.length)]
  });

  ref.rewards.push({
    id: createRewardId('reward'),
    type: 'signal_days',
    description: `${newUserName || 'Dein Freund'} hat sich registriert! +3 Tage GEN:SIGNAL`,
    daysGranted: 3,
    earnedAt: new Date().toISOString(),
    isNew: true
  });

  // 6. Meilenstein-Badges prüfen
  const milestones = [
    { required: 1,  title: 'CONNECTOR', emoji: '🤝', color: '#5CB85C', extraDays: 0,  exclusiveTrack: null },
    { required: 3,  title: 'CATALYST',  emoji: '⚡️', color: '#00C9C9', extraDays: 0,  exclusiveTrack: 'gratitude-flow' },
    { required: 5,  title: 'PIONEER',   emoji: '🔥', color: '#FF6B35', extraDays: 7,  exclusiveTrack: null },
    { required: 10, title: 'LEGEND',    emoji: '👑', color: '#F5A623', extraDays: 30, exclusiveTrack: null },
  ];

  const earned = milestones.find(m => m.required === ref.totalReferred);
  if (earned && !ref.badgeTitles.has(earned.title)) {  // 7. Kein doppeltes Badge
    ref.badgeTitles.add(earned.title);
    ref.badges.push({
      id: createRewardId('badge'),
      title: earned.title,
      emoji: earned.emoji,
      earnedAt: new Date().toISOString(),
      colorHex: earned.color
    });
    if (earned.extraDays > 0) {
      signalExtensions[referrerId] = (signalExtensions[referrerId] || 0) + earned.extraDays;
      ref.earnedDays += earned.extraDays;
      ref.rewards.push({
        id: createRewardId('milestone'),
        type: 'signal_days',
        description: `${earned.title} Meilenstein! +${earned.extraDays} Tage GEN:SIGNAL`,
        daysGranted: earned.extraDays,
        earnedAt: new Date().toISOString(),
        isNew: true
      });
    }
    if (earned.exclusiveTrack) {
      ref.rewards.push({
        id: createRewardId('track'),
        type: 'exclusive_track',
        description: 'Exklusiver Track "Gratitude Flow" freigeschaltet',
        daysGranted: 0,
        earnedAt: new Date().toISOString(),
        isNew: true
      });
    }
  }

  console.log(`✅ Referral: ${newUserName} via ${referralCode} → Referrer ${referrerId} hat jetzt ${ref.totalReferred} Freunde`);
  return { success: true };
}

function buildReferralResponse(userId) {
  const data = referrals[userId];
  if (!data) return { referralCode: '', referralLink: '', totalReferred: 0, pendingReferred: 0, earnedDays: 0, badges: [], rewards: [], referredFriends: [] };
  return {
    referralCode:    data.code,
    referralLink:    `https://genselfcore.de/join?ref=${data.code}`,
    totalReferred:   data.totalReferred,
    pendingReferred: data.pendingReferred || 0,
    earnedDays:      data.earnedDays,
    badges:          data.badges,
    rewards:         data.rewards,
    referredFriends: data.friends
  };
}

// ============================================================
// CLOUDFLARE R2 — SIGNED URL GENERIERUNG
// ============================================================

function generateR2SignedUrl(fileKey, expiresInSeconds = 3600) {
  if (!R2_ACCESS_KEY || !R2_SECRET_KEY) {
    console.warn('⚠️ R2 nicht konfiguriert — leere URL zurückgegeben');
    return '';
  }

  const now = new Date();
  const datestamp = now.toISOString().replace(/[-:]/g, '').split('.')[0] + 'Z';
  const dateOnly = datestamp.substring(0, 8);

  const region = 'auto';
  const service = 's3';
  const credential = `${R2_ACCESS_KEY}/${dateOnly}/${region}/${service}/aws4_request`;

  const expires = expiresInSeconds;
  const host = `${R2_BUCKET}.${R2_ACCOUNT_ID}.r2.cloudflarestorage.com`;

  const queryParams = [
    `X-Amz-Algorithm=AWS4-HMAC-SHA256`,
    `X-Amz-Credential=${encodeURIComponent(credential)}`,
    `X-Amz-Date=${datestamp}`,
    `X-Amz-Expires=${expires}`,
    `X-Amz-SignedHeaders=host`
  ].sort().join('&');

  const canonicalRequest = [
    'GET',
    `/${fileKey}`,
    queryParams,
    `host:${host}`,
    '',
    'host',
    'UNSIGNED-PAYLOAD'
  ].join('\n');

  const stringToSign = [
    'AWS4-HMAC-SHA256',
    datestamp,
    `${dateOnly}/${region}/${service}/aws4_request`,
    crypto.createHash('sha256').update(canonicalRequest).digest('hex')
  ].join('\n');

  function hmac(key, data) {
    return crypto.createHmac('sha256', key).update(data).digest();
  }

  const signingKey = hmac(hmac(hmac(hmac(`AWS4${R2_SECRET_KEY}`, dateOnly), region), service), 'aws4_request');
  const signature = crypto.createHmac('sha256', signingKey).update(stringToSign).digest('hex');

  return `https://${host}/${fileKey}?${queryParams}&X-Amz-Signature=${signature}`;
}

// ============================================================
// APPLE IAP — RECEIPT VALIDATION
// ============================================================

app.post('/v1/iap/validate', authMiddleware, async (req, res) => {
  const userId = req.user.userId;
  const { receiptData, productId } = req.body;

  if (!receiptData) return res.status(400).json({ error: 'receiptData erforderlich.' });

  // Apple Server-zu-Server Validierung
  const verifyUrl = process.env.NODE_ENV === 'production'
    ? 'https://buy.itunes.apple.com/verifyReceipt'
    : 'https://sandbox.itunes.apple.com/verifyReceipt';

  try {
    const response = await fetch(verifyUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        'receipt-data': receiptData,
        'password': process.env.APPLE_SHARED_SECRET || '',
        'exclude-old-transactions': true
      })
    });

    const result = await response.json();

    // Status 0 = gültig
    if (result.status === 0) {
      const latestReceipt = result.latest_receipt_info || [];
      const activeSubscription = latestReceipt.find(r =>
        r.product_id === productId && new Date(parseInt(r.expires_date_ms)) > new Date()
      );

      if (activeSubscription) {
        // Abo im Server aktivieren
        const sub = userSubscriptions[userId] || {};

        // Product-ID → Tier zuordnen
        let tier = 'START';
        if (productId.includes('complete')) tier = 'COMPLETE';
        else if (productId.includes('pro')) tier = 'PRO';

        userSubscriptions[userId] = {
          ...sub,
          tier,
          activeSince: new Date(parseInt(activeSubscription.purchase_date_ms)).toISOString(),
          expiresAt: new Date(parseInt(activeSubscription.expires_date_ms)).toISOString(),
          billingType: productId.includes('yearly') ? 'yearly' : 'monthly',
          appleProductId: productId,
          appleTransactionId: activeSubscription.transaction_id,
          selectedCourseIds: tier === 'COMPLETE' ? ALL_COURSES.map(c => c.id) : (sub.selectedCourseIds || []),
          purchasedCourseIds: sub.purchasedCourseIds || [],
          purchasedSignalTrackIds: sub.purchasedSignalTrackIds || [],
          purchasedSignalBundle: sub.purchasedSignalBundle || false
        };

        saveDB('userSubscriptions', userSubscriptions);
        console.log(`✅ Apple IAP validiert: User ${userId} → ${tier} (${productId})`);

        return res.json({
          valid: true,
          tier,
          expiresAt: userSubscriptions[userId].expiresAt,
          message: `Abo ${tier} erfolgreich aktiviert!`
        });
      }

      // Einmalzahlung (Non-Consumable)
      const purchase = latestReceipt.find(r => r.product_id === productId);
      if (purchase) {
        const sub = userSubscriptions[userId] || {};

        if (productId.includes('course.')) {
          const courseId = productId.split('course.').pop();
          if (!sub.purchasedCourseIds) sub.purchasedCourseIds = [];
          if (!sub.purchasedCourseIds.includes(courseId)) sub.purchasedCourseIds.push(courseId);
        } else if (productId.includes('signal.bundle')) {
          sub.purchasedSignalBundle = true;
        } else if (productId.includes('signal.track.')) {
          const trackId = productId.split('signal.track.').pop();
          if (!sub.purchasedSignalTrackIds) sub.purchasedSignalTrackIds = [];
          if (!sub.purchasedSignalTrackIds.includes(trackId)) sub.purchasedSignalTrackIds.push(trackId);
        }

        userSubscriptions[userId] = { ...userSubscriptions[userId], ...sub };
        saveDB('userSubscriptions', userSubscriptions);

        return res.json({ valid: true, message: 'Kauf validiert und freigeschaltet!' });
      }

      return res.json({ valid: false, error: 'Kein aktives Abo oder Kauf gefunden.' });
    }

    // Status 21007 = Sandbox-Receipt an Production gesendet → Retry
    if (result.status === 21007) {
      console.log('Sandbox receipt detected, retrying with sandbox URL...');
      const sandboxResponse = await fetch('https://sandbox.itunes.apple.com/verifyReceipt', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 'receipt-data': receiptData, 'password': process.env.APPLE_SHARED_SECRET || '' })
      });
      const sandboxResult = await sandboxResponse.json();
      if (sandboxResult.status === 0) {
        return res.json({ valid: true, sandbox: true, message: 'Sandbox-Kauf validiert.' });
      }
    }

    return res.json({ valid: false, status: result.status, error: 'Receipt ungültig.' });

  } catch (error) {
    console.error('Apple IAP Fehler:', error.message);
    return res.status(500).json({ error: 'Validierung fehlgeschlagen. Bitte versuche es erneut.' });
  }
});

// ============================================================
// SERVER STARTEN
// ============================================================

app.listen(PORT, () => {
  console.log(`✅ GEN:SELFCORE Server läuft auf Port ${PORT}`);
  console.log(`   Health: http://localhost:${PORT}/health`);
});

// ============================================================
// DATENORDNER ERSTELLEN (falls nicht vorhanden)
// ============================================================

['data', 'data/lessons'].forEach(dir => {
  const p = path.join(__dirname, dir);
  if (!fs.existsSync(p)) fs.mkdirSync(p, { recursive: true });
});
