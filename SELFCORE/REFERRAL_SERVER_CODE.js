// ─────────────────────────────────────────────────────────────────────────────
// SELFCORE Referral System – Server Code (zu server.js hinzufügen)
// ─────────────────────────────────────────────────────────────────────────────
//
// WIE ES FUNKTIONIERT:
// 1. User öffnet App → GET /referral/code → bekommt seinen Code (z.B. "MAX2K4")
// 2. User teilt Link: https://genselfcore.de/join?ref=MAX2K4
// 3. Freund öffnet Link → Website speichert Code in Cookie
// 4. Freund registriert Account → POST /auth/register → Server erkennt Ref-Code
// 5. Server schreibt +7 Tage für beide → App zeigt Reward-Animation
// ─────────────────────────────────────────────────────────────────────────────

// Einfache In-Memory Datenbank (für Produktion: echte DB wie PostgreSQL/MongoDB)
const referrals = {};   // { userId: { code, totalReferred, rewards, friends } }
const codes = {};       // { "MAX2K4": userId }  (umgekehrte Suche)
const signalExtensions = {}; // { userId: extraDays }

// Hilfsfunktion: Einzigartigen Code generieren
function generateReferralCode(name = '') {
  const base = name.substring(0, 3).toUpperCase().replace(/[^A-Z]/g, 'X') || 'REF';
  const suffix = Math.random().toString(36).substring(2, 5).toUpperCase();
  return base + suffix;
}

// Hilfsfunktion: Gratis-Tage für User berechnen
function getGrantedDays(userId) {
  return signalExtensions[userId] || 0;
}

// ─── GET /v1/referral/code ──────────────────────────────────────────────────
// Gibt vorhandenen Code zurück oder erstellt neuen
app.get('/v1/referral/code', authMiddleware, (req, res) => {
  const userId = req.user.userId;

  if (!referrals[userId]) {
    referrals[userId] = {
      code: generateReferralCode(req.user.email),
      totalReferred: 0,
      pendingReferred: 0,
      earnedDays: 0,
      badges: [],
      rewards: [],
      friends: []
    };
    codes[referrals[userId].code] = userId;
  }

  const data = referrals[userId];
  res.json({
    referralCode: data.code,
    referralLink: `https://genselfcore.de/join?ref=${data.code}`,
    totalReferred: data.totalReferred,
    pendingReferred: data.pendingReferred,
    earnedDays: data.earnedDays,
    badges: data.badges,
    rewards: data.rewards,
    referredFriends: data.friends
  });
});

// ─── POST /v1/referral/code (alias, für App-Kompatibilität) ─────────────────
app.post('/v1/referral/code', authMiddleware, (req, res) => {
  req.method = 'GET';
  // Rufe dieselbe Logik auf
  const userId = req.user.userId;
  if (!referrals[userId]) {
    referrals[userId] = {
      code: generateReferralCode(req.user.email),
      totalReferred: 0, pendingReferred: 0, earnedDays: 0,
      badges: [], rewards: [], friends: []
    };
    codes[referrals[userId].code] = userId;
  }
  const data = referrals[userId];
  res.json({
    referralCode: data.code,
    referralLink: `https://genselfcore.de/join?ref=${data.code}`,
    totalReferred: data.totalReferred,
    pendingReferred: data.pendingReferred,
    earnedDays: data.earnedDays,
    badges: data.badges,
    rewards: data.rewards,
    referredFriends: data.friends
  });
});

// ─── GET /v1/referral/data ───────────────────────────────────────────────────
app.get('/v1/referral/data', authMiddleware, (req, res) => {
  const userId = req.user.userId;
  const data = referrals[userId] || { totalReferred: 0, rewards: [], friends: [] };
  res.json({
    referralCode: data.code || '',
    referralLink: data.code ? `https://genselfcore.de/join?ref=${data.code}` : '',
    totalReferred: data.totalReferred,
    pendingReferred: data.pendingReferred || 0,
    earnedDays: data.earnedDays || 0,
    badges: data.badges || [],
    rewards: data.rewards || [],
    referredFriends: data.friends || []
  });
});

// ─── POST /v1/referral/rewards/seen ─────────────────────────────────────────
app.post('/v1/referral/rewards/seen', authMiddleware, (req, res) => {
  const userId = req.user.userId;
  if (referrals[userId]) {
    referrals[userId].rewards = referrals[userId].rewards.map(r => ({ ...r, isNew: false }));
  }
  res.json({});
});

// ─── POST /v1/auth/register ──────────────────────────────────────────────────
// !! WICHTIG: Hier passiert die Referral-Logik !!
// Wenn jemand sich registriert, prüfen wir ob er über einen Ref-Link kam
app.post('/v1/auth/register', async (req, res) => {
  const { email, password, name, referralCode } = req.body;

  // TODO: Passwort hashen, User in DB speichern
  const newUserId = 'user_' + Date.now();
  const token = jwt.sign({ userId: newUserId, email }, JWT_SECRET, { expiresIn: '30d' });

  // ── Referral verarbeiten ──────────────────────────────────────────────────
  if (referralCode && codes[referralCode]) {
    const referrerId = codes[referralCode];

    // Verhindern dass jemand sich selbst einlädt
    if (referrerId !== newUserId) {

      // BUSINESS-KALKULATION:
      // Kosten pro Freund: 3 Tage ≈ 0,50 €
      // Einnahme pro Freund: Ø 3 Monate Abo = 14,97 €
      // ROI: ~3.000% — sehr profitabel

      // 1. Referrer belohnen (+3 Tage statt 7 — balance zwischen Anreiz & Kosten)
      if (!referrals[referrerId]) referrals[referrerId] = { rewards: [], friends: [], badges: [], totalReferred: 0, earnedDays: 0 };
      referrals[referrerId].totalReferred += 1;
      referrals[referrerId].earnedDays += 3;

      const newReward = {
        id: 'reward_' + Date.now(),
        type: 'signal_days',
        description: `${name || 'Dein Freund'} hat sich registriert! +3 Tage GEN:SIGNAL`,
        daysGranted: 3,
        earnedAt: new Date().toISOString(),
        isNew: true
      };
      referrals[referrerId].rewards.push(newReward);

      // Friend-Eintrag beim Referrer
      const avatarColors = ['#F5A623', '#FF6B9D', '#4A90D9', '#FF6B35', '#5CB85C', '#00C9C9'];
      referrals[referrerId].friends.push({
        id: newUserId,
        firstName: name ? name.split(' ')[0] : 'Freund',
        joinedAt: new Date().toISOString(),
        isActive: true,
        avatarColor: avatarColors[Math.floor(Math.random() * avatarColors.length)]
      });

      signalExtensions[referrerId] = (signalExtensions[referrerId] || 0) + 3;

      // 2. Meilenstein-Badges prüfen + spezielle Milestone-Rewards
      const milestones = [
        { required: 1,  title: 'CONNECTOR', emoji: '🤝', color: '#5CB85C', extraDays: 0  }, // Badge reicht
        { required: 3,  title: 'CATALYST',  emoji: '⚡️', color: '#00C9C9', extraDays: 0,
          exclusiveTrack: 'gratitude-flow' },                                                  // Exkl. Track — 0€ Kosten
        { required: 5,  title: 'PIONEER',   emoji: '🔥', color: '#FF6B35', extraDays: 7  }, // +7 Tage extra
        { required: 10, title: 'LEGEND',    emoji: '👑', color: '#F5A623', extraDays: 30  }, // +1 Monat (statt 6!)
      ];
      const total = referrals[referrerId].totalReferred;
      const earned = milestones.find(m => m.required === total);
      if (earned) {
        referrals[referrerId].badges.push({
          id: 'badge_' + Date.now(),
          title: earned.title,
          emoji: earned.emoji,
          earnedAt: new Date().toISOString(),
          colorHex: earned.color
        });
        // Milestone-Bonus-Tage obendrauf
        if (earned.extraDays > 0) {
          signalExtensions[referrerId] = (signalExtensions[referrerId] || 0) + earned.extraDays;
          referrals[referrerId].earnedDays += earned.extraDays;
          referrals[referrerId].rewards.push({
            id: 'milestone_' + Date.now(),
            type: 'signal_days',
            description: `${earned.title} Meilenstein! +${earned.extraDays} Tage GEN:SIGNAL`,
            daysGranted: earned.extraDays,
            earnedAt: new Date().toISOString(),
            isNew: true
          });
        }
        if (earned.exclusiveTrack) {
          referrals[referrerId].rewards.push({
            id: 'track_' + Date.now(),
            type: 'exclusive_track',
            description: 'Exklusiver Track "Gratitude Flow" freigeschaltet',
            daysGranted: 0,
            earnedAt: new Date().toISOString(),
            isNew: true
          });
        }
      }

      // 3. Neuen User belohnen (+3 Tage als Willkommen — reicht zum Reinschnuppern)
      signalExtensions[newUserId] = 3;
      console.log(`✅ Referral: ${name} durch Code ${referralCode} (Referrer ${referrerId}) → Referrer +3 Tage, Neuer User +3 Tage`);
    }
  }

  res.json({
    token,
    user: {
      id: newUserId,
      name: name || '',
      email,
      selfcoreType: 'ACHIEVER', // wird nach DNA-Test gesetzt
      dimensions: { selbstkenntnis: 5, authentizitaet: 5, klarheit: 5, mut: 5, verbindung: 5 }
    },
    signalFreeDays: referralCode ? 3 : 0  // 3 Tage gratis — genug zum Reinschnuppern, fair für dich
  });
});

// ─── GET /v1/user/signal-status ─────────────────────────────────────────────
// App fragt: Hat dieser User aktives Signal-Abo ODER Gratis-Tage?
app.get('/v1/user/signal-status', authMiddleware, (req, res) => {
  const userId = req.user.userId;
  const freeDays = signalExtensions[userId] || 0;
  // TODO: Echtes Abo-Status aus StoreKit-Webhook prüfen
  res.json({
    isSubscribed: false,   // Echtes Abo
    freeDaysRemaining: freeDays,
    hasAccess: freeDays > 0  // Gratis-Tage ODER Abo
  });
});

// ─── WEBSITE: Deep Link Handler ─────────────────────────────────────────────
// Wenn Nutzer https://genselfcore.de/join?ref=MAX2K4 öffnet:
// Website speichert Code in Cookie → bei Registrierung mitschicken

/*
  In deiner Website (HTML/JS):

  // Seite lädt → Code aus URL extrahieren und in Cookie speichern
  const urlParams = new URLSearchParams(window.location.search);
  const refCode = urlParams.get('ref');
  if (refCode) {
    document.cookie = `selfcore_ref=${refCode}; max-age=2592000`; // 30 Tage
  }

  // Bei Registrierung → Code aus Cookie auslesen und mitschicken
  function getRefCode() {
    const match = document.cookie.match(/selfcore_ref=([^;]+)/);
    return match ? match[1] : null;
  }

  // Beim API-Call für Registrierung:
  fetch('/v1/auth/register', {
    method: 'POST',
    body: JSON.stringify({
      email, password, name,
      referralCode: getRefCode()  // ← hier!
    })
  });
*/

// ─── APP: Deep Link (Universal Link) ────────────────────────────────────────
// Wenn jemand den Link direkt auf dem iPhone öffnet → öffnet die App
// In Info.plist:
//   CFBundleURLTypes → selfcore://
//   Associated Domains → applinks:genselfcore.de
//
// In SELFCOREApp.swift:
//   .onOpenURL { url in
//     if let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
//       .queryItems?.first(where: { $0.name == "ref" })?.value {
//       UserDefaults.standard.set(code, forKey: "pendingReferralCode")
//     }
//   }
//
// Bei Login/Registrierung → pendingReferralCode mitschicken
