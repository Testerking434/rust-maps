// ═══════════════════════════════════════════════════════════════════════════════
// SELFCORE – Sicheres Referral-System (produktionsreif)
// Ersetze die Referral-Teile in server.js komplett durch diese Datei
// ═══════════════════════════════════════════════════════════════════════════════
//
// SCHUTZMECHANISMEN:
// [1] Idempotenz-Key   — gleicher Request 2× = trotzdem nur 1 Belohnung
// [2] E-Mail-Lock       — gleiche E-Mail kann sich nur 1× registrieren
// [3] processedReferrals — jedes (newUserId + referralCode) Paar nur 1× verarbeitet
// [4] userReferredBy    — jeder User kann nur durch EINEN Code geworben werden
// [5] Reward-Dedup      — vor Gutschrift: prüfe ob gleiche Reward-ID existiert
// [6] Selbst-Einladung  — Referrer kann sich nicht selbst einladen
// [7] In-Progress-Lock  — verhindert Race Conditions bei gleichzeitigen Requests
// ═══════════════════════════════════════════════════════════════════════════════

// ─── In-Memory Stores (für Produktion durch PostgreSQL/Redis ersetzen) ──────
const users = {};           // { email → { userId, name, passwordHash } }
const usersByID = {};       // { userId → user }
const referrals = {};       // { userId → ReferralState }
const codeToUser = {};      // { "MAX2K4" → userId }

// Deduplication Stores
const processedReferrals = new Set();   // "newUserId:referralCode" — niemals 2× verarbeiten
const registrationLocks  = new Set();   // E-Mails die gerade registriert werden (Race Condition)
const rewardIDs          = new Set();   // alle je vergebenen Reward-IDs (globale Eindeutigkeit)
const userReferredBy     = {};          // { newUserId → referralCode } — max. 1 Referrer pro User
const idempotencyCache   = {};          // { idempotency-key → response } — gleicher Request = gleiche Antwort
const signalExtensions   = {};          // { userId → freeDaysRemaining }

// ─── Hilfsfunktionen ──────────────────────────────────────────────────────────

function generateReferralCode(email = '') {
  // Eindeutiger Code: 3 Buchstaben aus E-Mail + 4 Zufallszeichen
  const base = email.substring(0, 3).toUpperCase().replace(/[^A-Z]/g, 'X');
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  const suffix = Array.from({ length: 4 }, () => chars[Math.floor(Math.random() * chars.length)]).join('');
  let code = base + suffix;
  // Kollision prüfen (extrem selten, aber sicher)
  while (codeToUser[code]) {
    const newSuffix = Array.from({ length: 4 }, () => chars[Math.floor(Math.random() * chars.length)]).join('');
    code = base + newSuffix;
  }
  return code;
}

// Eindeutige Reward-ID generieren (und registrieren)
function createRewardId(prefix = 'reward') {
  let id;
  do {
    id = `${prefix}_${Date.now()}_${Math.random().toString(36).substr(2, 6)}`;
  } while (rewardIDs.has(id));
  rewardIDs.add(id);
  return id;
}

// Referral-State für einen User initialisieren (falls noch nicht vorhanden)
function ensureReferralState(userId) {
  if (!referrals[userId]) {
    referrals[userId] = {
      code: null,
      totalReferred: 0,
      earnedDays: 0,
      badges: [],
      rewards: [],
      friends: [],
      badgeTitles: new Set()  // schnelle Duplikat-Prüfung für Badges
    };
  }
  return referrals[userId];
}

// ─── MILESTONES Definition ────────────────────────────────────────────────────
const MILESTONES = [
  { required: 1,  title: 'CONNECTOR', emoji: '🤝', color: '#5CB85C', extraDays: 0,
    description: 'CONNECTOR-Badge freigeschaltet' },
  { required: 3,  title: 'CATALYST',  emoji: '⚡️', color: '#00C9C9', extraDays: 0,
    exclusiveTrack: 'gratitude-flow',
    description: 'CATALYST-Badge + Exklusiver Track "Gratitude Flow"' },
  { required: 5,  title: 'PIONEER',   emoji: '🔥', color: '#FF6B35', extraDays: 7,
    description: 'PIONEER-Badge + 7 Tage GEN:SIGNAL extra' },
  { required: 10, title: 'LEGEND',    emoji: '👑', color: '#F5A623', extraDays: 30,
    description: 'LEGEND-Status + 1 Monat GEN:SIGNAL gratis' },
];

// ─── Kernfunktion: Referral verarbeiten (atomar, idempotent) ─────────────────
function processReferral(newUserId, referralCode, newUserName) {
  // [3] Idempotenz: gleiche Kombination nie 2× verarbeiten
  const pairKey = `${newUserId}:${referralCode}`;
  if (processedReferrals.has(pairKey)) {
    console.log(`⚠️  Referral SKIP (bereits verarbeitet): ${pairKey}`);
    return { alreadyProcessed: true };
  }

  // Code existiert?
  const referrerId = codeToUser[referralCode];
  if (!referrerId) {
    console.log(`⚠️  Referral SKIP (ungültiger Code): ${referralCode}`);
    return { invalidCode: true };
  }

  // [6] Selbst-Einladung verhindern
  if (referrerId === newUserId) {
    console.log(`⚠️  Referral SKIP (Selbsteinladung): ${newUserId}`);
    return { selfReferral: true };
  }

  // [4] Jeder User kann nur durch EINEN Code geworben werden
  if (userReferredBy[newUserId]) {
    console.log(`⚠️  Referral SKIP (User ${newUserId} hat bereits einen Referrer)`);
    return { alreadyReferred: true };
  }

  // ── Ab hier: alles OK, Belohnungen vergeben ───────────────────────────────

  // Atomar markieren BEVOR Belohnungen vergeben werden
  // (verhindert Race Condition: zwei gleichzeitige Requests)
  processedReferrals.add(pairKey);
  userReferredBy[newUserId] = referralCode;

  const referrerState = ensureReferralState(referrerId);
  const avatarColors = ['#F5A623', '#FF6B9D', '#4A90D9', '#FF6B35', '#5CB85C', '#00C9C9'];

  // 1. Friend-Eintrag (einmalig durch pairKey gesichert)
  const alreadyFriend = referrerState.friends.some(f => f.id === newUserId);
  if (!alreadyFriend) {
    referrerState.friends.push({
      id: newUserId,
      firstName: newUserName ? newUserName.split(' ')[0] : 'Freund',
      joinedAt: new Date().toISOString(),
      isActive: true,
      avatarColor: avatarColors[Math.floor(Math.random() * avatarColors.length)]
    });
    referrerState.totalReferred += 1;
  }

  // 2. +3 Tage pro Freund (Basis-Reward)
  const baseRewardId = createRewardId('base');
  referrerState.rewards.push({
    id: baseRewardId,
    type: 'signal_days',
    description: `${newUserName || 'Dein Freund'} ist beigetreten — +3 Tage GEN:SIGNAL`,
    daysGranted: 3,
    earnedAt: new Date().toISOString(),
    isNew: true
  });
  referrerState.earnedDays += 3;
  signalExtensions[referrerId] = (signalExtensions[referrerId] || 0) + 3;

  // 3. Meilenstein prüfen (jeder Badge nur 1× vergeben)
  const total = referrerState.totalReferred;
  const milestone = MILESTONES.find(m => m.required === total);

  if (milestone) {
    // [5] Badge-Dedup: badgeTitles Set verhindert doppelten Badge
    if (!referrerState.badgeTitles.has(milestone.title)) {
      referrerState.badgeTitles.add(milestone.title);
      referrerState.badges.push({
        id: createRewardId('badge'),
        title: milestone.title,
        emoji: milestone.emoji,
        earnedAt: new Date().toISOString(),
        colorHex: milestone.color
      });

      // Milestone-Bonus-Tage
      if (milestone.extraDays > 0) {
        const milestoneRewardId = createRewardId('milestone');
        referrerState.rewards.push({
          id: milestoneRewardId,
          type: 'signal_days',
          description: milestone.description,
          daysGranted: milestone.extraDays,
          earnedAt: new Date().toISOString(),
          isNew: true
        });
        referrerState.earnedDays += milestone.extraDays;
        signalExtensions[referrerId] = (signalExtensions[referrerId] || 0) + milestone.extraDays;
      }

      // Exklusiver Track
      if (milestone.exclusiveTrack) {
        // Nur wenn noch nicht vorhanden
        const hasTrack = referrerState.rewards.some(r => r.type === 'exclusive_track' && r.trackId === milestone.exclusiveTrack);
        if (!hasTrack) {
          referrerState.rewards.push({
            id: createRewardId('track'),
            type: 'exclusive_track',
            trackId: milestone.exclusiveTrack,
            description: 'Exklusiver Track "Gratitude Flow" freigeschaltet',
            daysGranted: 0,
            earnedAt: new Date().toISOString(),
            isNew: true
          });
        }
      }
    }
  }

  // 4. Neuer User bekommt 3 Tage Gratis
  signalExtensions[newUserId] = 3;

  console.log(`✅ Referral verarbeitet: ${newUserName} (${newUserId}) via Code ${referralCode} → Referrer ${referrerId} +3 Tage (gesamt: ${total} Freunde)`);
  return { success: true, referrerId, totalReferred: total };
}

// ─── ROUTES ──────────────────────────────────────────────────────────────────

// POST /v1/auth/register
app.post('/v1/auth/register', async (req, res) => {
  // [1] Idempotenz-Key aus Header (iOS schickt diesen bei Retry automatisch mit)
  const idempotencyKey = req.headers['idempotency-key'] || `reg_${req.body.email}`;

  // Gleicher Request nochmal? Gleiche Antwort zurückgeben
  if (idempotencyCache[idempotencyKey]) {
    console.log(`↩️  Idempotent response für: ${idempotencyKey}`);
    return res.json(idempotencyCache[idempotencyKey]);
  }

  const { email, password, name, referralCode } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'E-Mail und Passwort erforderlich' });
  }

  const normalizedEmail = email.toLowerCase().trim();

  // [2] E-Mail bereits registriert?
  if (users[normalizedEmail]) {
    return res.status(409).json({ error: 'E-Mail bereits registriert' });
  }

  // [7] Race Condition: gleiche E-Mail wird gerade registriert?
  if (registrationLocks.has(normalizedEmail)) {
    return res.status(429).json({ error: 'Registrierung läuft bereits, bitte warte kurz' });
  }

  // Lock setzen
  registrationLocks.add(normalizedEmail);

  try {
    // User erstellen
    const newUserId = `user_${Date.now()}_${Math.random().toString(36).substr(2, 6)}`;
    const bcrypt = require('bcrypt');
    const passwordHash = await bcrypt.hash(password, 12);

    const newUser = { userId: newUserId, email: normalizedEmail, name: name || '', passwordHash };
    users[normalizedEmail] = newUser;
    usersByID[newUserId] = newUser;

    const token = require('jsonwebtoken').sign(
      { userId: newUserId, email: normalizedEmail },
      process.env.JWT_SECRET || 'selfcore-secret',
      { expiresIn: '30d' }
    );

    // Referral verarbeiten (sicher, idempotent)
    let freeDays = 0;
    if (referralCode && referralCode.trim()) {
      const result = processReferral(newUserId, referralCode.trim().toUpperCase(), name);
      if (result.success) freeDays = 3;
    }

    const response = {
      token,
      user: {
        id: newUserId,
        name: name || '',
        email: normalizedEmail,
        selfcoreType: 'ACHIEVER',
        dimensions: { selbstkenntnis: 5, authentizitaet: 5, klarheit: 5, mut: 5, verbindung: 5 }
      },
      signalFreeDays: freeDays
    };

    // [1] Antwort cachen (30 Minuten)
    idempotencyCache[idempotencyKey] = response;
    setTimeout(() => delete idempotencyCache[idempotencyKey], 30 * 60 * 1000);

    res.json(response);

  } finally {
    // Lock immer freigeben (auch bei Fehler)
    registrationLocks.delete(normalizedEmail);
  }
});

// POST /v1/auth/login
app.post('/v1/auth/login', async (req, res) => {
  const { email, password } = req.body;
  const normalizedEmail = email?.toLowerCase().trim();
  const user = users[normalizedEmail];

  if (!user) return res.status(401).json({ error: 'E-Mail oder Passwort falsch' });

  const bcrypt = require('bcrypt');
  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) return res.status(401).json({ error: 'E-Mail oder Passwort falsch' });

  const token = require('jsonwebtoken').sign(
    { userId: user.userId, email: normalizedEmail },
    process.env.JWT_SECRET || 'selfcore-secret',
    { expiresIn: '30d' }
  );

  const profile = buildProfile(user);
  res.json({ token, user: profile });
});

// GET /v1/referral/data (mit /code als Alias)
app.get('/v1/referral/data', authMiddleware, (req, res) => {
  res.json(buildReferralResponse(req.user.userId));
});
app.get('/v1/referral/code', authMiddleware, (req, res) => {
  // Code erstellen falls noch nicht vorhanden
  const state = ensureReferralState(req.user.userId);
  if (!state.code) {
    const user = usersByID[req.user.userId];
    state.code = generateReferralCode(user?.email || '');
    codeToUser[state.code] = req.user.userId;
  }
  res.json(buildReferralResponse(req.user.userId));
});
app.post('/v1/referral/code', authMiddleware, (req, res) => {
  const state = ensureReferralState(req.user.userId);
  if (!state.code) {
    const user = usersByID[req.user.userId];
    state.code = generateReferralCode(user?.email || '');
    codeToUser[state.code] = req.user.userId;
  }
  res.json(buildReferralResponse(req.user.userId));
});

// POST /v1/referral/rewards/seen — Rewards als gesehen markieren
app.post('/v1/referral/rewards/seen', authMiddleware, (req, res) => {
  const state = referrals[req.user.userId];
  if (state) {
    state.rewards = state.rewards.map(r => ({ ...r, isNew: false }));
  }
  res.json({});
});

// GET /v1/user/signal-status — Abo-Status + Gratis-Tage
app.get('/v1/user/signal-status', authMiddleware, (req, res) => {
  const freeDays = signalExtensions[req.user.userId] || 0;
  res.json({
    isSubscribed: false,   // Echtes Abo via StoreKit-Webhook setzen
    freeDaysRemaining: freeDays,
    hasAccess: freeDays > 0
  });
});

// ─── Hilfsfunktionen für Response-Format ─────────────────────────────────────

function buildReferralResponse(userId) {
  const state = ensureReferralState(userId);
  return {
    referralCode: state.code || '',
    referralLink: state.code ? `https://genselfcore.de/join?ref=${state.code}` : '',
    totalReferred: state.totalReferred,
    pendingReferred: 0,
    earnedDays: state.earnedDays,
    usedByCode: userReferredBy[userId] || null,
    badges: state.badges,
    rewards: state.rewards,
    referredFriends: state.friends
  };
}

function buildProfile(user) {
  return {
    id: user.userId,
    name: user.name,
    email: user.email,
    selfcoreType: 'ACHIEVER',
    dimensions: { selbstkenntnis: 5, authentizitaet: 5, klarheit: 5, mut: 5, verbindung: 5 }
  };
}

// ─── PRODUCTION TODO: Ersetze In-Memory durch Datenbank ──────────────────────
//
// Empfehlung: PostgreSQL mit diesen Tabellen:
//
// users (id, email UNIQUE, name, password_hash, created_at)
// referral_codes (code PRIMARY KEY, user_id REFERENCES users)
// referral_events (
//   id PRIMARY KEY,
//   new_user_id REFERENCES users,
//   referrer_id REFERENCES users,
//   code TEXT,
//   processed_at TIMESTAMP,
//   UNIQUE(new_user_id)  ← jeder neue User nur 1× als Geworbener
//   UNIQUE(new_user_id, code) ← gleiche Kombination nie 2×
// )
// referral_rewards (
//   id PRIMARY KEY,
//   user_id REFERENCES users,
//   type TEXT,
//   days_granted INT,
//   is_new BOOLEAN DEFAULT true,
//   earned_at TIMESTAMP,
//   UNIQUE(id)  ← globale Reward-ID Eindeutigkeit
// )
// signal_extensions (
//   user_id REFERENCES users PRIMARY KEY,
//   free_days_remaining INT DEFAULT 0
// )
//
// Mit PostgreSQL-Transactions (BEGIN/COMMIT) und SELECT ... FOR UPDATE
// sind Race Conditions auf Datenbankebene ausgeschlossen.
