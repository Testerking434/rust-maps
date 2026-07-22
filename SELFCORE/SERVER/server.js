// ============================================================
// GEN:SELFCORE — server.js
// Läuft auf Port 8001
// ============================================================

'use strict';

const express    = require('express');
const bcrypt     = require('bcryptjs');
const jwt        = require('jsonwebtoken');
const cors       = require('cors');
const path       = require('path');
const fs         = require('fs');

const app  = express();
const PORT = process.env.PORT || 8001;
const JWT_SECRET = process.env.JWT_SECRET || 'AENDER_MICH_VOR_PRODUKTIONSSTART';

app.use(cors());
app.use(express.json());

// ============================================================
// IN-MEMORY DATENBANK
// ============================================================

const users              = {};  // { normEmail: userData }
const userById           = {};  // { userId: userData }
const referrals          = {};  // { userId: referralData }
const codeToUser         = {};  // { "MAX2K4": userId }
const signalExtensions   = {};  // { userId: extraDays }
const processedReferrals = new Set();
const userReferredBy     = {};  // { newUserId: referralCode }
const rewardIDs          = new Set();
const registrationLocks  = new Set();
const idempotencyCache   = {};  // { key: { response, expiresAt } }

const subscriptions      = {};  // { userId: { tier, expiresAt, productId, purchasedAt } }
const oneTimePurchases   = {};  // { userId: Set<productId> }
const lessonProgress     = {};  // { userId: { 'courseId/lessonId': { completed, completedAt } } }
const dnaResults         = {};  // { userId: DnaResult }
const checkIns           = {};  // { userId: [CheckIn] }

// ============================================================
// PRODUKTE & PREISE
// ============================================================

const DIGITAL_NOTICE = 'Digitales Produkt. Nach Aktivierung kein Rueckgaberecht gemaess § 356 Abs. 5 BGB.';
const AUDIO_NOTICE   = 'Digitales Audio-Produkt. Nach Freischaltung kein Rueckgaberecht gemaess § 356 Abs. 5 BGB. Kein Rueckgaberecht nach Download oder Streaming-Start.';

const PRODUCTS = {
  // Abonnements
  'de.genselfcore.start.monthly': {
    id: 'de.genselfcore.start.monthly', type: 'subscription', tier: 'start',
    name: 'START Monatlich', price: 4.99, currency: 'EUR', period: 'monthly',
    isDigital: true, notice: DIGITAL_NOTICE
  },
  'de.genselfcore.start.yearly': {
    id: 'de.genselfcore.start.yearly', type: 'subscription', tier: 'start',
    name: 'START Jährlich', price: 39.99, currency: 'EUR', period: 'yearly',
    isDigital: true, notice: DIGITAL_NOTICE
  },
  'de.genselfcore.pro.monthly': {
    id: 'de.genselfcore.pro.monthly', type: 'subscription', tier: 'pro',
    name: 'PRO Monatlich', price: 9.99, currency: 'EUR', period: 'monthly',
    isDigital: true, notice: DIGITAL_NOTICE
  },
  'de.genselfcore.pro.yearly': {
    id: 'de.genselfcore.pro.yearly', type: 'subscription', tier: 'pro',
    name: 'PRO Jährlich', price: 79.99, currency: 'EUR', period: 'yearly',
    isDigital: true, notice: DIGITAL_NOTICE
  },
  'de.genselfcore.complete.monthly': {
    id: 'de.genselfcore.complete.monthly', type: 'subscription', tier: 'complete',
    name: 'COMPLETE Monatlich', price: 19.99, currency: 'EUR', period: 'monthly',
    isDigital: true, notice: DIGITAL_NOTICE
  },
  'de.genselfcore.complete.yearly': {
    id: 'de.genselfcore.complete.yearly', type: 'subscription', tier: 'complete',
    name: 'COMPLETE Jährlich', price: 159.99, currency: 'EUR', period: 'yearly',
    isDigital: true, notice: DIGITAL_NOTICE
  },
  // GEN:SIGNAL Einmalzahlungen
  'de.genselfcore.signal.basic': {
    id: 'de.genselfcore.signal.basic', type: 'onetime', category: 'signal',
    name: 'GEN:SIGNAL BASIC', price: 29.99, currency: 'EUR',
    isDigital: true, notice: AUDIO_NOTICE
  },
  'de.genselfcore.signal.protocol': {
    id: 'de.genselfcore.signal.protocol', type: 'onetime', category: 'signal',
    name: 'GEN:SIGNAL PROTOCOL', price: 99.99, currency: 'EUR',
    isDigital: true, notice: AUDIO_NOTICE
  },
  'de.genselfcore.signal.command': {
    id: 'de.genselfcore.signal.command', type: 'onetime', category: 'signal',
    name: 'GEN:SIGNAL COMMAND', price: 249.99, currency: 'EUR',
    isDigital: true, notice: AUDIO_NOTICE
  },
  // DNA Analyse Einmalzahlungen
  'de.genselfcore.analysis.premium': {
    id: 'de.genselfcore.analysis.premium', type: 'onetime', category: 'dna',
    name: 'DNA Analyse PREMIUM', price: 29.99, currency: 'EUR',
    isDigital: true, notice: DIGITAL_NOTICE
  },
  'de.genselfcore.analysis.deepcore': {
    id: 'de.genselfcore.analysis.deepcore', type: 'onetime', category: 'dna',
    name: 'DNA Analyse DEEPCORE', price: 49.99, currency: 'EUR',
    isDigital: true, notice: DIGITAL_NOTICE
  }
};

// ============================================================
// ABO-STUFEN & ZUGANGSRECHTE
// ============================================================

const TIER_ACCESS = {
  free: {
    courses: ['awakening_preview'],
    moduleLimit: 2,
    signal: false,
    dnaLevel: 'basic',
    downloads: false
  },
  start: {
    courses: ['awakening', 'recommended'],
    moduleLimit: null,
    signal: 'basic',
    dnaLevel: 'basic',
    downloads: false
  },
  pro: {
    courses: 'all',
    moduleLimit: null,
    signal: 'full',
    dnaLevel: 'premium',
    downloads: false
  },
  complete: {
    courses: 'all',
    moduleLimit: null,
    signal: 'command',
    dnaLevel: 'deepcore',
    downloads: true
  }
};

// ============================================================
// DNA PERSÖNLICHKEITSTYPEN
// ============================================================

const DNA_TYPES = {
  ACHIEVER:  { emoji: '🎯', color: '#F5A623', dimension: 'selbstkenntnis', course: 'awakening',    label: 'Der Macher' },
  GUARDIAN:  { emoji: '🛡', color: '#FF6B9D', dimension: 'authentizitaet', course: 'origin',       label: 'Der Hüter' },
  CREATOR:   { emoji: '✨', color: '#4A90D9', dimension: 'klarheit',       course: 'genesis',      label: 'Der Erschaffer' },
  PIONEER:   { emoji: '🔥', color: '#FF6B35', dimension: 'mut',            course: 'foundation',   label: 'Der Pionier' },
  CONNECTOR: { emoji: '🌿', color: '#5CB85C', dimension: 'verbindung',     course: 'core-journey', label: 'Der Verbinder' }
};

// ============================================================
// DNA FRAGEN
// ============================================================

const DNA_QUESTIONS = {
  basic: [
    // Dimension 1: Selbstkenntnis (q1, q6)
    { id: 'q1',  dimension: 'selbstkenntnis', text: 'Ich kenne meine Stärken und Schwächen gut.', scale: 5 },
    { id: 'q2',  dimension: 'authentizitaet', text: 'Ich handle im Einklang mit meinen Werten, auch unter Druck.', scale: 5 },
    { id: 'q3',  dimension: 'klarheit',       text: 'Ich weiß, was ich in meinem Leben erreichen will.', scale: 5 },
    { id: 'q4',  dimension: 'mut',            text: 'Ich gehe Risiken ein, wenn ich von etwas überzeugt bin.', scale: 5 },
    { id: 'q5',  dimension: 'verbindung',     text: 'Tiefe Beziehungen sind mir wichtiger als viele oberflächliche.', scale: 5 },
    { id: 'q6',  dimension: 'selbstkenntnis', text: 'Ich reflektiere regelmäßig über meine Entscheidungen.', scale: 5 },
    { id: 'q7',  dimension: 'authentizitaet', text: 'Ich kann Nein sagen, ohne mich schuldig zu fühlen.', scale: 5 },
    { id: 'q8',  dimension: 'klarheit',       text: 'Ich handle nach klaren Prioritäten und verliere mich nicht.', scale: 5 },
    { id: 'q9',  dimension: 'mut',            text: 'Ich spreche aus, was ich denke, auch wenn es unbequem ist.', scale: 5 },
    { id: 'q10', dimension: 'verbindung',     text: 'Ich investiere aktiv in die Menschen, die mir wichtig sind.', scale: 5 }
  ],
  premium: [
    { id: 'p1',  dimension: 'selbstkenntnis', text: 'Ich erkenne Muster in meinem Verhalten, die mich limitieren.', scale: 5 },
    { id: 'p2',  dimension: 'authentizitaet', text: 'Meine äußere Erscheinung spiegelt wider, wer ich wirklich bin.', scale: 5 },
    { id: 'p3',  dimension: 'klarheit',       text: 'Ich kann meine Gedanken klar und präzise kommunizieren.', scale: 5 },
    { id: 'p4',  dimension: 'mut',            text: 'Ich stelle den Status quo in Frage, wenn er mich nicht weiterbringt.', scale: 5 },
    { id: 'p5',  dimension: 'verbindung',     text: 'Ich kann verletzlich sein und um Hilfe bitten.', scale: 5 },
    { id: 'p6',  dimension: 'selbstkenntnis', text: 'Ich weiß, welche Umgebungen mein Bestes hervorbringen.', scale: 5 },
    { id: 'p7',  dimension: 'authentizitaet', text: 'Ich passe mich nicht an, wenn es gegen meine Überzeugungen geht.', scale: 5 },
    { id: 'p8',  dimension: 'klarheit',       text: 'Ich unterscheide zwischen dem, was dringend und was wichtig ist.', scale: 5 },
    { id: 'p9',  dimension: 'mut',            text: 'Scheitern bremst mich nicht — es lehrt mich.', scale: 5 },
    { id: 'p10', dimension: 'verbindung',     text: 'Ich gebe und nehme in Beziehungen mit gleicher Offenheit.', scale: 5 }
  ],
  deepcore: [
    { id: 'd1',  dimension: 'selbstkenntnis', text: 'Ich kenne die Wurzeln meiner tiefsten Ängste.', scale: 5 },
    { id: 'd2',  dimension: 'authentizitaet', text: 'Ich lebe meine Werte, auch wenn niemand zuschaut.', scale: 5 },
    { id: 'd3',  dimension: 'klarheit',       text: 'Meine Entscheidungen entstehen aus innerer Stille, nicht aus Angst.', scale: 5 },
    { id: 'd4',  dimension: 'mut',            text: 'Ich habe Dinge getan, die mich fundamental verändert haben.', scale: 5 },
    { id: 'd5',  dimension: 'verbindung',     text: 'Ich kann jemanden vollständig sehen und akzeptieren, ohne ihn zu verändern.', scale: 5 },
    { id: 'd6',  dimension: 'selbstkenntnis', text: 'Ich erkenne, wenn ich mich selbst belüge.', scale: 5 },
    { id: 'd7',  dimension: 'authentizitaet', text: 'Mein Leben ist ein Ausdruck von dem, wer ich sein will.', scale: 5 },
    { id: 'd8',  dimension: 'klarheit',       text: 'Ich weiß, was mein Leben sinnvoll macht.', scale: 5 },
    { id: 'd9',  dimension: 'mut',            text: 'Ich stehe zu mir selbst, auch wenn es Konsequenzen hat.', scale: 5 },
    { id: 'd10', dimension: 'verbindung',     text: 'Ich trage aktiv zur Entwicklung anderer Menschen bei.', scale: 5 }
  ]
};

// ============================================================
// KURS-DATEN (Fallback wenn keine courses.json)
// ============================================================

const COURSES_FALLBACK = [
  {
    id: 'awakening', stage: 1, title: 'AWAKENING', subtitle: 'Erwache zu dir selbst',
    lessonCount: 42, moduleCount: 6, color: '#F5A623',
    dnaType: 'ACHIEVER', coverImageURL: ''
  },
  {
    id: 'origin', stage: 2, title: 'ORIGIN', subtitle: 'Dein DNA-Profil verstehen',
    lessonCount: 36, moduleCount: 6, color: '#4A90D9',
    dnaType: 'GUARDIAN', coverImageURL: ''
  },
  {
    id: 'genesis', stage: 3, title: 'GENESIS', subtitle: 'Erschaffe dein neues Selbst',
    lessonCount: 38, moduleCount: 6, color: '#5CB85C',
    dnaType: 'CREATOR', coverImageURL: ''
  },
  {
    id: 'foundation', stage: 4, title: 'FOUNDATION', subtitle: 'Baue auf felsigem Grund',
    lessonCount: 35, moduleCount: 6, color: '#FF6B35',
    dnaType: 'PIONEER', coverImageURL: ''
  },
  {
    id: 'core-journey', stage: 5, title: 'CORE JOURNEY', subtitle: 'Die Reise zum Kern',
    lessonCount: 40, moduleCount: 6, color: '#C0C0C0',
    dnaType: 'CONNECTOR', coverImageURL: ''
  }
];

// ============================================================
// HILFSFUNKTIONEN
// ============================================================

function generateReferralCode(name = '') {
  const base = (name.substring(0, 3).toUpperCase().replace(/[^A-Z]/g, 'X')) || 'REF';
  const suffix = Math.random().toString(36).substring(2, 5).toUpperCase();
  const code = base + suffix;
  return codeToUser[code] ? generateReferralCode(name) : code;
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

function checkIdempotency(req, res, next) {
  const key = req.headers['idempotency-key'];
  if (!key) return next();
  const now = Date.now();
  Object.keys(idempotencyCache).forEach(k => {
    if (idempotencyCache[k].expiresAt < now) delete idempotencyCache[k];
  });
  if (idempotencyCache[key]) return res.status(200).json(idempotencyCache[key].response);
  res.sendCachedResponse = (data) => {
    idempotencyCache[key] = { response: data, expiresAt: now + 30 * 60 * 1000 };
  };
  next();
}

function getUserTier(userId) {
  const sub = subscriptions[userId];
  if (!sub) return 'free';
  if (sub.expiresAt && new Date(sub.expiresAt) < new Date()) return 'free';
  return sub.tier || 'free';
}

function canAccessCourse(userId, courseId) {
  const tier = getUserTier(userId);
  const access = TIER_ACCESS[tier];
  const dna = dnaResults[userId];

  if (access.courses === 'all') return { access: true, reason: 'subscription' };

  if (Array.isArray(access.courses)) {
    if (access.courses.includes(courseId)) return { access: true, reason: 'subscription' };
    if (access.courses.includes('recommended') && dna && DNA_TYPES[dna.type]?.course === courseId) {
      return { access: true, reason: 'dna_recommended' };
    }
    if (access.courses.includes('awakening_preview') && courseId === 'awakening') {
      return { access: true, reason: 'free_preview', moduleLimit: access.moduleLimit };
    }
  }

  return {
    access: false,
    reason: 'upgrade_required',
    upgradeProduct: tier === 'free' ? 'de.genselfcore.start.monthly' : 'de.genselfcore.pro.monthly'
  };
}

function canAccessSignal(userId) {
  const tier = getUserTier(userId);
  const access = TIER_ACCESS[tier];
  const freeDays = signalExtensions[userId] || 0;
  const purchases = oneTimePurchases[userId];

  if (access.signal) return { hasAccess: true, accessLevel: access.signal, freeDaysRemaining: 0 };
  if (freeDays > 0) return { hasAccess: true, accessLevel: 'basic', freeDaysRemaining: freeDays };
  if (purchases) {
    if (purchases.has('de.genselfcore.signal.command')) return { hasAccess: true, accessLevel: 'command', freeDaysRemaining: 0 };
    if (purchases.has('de.genselfcore.signal.protocol')) return { hasAccess: true, accessLevel: 'full', freeDaysRemaining: 0 };
    if (purchases.has('de.genselfcore.signal.basic')) return { hasAccess: true, accessLevel: 'basic', freeDaysRemaining: 0 };
  }

  return { hasAccess: false, accessLevel: null, freeDaysRemaining: 0 };
}

function calculateDnaType(answers) {
  const scores = { selbstkenntnis: 0, authentizitaet: 0, klarheit: 0, mut: 0, verbindung: 0 };

  const allQuestions = [
    ...DNA_QUESTIONS.basic,
    ...DNA_QUESTIONS.premium,
    ...DNA_QUESTIONS.deepcore
  ];

  for (const [questionId, value] of Object.entries(answers)) {
    const q = allQuestions.find(q => q.id === questionId);
    if (q && scores[q.dimension] !== undefined) {
      scores[q.dimension] += Number(value);
    }
  }

  const topDimension = Object.entries(scores).sort((a, b) => b[1] - a[1])[0][0];
  const dimToType = {
    selbstkenntnis: 'ACHIEVER',
    authentizitaet: 'GUARDIAN',
    klarheit:       'CREATOR',
    mut:            'PIONEER',
    verbindung:     'CONNECTOR'
  };

  const type = dimToType[topDimension];
  const maxPossible = Object.keys(answers).length * 5;

  return {
    type,
    dimensions: scores,
    recommendedCourse: DNA_TYPES[type].course,
    completedAt: new Date().toISOString(),
    totalScore: maxPossible > 0 ? Math.round((Object.values(scores).reduce((a,b)=>a+b,0) / maxPossible) * 100) : 0
  };
}

function loadCourses() {
  try {
    const p = path.join(__dirname, 'data', 'courses.json');
    if (fs.existsSync(p)) return JSON.parse(fs.readFileSync(p, 'utf8'));
  } catch {}
  return COURSES_FALLBACK;
}

// ============================================================
// HEALTH CHECK
// ============================================================

app.get('/health', (_, res) => res.json({ status: 'ok', app: 'GEN:SELFCORE', port: PORT }));

// ============================================================
// PRODUKTE
// ============================================================

app.get('/v1/products', (req, res) => {
  return res.json(Object.values(PRODUCTS));
});

// ============================================================
// AUTH — REGISTRIERUNG
// ============================================================

app.post('/v1/auth/register', checkIdempotency, async (req, res) => {
  const { name, email, password, referralCode } = req.body;

  if (!email || !password || !name) {
    return res.status(400).json({ error: 'Name, E-Mail und Passwort erforderlich.' });
  }

  const normEmail = email.toLowerCase().trim();

  if (registrationLocks.has(normEmail)) {
    return res.status(429).json({ error: 'Registrierung läuft bereits. Bitte warten.' });
  }
  registrationLocks.add(normEmail);

  try {
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
  const tier  = getUserTier(userData.id);
  const dna   = dnaResults[userData.id];

  return res.json({
    token,
    user: {
      id: userData.id,
      name: userData.name,
      email: normEmail,
      selfcoreType: dna ? dna.type : userData.selfcoreType,
      dimensions: dna ? dna.dimensions : userData.dimensions,
      tier
    }
  });
});

// ============================================================
// AUTH — PASSWORT RESET
// ============================================================

app.post('/v1/auth/reset-password', (req, res) => {
  console.log(`Password reset requested for: ${req.body.email}`);
  return res.json({ message: 'Falls diese E-Mail registriert ist, wurde ein Link gesendet.' });
});

// ============================================================
// AUTH — LOGOUT
// ============================================================

app.post('/v1/auth/logout', authMiddleware, (req, res) => res.json({ message: 'Abgemeldet.' }));

// ============================================================
// USER — PROFIL
// ============================================================

app.get('/v1/user/profile', authMiddleware, (req, res) => {
  const user = userById[req.user.userId];
  if (!user) return res.status(404).json({ error: 'User nicht gefunden.' });

  const tier     = getUserTier(req.user.userId);
  const dna      = dnaResults[req.user.userId];
  const sub      = subscriptions[req.user.userId];
  const signal   = canAccessSignal(req.user.userId);
  const progress = lessonProgress[req.user.userId] || {};

  return res.json({
    id: user.id,
    name: user.name,
    email: user.email,
    selfcoreType: dna ? dna.type : user.selfcoreType,
    dimensions: dna ? dna.dimensions : user.dimensions,
    tier,
    subscription: sub ? { tier: sub.tier, expiresAt: sub.expiresAt, productId: sub.productId } : null,
    dnaCompleted: !!dna,
    dnaType: dna ? dna.type : null,
    recommendedCourse: dna ? dna.recommendedCourse : null,
    signal,
    completedLessons: Object.keys(progress).filter(k => progress[k].completed).length,
    createdAt: user.createdAt
  });
});

// ============================================================
// ABO — VALIDIERUNG (Apple StoreKit 2 receipt)
// ============================================================

app.post('/v1/subscription/validate', checkIdempotency, authMiddleware, (req, res) => {
  const { productId, transactionId, originalTransactionId } = req.body;
  const userId = req.user.userId;

  if (!productId) return res.status(400).json({ error: 'productId fehlt.' });

  const product = PRODUCTS[productId];
  if (!product || product.type !== 'subscription') {
    return res.status(400).json({ error: 'Ungültige Produkt-ID.' });
  }

  const now      = new Date();
  const months   = product.period === 'yearly' ? 12 : 1;
  const expires  = new Date(now.setMonth(now.getMonth() + months));

  subscriptions[userId] = {
    tier: product.tier,
    expiresAt: expires.toISOString(),
    productId,
    transactionId: transactionId || null,
    originalTransactionId: originalTransactionId || null,
    purchasedAt: new Date().toISOString()
  };

  const responseData = {
    success: true,
    tier: product.tier,
    expiresAt: expires.toISOString(),
    features: TIER_ACCESS[product.tier],
    notice: product.notice
  };

  if (res.sendCachedResponse) res.sendCachedResponse(responseData);
  return res.json(responseData);
});

// ============================================================
// ABO — STATUS
// ============================================================

app.get('/v1/subscription/status', authMiddleware, (req, res) => {
  const userId = req.user.userId;
  const tier   = getUserTier(userId);
  const sub    = subscriptions[userId];
  const signal = canAccessSignal(userId);

  return res.json({
    tier,
    isActive: tier !== 'free',
    subscription: sub ? { productId: sub.productId, expiresAt: sub.expiresAt } : null,
    features: TIER_ACCESS[tier],
    signal
  });
});

// ============================================================
// EINMALZAHLUNGEN — VALIDIERUNG
// ============================================================

app.post('/v1/purchases/validate', checkIdempotency, authMiddleware, (req, res) => {
  const { productId, transactionId } = req.body;
  const userId = req.user.userId;

  if (!productId) return res.status(400).json({ error: 'productId fehlt.' });

  const product = PRODUCTS[productId];
  if (!product || product.type !== 'onetime') {
    return res.status(400).json({ error: 'Ungültige Produkt-ID.' });
  }

  if (!oneTimePurchases[userId]) oneTimePurchases[userId] = new Set();
  oneTimePurchases[userId].add(productId);

  const responseData = {
    success: true,
    productId,
    category: product.category,
    purchasedAt: new Date().toISOString(),
    notice: product.notice
  };

  if (res.sendCachedResponse) res.sendCachedResponse(responseData);
  return res.json(responseData);
});

// ============================================================
// DNA — FRAGEN
// ============================================================

app.get('/v1/dna/questions', authMiddleware, (req, res) => {
  const requestedLevel = req.query.level || 'basic';
  const userId = req.user.userId;
  const tier   = getUserTier(userId);
  const tierAccess = TIER_ACCESS[tier];

  // Zugriffscheck für Premium/Deepcore
  if (requestedLevel === 'deepcore') {
    const hasPurchase = oneTimePurchases[userId]?.has('de.genselfcore.analysis.deepcore');
    const hasSubAccess = tierAccess.dnaLevel === 'deepcore';
    if (!hasPurchase && !hasSubAccess) {
      return res.status(403).json({
        error: 'Deepcore-Analyse erfordert einen Kauf.',
        upgradeProduct: 'de.genselfcore.analysis.deepcore',
        price: PRODUCTS['de.genselfcore.analysis.deepcore'].price,
        notice: PRODUCTS['de.genselfcore.analysis.deepcore'].notice
      });
    }
  }

  if (requestedLevel === 'premium') {
    const hasPurchase = oneTimePurchases[userId]?.has('de.genselfcore.analysis.premium') ||
                        oneTimePurchases[userId]?.has('de.genselfcore.analysis.deepcore');
    const hasSubAccess = ['premium', 'deepcore'].includes(tierAccess.dnaLevel);
    if (!hasPurchase && !hasSubAccess) {
      return res.status(403).json({
        error: 'Premium-Analyse erfordert einen Kauf.',
        upgradeProduct: 'de.genselfcore.analysis.premium',
        price: PRODUCTS['de.genselfcore.analysis.premium'].price,
        notice: PRODUCTS['de.genselfcore.analysis.premium'].notice
      });
    }
  }

  const level = ['basic', 'premium', 'deepcore'].includes(requestedLevel) ? requestedLevel : 'basic';
  return res.json({
    level,
    questions: DNA_QUESTIONS[level],
    totalQuestions: DNA_QUESTIONS[level].length,
    dimensions: Object.keys(DNA_QUESTIONS[level].reduce((acc, q) => { acc[q.dimension] = 1; return acc; }, {}))
  });
});

// ============================================================
// DNA — AUSWERTUNG
// ============================================================

app.post('/v1/dna/submit', authMiddleware, (req, res) => {
  const { answers, level } = req.body;
  const userId = req.user.userId;

  if (!answers || typeof answers !== 'object') {
    return res.status(400).json({ error: 'Antworten fehlen.' });
  }

  const result = calculateDnaType(answers);
  const typeInfo = DNA_TYPES[result.type];

  dnaResults[userId] = result;

  // User-Profil aktualisieren
  const user = userById[userId];
  if (user) {
    user.selfcoreType = result.type;
    user.dimensions   = result.dimensions;
  }

  return res.json({
    type: result.type,
    label: typeInfo.label,
    emoji: typeInfo.emoji,
    color: typeInfo.color,
    dimensions: result.dimensions,
    recommendedCourse: result.recommendedCourse,
    recommendedCourseInfo: COURSES_FALLBACK.find(c => c.id === result.recommendedCourse) || null,
    completedAt: result.completedAt,
    totalScore: result.totalScore
  });
});

// ============================================================
// DNA — ERGEBNIS ABRUFEN
// ============================================================

app.get('/v1/dna/results', authMiddleware, (req, res) => {
  const userId = req.user.userId;
  const dna    = dnaResults[userId];

  if (!dna) {
    return res.json({ completed: false, type: null, dimensions: null, recommendedCourse: null });
  }

  const typeInfo = DNA_TYPES[dna.type];
  return res.json({
    completed: true,
    type: dna.type,
    label: typeInfo.label,
    emoji: typeInfo.emoji,
    color: typeInfo.color,
    dimensions: dna.dimensions,
    recommendedCourse: dna.recommendedCourse,
    recommendedCourseInfo: COURSES_FALLBACK.find(c => c.id === dna.recommendedCourse) || null,
    completedAt: dna.completedAt,
    totalScore: dna.totalScore
  });
});

// ============================================================
// KURSE — ZUGANG PRÜFEN
// ============================================================

app.get('/v1/courses/:courseId/access', authMiddleware, (req, res) => {
  const { courseId } = req.params;
  const userId = req.user.userId;
  const result = canAccessCourse(userId, courseId);
  const tier   = getUserTier(userId);

  return res.json({
    courseId,
    ...result,
    tier,
    upgradeProductInfo: result.upgradeProduct ? PRODUCTS[result.upgradeProduct] : null
  });
});

// ============================================================
// KURSE — LISTE
// ============================================================

app.get('/v1/user/courses', authMiddleware, (req, res) => {
  const userId  = req.user.userId;
  const courses = loadCourses();
  const dna     = dnaResults[userId];
  const progress = lessonProgress[userId] || {};

  const enriched = courses.map(course => {
    const accessResult = canAccessCourse(userId, course.id);
    const isRecommended = dna && dna.recommendedCourse === course.id;

    const completedLessons = Object.entries(progress)
      .filter(([key, val]) => key.startsWith(course.id + '/') && val.completed)
      .length;

    return {
      ...course,
      access: accessResult.access,
      accessReason: accessResult.reason,
      moduleLimit: accessResult.moduleLimit || null,
      isRecommended,
      completedLessons,
      progressPercent: course.lessonCount > 0
        ? Math.round((completedLessons / course.lessonCount) * 100)
        : 0,
      upgradeProduct: accessResult.upgradeProduct || null
    };
  });

  return res.json(enriched);
});

// ============================================================
// KURSE — LEKTIONEN
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
  return res.json({ url: '' });
});

// ============================================================
// LEKTIONEN — ABSCHLUSS MARKIEREN
// ============================================================

app.post('/v1/lessons/:lessonId/complete', authMiddleware, (req, res) => {
  const userId   = req.user.userId;
  const lessonId = req.params.lessonId;
  const { courseId } = req.body;

  if (!lessonProgress[userId]) lessonProgress[userId] = {};
  const key = courseId ? `${courseId}/${lessonId}` : lessonId;
  lessonProgress[userId][key] = { completed: true, completedAt: new Date().toISOString() };

  return res.json({ message: 'Lektion als abgeschlossen markiert.', key, completedAt: lessonProgress[userId][key].completedAt });
});

// ============================================================
// FORTSCHRITT — ÜBERSICHT
// ============================================================

app.get('/v1/user/progress', authMiddleware, (req, res) => {
  const userId   = req.user.userId;
  const progress = lessonProgress[userId] || {};
  const courses  = loadCourses();

  const byCourse = {};
  courses.forEach(c => {
    const completed = Object.entries(progress)
      .filter(([key, val]) => key.startsWith(c.id + '/') && val.completed)
      .map(([key, val]) => ({ lessonId: key.split('/')[1], completedAt: val.completedAt }));
    byCourse[c.id] = {
      completedLessons: completed.length,
      totalLessons: c.lessonCount,
      progressPercent: c.lessonCount > 0 ? Math.round((completed.length / c.lessonCount) * 100) : 0,
      lessons: completed
    };
  });

  return res.json({ byCourse, totalCompleted: Object.values(progress).filter(v => v.completed).length });
});

// ============================================================
// SIGNAL — AUDIO
// ============================================================

app.get('/v1/user/signal-status', authMiddleware, (req, res) => {
  return res.json(canAccessSignal(req.user.userId));
});

app.get('/v1/signal/tracks', authMiddleware, (req, res) => {
  try {
    const p = path.join(__dirname, 'data', 'signal_tracks.json');
    if (fs.existsSync(p)) return res.json(JSON.parse(fs.readFileSync(p, 'utf8')));
  } catch {}
  return res.json([]);
});

app.get('/v1/signal/tracks/:trackId/url', authMiddleware, (req, res) => {
  return res.json({ url: '' });
});

// ============================================================
// USER — WEEKLY STATS
// ============================================================

app.get('/v1/user/weekly-stats', authMiddleware, (req, res) => {
  return res.json({ checkInsCount: 0, actionsCompleted: 0, dominantMood: null, dimensionChanges: {} });
});

// ============================================================
// CHECK-INS
// ============================================================

app.post('/v1/checkins', authMiddleware, (req, res) => {
  const userId = req.user.userId;
  if (!checkIns[userId]) checkIns[userId] = [];
  checkIns[userId].push({ ...req.body, savedAt: new Date().toISOString() });
  return res.json({ message: 'Check-in gespeichert.' });
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

app.get('/v1/referral/data', authMiddleware, (req, res) => {
  return res.json(buildReferralResponse(req.user.userId));
});

app.post('/v1/referral/rewards/seen', checkIdempotency, authMiddleware, (req, res) => {
  const data = referrals[req.user.userId];
  if (data) data.rewards = data.rewards.map(r => ({ ...r, isNew: false }));
  const responseData = {};
  if (res.sendCachedResponse) res.sendCachedResponse(responseData);
  return res.json(responseData);
});

// ============================================================
// REFERRAL — KERN-LOGIK
// ============================================================

function processReferral(newUserId, referralCode, newUserName) {
  const pairKey = `${newUserId}:${referralCode}`;
  if (processedReferrals.has(pairKey)) return { alreadyProcessed: true };

  const referrerId = codeToUser[referralCode];
  if (!referrerId) return { invalidCode: true };
  if (referrerId === newUserId) return { selfReferral: true };
  if (userReferredBy[newUserId]) return { alreadyReferred: true };

  processedReferrals.add(pairKey);
  userReferredBy[newUserId] = referralCode;

  if (!referrals[referrerId]) {
    referrals[referrerId] = { code: referralCode, totalReferred: 0, pendingReferred: 0, earnedDays: 0, badges: [], rewards: [], friends: [], badgeTitles: new Set() };
  }
  const ref = referrals[referrerId];

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

  const milestones = [
    { required: 1,  title: 'CONNECTOR', emoji: '🤝', color: '#5CB85C', extraDays: 0,  exclusiveTrack: null },
    { required: 3,  title: 'CATALYST',  emoji: '⚡️', color: '#00C9C9', extraDays: 0,  exclusiveTrack: 'gratitude-flow' },
    { required: 5,  title: 'PIONEER',   emoji: '🔥', color: '#FF6B35', extraDays: 7,  exclusiveTrack: null },
    { required: 10, title: 'LEGEND',    emoji: '👑', color: '#F5A623', extraDays: 30, exclusiveTrack: null },
  ];

  const earned = milestones.find(m => m.required === ref.totalReferred);
  if (earned && !ref.badgeTitles.has(earned.title)) {
    ref.badgeTitles.add(earned.title);
    ref.badges.push({ id: createRewardId('badge'), title: earned.title, emoji: earned.emoji, earnedAt: new Date().toISOString(), colorHex: earned.color });
    if (earned.extraDays > 0) {
      signalExtensions[referrerId] = (signalExtensions[referrerId] || 0) + earned.extraDays;
      ref.earnedDays += earned.extraDays;
      ref.rewards.push({ id: createRewardId('milestone'), type: 'signal_days', description: `${earned.title} Meilenstein! +${earned.extraDays} Tage GEN:SIGNAL`, daysGranted: earned.extraDays, earnedAt: new Date().toISOString(), isNew: true });
    }
    if (earned.exclusiveTrack) {
      ref.rewards.push({ id: createRewardId('track'), type: 'exclusive_track', description: 'Exklusiver Track "Gratitude Flow" freigeschaltet', daysGranted: 0, earnedAt: new Date().toISOString(), isNew: true });
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
// DATENORDNER ERSTELLEN
// ============================================================

['data', 'data/lessons'].forEach(dir => {
  const p = path.join(__dirname, dir);
  if (!fs.existsSync(p)) fs.mkdirSync(p, { recursive: true });
});

// ============================================================
// SERVER STARTEN
// ============================================================

app.listen(PORT, () => {
  console.log(`✅ GEN:SELFCORE Server läuft auf Port ${PORT}`);
  console.log(`   Health: http://localhost:${PORT}/health`);
});
