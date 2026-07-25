# SKILL-INDEX — What to use when

> Use-case-first map over the 700+ skills in `.claude/skills/`. Find by job-to-be-done, not alphabet. For the full domain-organized list see `CLAUDE.md`.

---

## 🎯 Quick lookup — "I want to…"

| Goal | Primary skills | Also load |
|---|---|---|
| **Build an MT5 EA for XAUUSD** | `xauusd-gold-trading`, `mql-developer`, `profitable-ea-patterns` | `trading-risk-management`, `trading-kelly-criterion`, `trading-walk-forward-validation` |
| **Backtest a trading strategy** | `trading-backtrader` or `trading-vectorbt`, `trading-walk-forward-validation` | `trading-pandas-ta`/`trading-ta-lib`, `trading-feature-engineering`, `trading-portfolio-analytics` |
| **Build an iOS app from scratch** | `ios-dev`, `swiftui-pro`, `swiftui-patterns`, `swiftdata` | `ios-ui-craft`, `swiftui-liquid-glass`, `swiftui-navigation`, `swift-concurrency`, `app-store-review` |
| **Launch on App Store** | `app-store-review`, `apple-aso`, `ios-security` | `storekit`, `swift-testing`, `xcuitest`, `debugging-instruments` |
| **Deploy to an Ubuntu server** | `ubuntu-server-deploy` | `devops-engineer`, `monitoring-expert`, `security-reviewer` |
| **Build a Next.js SaaS** | `nextjs-shadcn`, `next-best-practices`, `react-best-practices`, `cache-components` | `supabase-postgres-best-practices`, `shadcn`, `ui-ux-pro-max`, `ai-sdk-6`, `deploy-to-vercel` |
| **Write a sales landing page** | `hormozi-offers`, `schwartz-awareness-levels`, `write-landing` | `subconscious-copywriting`, `persuasion-deep`, `page-cro`, `ui-ux-pro-max` |
| **Write a 90-min sales webinar** | `russell-brunson-perfect-webinar`, `brunson-hook-story-offer`, `hormozi-offers` | `eugene-schwartz-breakthrough-advertising`, `dan-kennedy-direct-response` |
| **Make a viral TikTok/Reels/Shorts** | `create-viral-content`, `social-algorithm-insights-2026`, `video-ad-analysis` | `marketing-psychology`, `youtube-creator`, `ffmpeg`, `moviepy` |
| **Write a viral X/Twitter thread** | `thread-writer`, `x-impact-checker`, `marketing-psychology` | `copywriting`, `subconscious-copywriting` |
| **Launch a product** | `launch-strategy`, `hormozi-offers`, `brunson-hook-story-offer` | `schwartz-awareness-levels`, `dan-kennedy-direct-response`, `russell-brunson-perfect-webinar`, `lead-magnets` |
| **Diagnose a prospect before writing** | `schwartz-awareness-levels`, `marketing-psych-awareness-analyzer`, `icp-builder` | `customer-research`, `mom-test` |
| **Audit any copy** | `marketing-psych-persuasion-auditor` (Cialdini), `marketing-psych-nesb-scorer`, `marketing-psych-copy-optimizer` | `persuasion-deep`, `copy-editing` |
| **Build an email sequence** | `email-sequence`, `email-subject-lines`, `dan-kennedy-direct-response` | `persuasion-deep`, `copywriting` |
| **Run paid ads** | `ads-audit`, `ads-plan`, platform-specific (`ads-meta`, `ads-google`, `ads-tiktok`, `ads-youtube`, etc.) | `ad-creative`, `ads-test`, `video-ad-analysis` |
| **Design a UI from scratch** | `ui-ux-pro-max`, `frontend-design`, `ui-styling` | `design-system`, `design-everyday-things`, `refactoring-ui`, `brand` |
| **Do CRO on a site** | `cro-methodology`, `page-cro`, `ab-test-setup`, `analytics-tracking` | `ui-ux-pro-max`, `subconscious-copywriting`, `hormozi-offers` |
| **Build a chatbot / AI app** | `ai-app`, `ai-sdk-6`, `ai-elements`, `nextjs-chatbot` | `claude-api`, `rag-architect`, `prompt-engineer` |
| **Write or refactor Python/Rust/Go/etc.** | `python-pro` / `rust-engineer` / `golang-pro` / `java-architect` | `code-reviewer`, `systematic-debugging`, `test-master` |
| **Build an MCP server** | `mcp-builder`, `mcp-developer` | `claude-api`, `python-pro` / `typescript-pro` |

---

## 🏗️ Full workflows (when you're doing a big thing)

### Building a profitable XAUUSD EA
1. `xauusd-gold-trading` — Gold-specific knowledge, sessions, news, correlations
2. `profitable-ea-patterns` — the 7 laws, what actually works, what blows up
3. `mql-developer` — MQL5 language, EA architecture, OrderSend, indicators
4. `trading-risk-management` — portfolio heat, drawdown caps
5. `trading-position-sizing` + `trading-kelly-criterion` — dynamic lot sizing
6. `trading-walk-forward-validation` — out-of-sample testing
7. `trading-backtrader` or `trading-vectorbt` — Python prototype first
8. `trading-volatility-modeling` + `trading-regime-detection` — regime filters
9. `trading-exit-strategies` — trailing stops, partial TPs
10. `trading-trade-journal` — log everything, review weekly

### Building an iOS app and launching it
1. `ios-dev` — start here
2. `swiftui-pro` / `swiftui-patterns` — MV architecture, modern APIs
3. `swiftdata` + `cloudkit` — data + sync
4. `swiftui-liquid-glass` + `ios-ui-craft` — iOS 26 polish
5. `storekit` — monetization
6. `widgetkit` + `activitykit` — widgets, Dynamic Island
7. `app-intents` — Siri/Shortcuts integration
8. `swift-testing` + `xcuitest` — tests
9. `debugging-instruments` — profile before shipping
10. `ios-security` + `authentication` — hardening
11. `app-store-review` + `apple-aso` — launch

### Launching a paid course/coaching program
1. `customer-research` + `mom-test` — find the real mass desire
2. `schwartz-awareness-levels` — where is the audience's head?
3. `hormozi-offers` — build the Grand Slam Offer
4. `brunson-hook-story-offer` — content to drive traffic
5. `russell-brunson-perfect-webinar` — the 90-min sales presentation
6. `dan-kennedy-direct-response` — long-form sales page + follow-up
7. `write-landing` — the checkout page
8. `email-sequence` + `email-subject-lines` — nurture + launch sequence
9. `ads-audit` + `ads-meta` / `ads-google` — paid traffic
10. `launch-strategy` — orchestrate the rollout
11. `persuasion-deep` + `subconscious-copywriting` — word-level polish

### Growing a TikTok / Instagram / YouTube channel
1. `social-algorithm-insights-2026` — what the algorithms reward in 2026
2. `create-viral-content` — 18 psychological hook patterns
3. `marketing-psychology` + `persuasion-deep` — triggers
4. `content-strategy` + `content-calendar` — what to post when
5. `content-repurposing` — 1 long video → 10 platform posts
6. `video-ad-analysis` — deconstruct winners
7. `thread-writer` — X/Reddit variants
8. `youtube-creator` — YouTube-specific retention engineering
9. `youtube-analytics` — read the data
10. `x-impact-checker` — score X posts before publishing
11. `ffmpeg` / `moviepy` — edit the videos

### Deploying any web app to a fresh Ubuntu server
1. `ubuntu-server-deploy` — the full playbook
2. `devops-engineer` — Dockerfiles, systemd services
3. `security-reviewer` — hardening audit
4. `monitoring-expert` — Prometheus + Grafana / log shipping
5. `postgres-pro` (if database) — tuning
6. `deploy-to-vercel` (alternative for static + edge)

### Building a Next.js + Supabase SaaS
1. `nextjs-shadcn` — scaffold
2. `next-best-practices` + `react-best-practices` (Vercel) — architecture
3. `cache-components` — PPR and caching
4. `shadcn` + `ui-styling` + `ui-ux-pro-max` — UI
5. `supabase-postgres-best-practices` + `postgres-pro` — backend
6. `ai-sdk-6` + `ai-elements` — if AI features
7. `page-cro` + `signup-flow-cro` + `onboarding-cro` — conversion
8. `deploy-to-vercel` + `vercel-cli-with-tokens` — ship it

### Writing any piece of sales/marketing copy
**The stack in order:**
1. `customer-research` → get the mass desire in their words
2. `schwartz-awareness-levels` → diagnose where they are
3. `brunson-hook-story-offer` → structure the content
4. `hormozi-offers` → package the offer
5. `dan-kennedy-direct-response` → write the long-form
6. `subconscious-copywriting` → word-level polish
7. `marketing-psych-persuasion-auditor` → final Cialdini audit
8. `marketing-psych-nesb-scorer` → score headlines before publish

---

## 🧭 Decision trees

### "I need to persuade someone to do something"
- Is it in writing? → `copywriting` + `subconscious-copywriting`
- Is it a sales page? → `hormozi-offers` + `dan-kennedy-direct-response`
- Is it a conversation? → `negotiation` (Chris Voss)
- Is it a presentation? → `russell-brunson-perfect-webinar`
- Is it a headline? → `eugene-schwartz-breakthrough-advertising` (36 formulas) + `marketing-psych-nesb-scorer`
- Is it a tribe/movement? → `brunson-hook-story-offer` (Expert Secrets part)

### "I need to diagnose why something isn't converting"
- Landing page → `cro-methodology`, `page-cro`, `ui-ux-pro-max`
- Signup → `signup-flow-cro`, `form-cro`
- Onboarding → `onboarding-cro`
- Paywall → `paywall-upgrade-cro`
- Ad creative → `video-ad-analysis`, `ads-creative`, `ads-audit`
- Email → `email-subject-lines`, `email-sequence`
- Copy tone/emotion → `marketing-psych-voice-extractor`, `subconscious-copywriting`
- Offer weakness → `hormozi-offers` audit checklist
- Wrong audience → `schwartz-awareness-levels`, `marketing-psych-awareness-analyzer`

### "Something is slow / broken"
- iOS app slow → `swiftui-performance`, `guide-swiftui-performance-audit`, `debugging-instruments`, `metrickit`
- Web app slow → `react-best-practices`, `next-best-practices`, `cache-components`
- Database slow → `postgres-pro`, `database-optimizer`, `sql-pro`
- Build failing → `systematic-debugging`, `debugging-wizard`
- Tests flaky → `test-flakiness`
- Production incident → `sre-engineer`, `monitoring-expert`, `chaos-engineer`

### "I need to ship something today"
- `ubuntu-server-deploy` (if deploying to VPS)
- `deploy-to-vercel` (if Next.js)
- `hotfix` (if fixing a broken thing)
- `day-one-patch` (if launching)

---

## 🧠 Frameworks that compose well

Some skills are meant to be chained:

- **The Direct Response Chain:** `schwartz-awareness-levels` → `eugene-schwartz-breakthrough-advertising` → `brunson-hook-story-offer` → `hormozi-offers` → `dan-kennedy-direct-response` → `russell-brunson-perfect-webinar` → `persuasion-deep` → `subconscious-copywriting`
- **The Trading Chain:** `profitable-ea-patterns` → `xauusd-gold-trading` → `mql-developer` → `trading-risk-management` → `trading-walk-forward-validation` → `trading-backtrader`/`trading-vectorbt` → `trading-exit-strategies` → `trading-trade-journal`
- **The iOS App Chain:** `ios-dev` → `swiftui-patterns` → `swiftdata` → `swiftui-liquid-glass` → `storekit` → `swift-testing` → `debugging-instruments` → `app-store-review` → `apple-aso`
- **The SaaS Chain:** `nextjs-shadcn` → `next-best-practices` → `supabase-postgres-best-practices` → `page-cro` → `email-sequence` → `hormozi-offers` → `launch-strategy`

---

## 📚 Custom deep skills (built specifically for this project)

These are the skills I authored from scratch for your use cases — they combine multiple sources into single deep references:

| Skill | Purpose |
|---|---|
| `xauusd-gold-trading` | Gold-specific trading: sessions, news, correlations, MQL5 boilerplate, broker considerations |
| `profitable-ea-patterns` | The 7 laws of survivable EAs, what actually works, honest math |
| `social-algorithm-insights-2026` | Current TikTok/IG/YT/X/LinkedIn ranking signals, hook engineering, retention |
| `ubuntu-server-deploy` | Full production playbook: nginx/Caddy, certbot, systemd, UFW, fail2ban, Postgres, backups, zero-downtime |
| `persuasion-deep` | Cialdini's 7 + 50 cognitive biases + behavioral economics + direct response masters |
| `subconscious-copywriting` | Milton Model, embedded commands, VAKOG, pacing-and-leading, trance induction |
| `hormozi-offers` | $100M Offers — Value Equation, Grand Slam Offer, stacking, guarantees, MAGIC naming |
| `brunson-hook-story-offer` | Hook/Story/Offer, 10-step Epiphany Bridge, Attractive Character, Value Ladder, Dream 100 |
| `schwartz-awareness-levels` | 5 Awareness Levels × 5 Sophistication Stages, diagnostic questions, lookup tables |
| `eugene-schwartz-breakthrough-advertising` | Deep Schwartz: Mass Desire, performance/mechanism claims, 6 ways to sell, 36 headlines |
| `dan-kennedy-direct-response` | No BS philosophy, 10 Commandments, sales letter structure, Magnetic Marketing, pricing |
| `russell-brunson-perfect-webinar` | 90-min slide-by-slide script, 3 Secrets, Stack & Close, 6 closes, follow-up |

---

## 🔍 When you don't know what you need

Ask Claude Code directly:
- *"What skills do I have for [topic]?"*
- *"Is there a skill for X?"*
- *"What's the right skill chain for building Y?"*

Or use these orchestrators:
- `brainstorming` — use before any creative work
- `writing-plans` — before any multi-step task
- `skill-creator` — if you realize you need a skill that doesn't exist yet, build it
