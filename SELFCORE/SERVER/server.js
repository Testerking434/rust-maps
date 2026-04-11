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

const app  = express();
const PORT = process.env.PORT || 3001;
const JWT_SECRET = process.env.JWT_SECRET || 'AENDER_MICH_VOR_PRODUKTIONSSTART';

app.use(cors());
app.use(express.json());

// ============================================================
// IN-MEMORY DATENBANK
// Für Produktion: PostgreSQL (Anleitung am Ende der Datei)
// ============================================================

const users             = {};   // { normalisierteEmail: { id, name, email, passwordHash, ... } }
const userById          = {};   // { userId: userData }
const referrals         = {};   // { userId: { code, totalReferred, friends, rewards, badges } }
const codeToUser        = {};   // { "MAX2K4": userId }
const signalExtensions  = {};   // { userId: extraDays }
const processedReferrals = new Set(); // "newUserId:referralCode"
const userReferredBy    = {};   // { newUserId: referralCode }
const rewardIDs         = new Set();
const registrationLocks = new Set();
const idempotencyCache  = {};   // { key: { response, expiresAt } }

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
      selfcoreType: 'ACHIEVER',
      dimensions: { selbstkenntnis: 5, authentizitaet: 5, klarheit: 5, mut: 5, verbindung: 5 },
      createdAt: new Date().toISOString()
    };

    users[normEmail] = userData;
    userById[newUserId] = userData;

    // Referral verarbeiten
    let signalFreeDays = 0;
    if (referralCode) {
      const result = processReferral(newUserId, referralCode.toUpperCase().trim(), name.trim());
      if (result.success) {
        signalExtensions[newUserId] = (signalExtensions[newUserId] || 0) + 3;
        signalFreeDays = 3;
      }
    }

    const responseData = {
      token,
      user: {
        id: newUserId,
        name: userData.name,
        email: normEmail,
        selfcoreType: userData.selfcoreType,
        dimensions: userData.dimensions
      },
      signalFreeDays
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

  return res.json({
    token,
    user: {
      id: userData.id,
      name: userData.name,
      email: normEmail,
      selfcoreType: userData.selfcoreType,
      dimensions: userData.dimensions
    }
  });
});

// ============================================================
// AUTH — PASSWORT RESET (E-Mail senden — TODO: echten Mailer einbauen)
// ============================================================

app.post('/v1/auth/reset-password', (req, res) => {
  // TODO: nodemailer einbauen und Reset-Link senden
  // Vorerst: immer 200 zurückgeben (security: nicht verraten ob E-Mail existiert)
  console.log(`Password reset requested for: ${req.body.email}`);
  return res.json({ message: 'Falls diese E-Mail registriert ist, wurde ein Link gesendet.' });
});

// ============================================================
// USER — PROFIL
// ============================================================

app.get('/v1/user/profile', authMiddleware, (req, res) => {
  const user = userById[req.user.userId];
  if (!user) return res.status(404).json({ error: 'User nicht gefunden.' });
  return res.json({
    id: user.id,
    name: user.name,
    email: user.email,
    selfcoreType: user.selfcoreType,
    dimensions: user.dimensions
  });
});

app.get('/v1/user/courses', authMiddleware, (req, res) => {
  // Kurse aus courses.json laden (oder hardcoded)
  try {
    const coursesPath = path.join(__dirname, 'data', 'courses.json');
    if (fs.existsSync(coursesPath)) {
      const courses = JSON.parse(fs.readFileSync(coursesPath, 'utf8'));
      return res.json(courses);
    }
  } catch {}
  // Fallback: Basis-Kursstruktur
  return res.json([
    { id: 'awakening', title: 'AWAKENING', subtitle: 'Erwache zu dir selbst', lessonCount: 42, coverImageURL: '' },
    { id: 'origin',    title: 'ORIGIN',    subtitle: 'Dein DNA-Profil',       lessonCount: 10, coverImageURL: '' }
  ]);
});

app.get('/v1/user/signal-status', authMiddleware, (req, res) => {
  const freeDays = signalExtensions[req.user.userId] || 0;
  return res.json({ isSubscribed: false, freeDaysRemaining: freeDays, hasAccess: freeDays > 0 });
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
  // TODO: Cloudflare R2 Signed URL generieren
  return res.json({ url: '' });
});

app.post('/v1/lessons/:lessonId/complete', authMiddleware, (req, res) => {
  return res.json({ message: 'Lektion als abgeschlossen markiert.' });
});

// ============================================================
// SIGNAL — AUDIO
// ============================================================

app.get('/v1/signal/tracks', authMiddleware, (req, res) => {
  try {
    const p = path.join(__dirname, 'data', 'signal_tracks.json');
    if (fs.existsSync(p)) return res.json(JSON.parse(fs.readFileSync(p, 'utf8')));
  } catch {}
  return res.json([]);
});

app.get('/v1/signal/tracks/:trackId/url', authMiddleware, (req, res) => {
  // TODO: Cloudflare R2 Signed URL für MP3 generieren
  return res.json({ url: '' });
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
