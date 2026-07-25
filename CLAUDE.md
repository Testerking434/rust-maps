# CLAUDE.md

> Persistent project memory for Claude Code. Loaded automatically at the start of every session.

## Project

- **Repo:** `testerking434/rust-maps`
- **Purpose:** ⚠️ Repo name is coincidental — **NOT about the Rust game**. This repo is the user's **"second brain"**: a central skill/memory hub serving every project they work on (trading EAs, social media growth, mobile apps, web, Ubuntu deploys, etc.). Treat as a persistent workspace, not a single-project repo.
- **Active project lines the user cares about:**
  1. **Trading bots / Expert Advisors** — building profitable MT5 EAs, especially for XAUUSD (Gold). Focus: survivable risk management, not martingale/guru scams.
  2. **Social media growth** — TikTok / Instagram Reels / YouTube Shorts / X, viral hook engineering, algorithm exploitation, creator economy.
  3. **Ubuntu server deploys** — frequent, production-grade.
  4. **Apple / iOS apps** — SwiftUI production apps.
  5. More to come.
- **Owner language:** German. Reply in German by default.
- **Primary working branch:** `claude/install-ui-ux-repo-A8tE6`
- **Never** push directly to `main` without explicit permission.

## Skill library — 700+ skills in `.claude/skills/`

All auto-discovered by Claude Code. Organized by domain:

### 1. Apple / iOS / macOS (~110 skills)
Full iOS 26+ framework coverage: SwiftUI (all aspects + `swiftui-pro`, `swiftui-liquid-glass`, `ios-ui-craft`), SwiftData, CloudKit, HealthKit, HomeKit, WeatherKit, CarPlay, StoreKit 2, PassKit, RealityKit, SpriteKit, SceneKit, GameKit, Core ML, Vision, Speech, AlarmKit, WidgetKit, ActivityKit (Dynamic Island), App Intents, App Clips, Swift Testing, XCUITest, debugging-instruments, app-store-review, apple-aso, ios-security, authentication. Sources: dpearson2699/swift-ios-skills, vabole/apple-skills, twostraws/SwiftUI-Agent-Skill, jeffallan/claude-skills (swift-expert).

### 2. Android / Kotlin / Cross-Platform (~5)
- `android-skill` (NowInAndroid best practices)
- `android-ninja` (Navigation3, modular, Gradle)
- `jetpack-compose` (Compose + Compose Multiplatform)
- `kotlin-specialist` (coroutines, Flow, KMP)
- `flutter-expert` (Dart, Riverpod/Bloc, widgets)
- `react-native-expert`, `react-native-skills`

### 3. Web / Frontend / UI (~50)
- **UI/UX Pro Max:** `ui-ux-pro-max`, `ui-styling`, `design`, `design-system`, `brand`, `banner-design`, `slides`
- **Vercel official:** `react-best-practices`, `web-design-guidelines`, `composition-patterns`, `react-view-transitions`, `deploy-to-vercel`, `vercel-cli-with-tokens`
- **Next.js / React stack:** `next-best-practices`, `nextjs-chatbot`, `nextjs-seo`, `nextjs-shadcn`, `cache-components`, `shadcn`, `react-expert`, `typescript-pro`, `javascript-pro`, `vue-expert`, `angular-architect`
- **AI apps:** `ai-app`, `ai-elements`, `ai-sdk`, `ai-sdk-6`, `openai-agents-sdk`, `claude-api`, `rag-architect`, `fine-tuning-expert`, `prompt-engineer`
- **Anthropic official:** `frontend-design`, `webapp-testing` (Playwright), `canvas-design`, `theme-factory`, `web-artifacts-builder`, `algorithmic-art`, `skill-creator`, `mcp-builder`, `mcp-developer`
- **Office:** `pdf`, `docx`, `xlsx`, `pptx`, `doc-coauthoring`

### 4. Backend Languages / Frameworks (~40)
- **Python:** `python-pro`, `fastapi-expert`, `django-expert`, `pandas-pro`
- **Rust:** `rust-engineer`
- **Go:** `golang-pro`
- **Java / JVM:** `java-architect`, `spring-boot-engineer`, `kotlin-specialist`
- **.NET:** `csharp-developer`, `dotnet-core-expert`
- **C/C++:** `cpp-pro`, `embedded-systems`
- **PHP:** `php-pro`, `laravel-specialist`, `wordpress-pro`
- **Ruby:** `rails-expert`
- **Node/TS:** `typescript-pro`, `javascript-pro`, `nestjs-expert`
- **DB/SQL:** `sql-pro`, `postgres-pro`, `database-optimizer`, `postgres-semantic-search`, `supabase-postgres-best-practices`
- **APIs:** `api-designer`, `graphql-architect`, `websocket-engineer`
- **Architecture:** `microservices-architect`, `cloud-architect`, `legacy-modernizer`, `fullstack-guardian`
- **Data/ML:** `ml-pipeline`, `spark-engineer`, `pandas-pro`, `scikit-learn`, `pytorch-lightning`, `transformers`, `matplotlib`, `seaborn`, `dask`, `statistical-analysis`, `exploratory-data-analysis`

### 5. DevOps / Deploy / Infra (~30)
- **Ubuntu server deploy** (custom): `ubuntu-server-deploy` — nginx, caddy, certbot, systemd, UFW, fail2ban, PostgreSQL, backup, hardening
- **Containers/K8s:** `devops-engineer`, `kubernetes-specialist`, `sre-engineer`
- **Terraform:** `terraform-engineer`, `terraform-plan-review`, `terraform-drift-detection`, `terraform-state-operations`, `provider-upgrade-analysis`, `aws-profile-management`, `auto-documentation`
- **Observability:** `monitoring-expert`, `chaos-engineer`
- **CI/CD workflow:** `writing-plans`, `executing-plans`, `verification-before-completion`, `using-git-worktrees`, `subagent-driven-development`, `dispatching-parallel-agents`, `finishing-a-development-branch`, `requesting-code-review`, `receiving-code-review`, `historical-pattern-analysis`, `systematic-debugging`, `test-driven-development`, `brainstorming`, `writing-skills`, `devops-skills`, `using-devops-skills`
- **Security:** `security-reviewer`, `secure-code-guardian`, `code-reviewer`, `code-documenter`, `debugging-wizard`, `cli-developer`

### 6. Game Development (~80)
- **Studio pipeline** (Donchitos/Claude-Code-Game-Studios): `team-ui`, `team-combat`, `team-level`, `team-narrative`, `team-audio`, `team-polish`, `team-qa`, `team-release`, `team-live-ops`, `brainstorm`, `art-bible`, `create-architecture`, `architecture-decision`, `create-epics`, `create-stories`, `dev-story`, `sprint-plan`, `sprint-status`, `gate-check`, `perf-profile`, `playtest-report`, `launch-checklist`, `balance-check`, `security-audit`, `tech-debt`, `asset-spec`, `asset-audit`, `prototype`, `quick-design`, `hotfix`, `day-one-patch`, `patch-notes`, `changelog`, `localize`, …
- **Engines:**
  - Apple-native: `spritekit`, `scenekit`, `realitykit`, `gamekit`, `tabletopkit`, `metrickit`
  - **Godot:** `godot-randroids`, `godot-godogen`, `godot-godot-api`, `godot-visual-qa`
  - **Unreal:** `unreal-randroids`

### 7. Marketing / Growth / Social Media (~110)
Full arsenal for solo founders and creators. Sources: coreyhaines31/marketingskills (36), OpenClaudia/openclaudia-skills (47 unique), aaaronmiller/create-viral-content.
- **Viral content / hooks:** `create-viral-content`, `thread-writer` (Twitter/X threads, Reddit), `copywriting`, `copy-editing`, `marketing-psychology` (mental models, triggers), `marketing-ideas`
- **Social platforms:** `social-content`, `linkedin-content`, `content-calendar`, `content-repurposing`, `bluesky`, `reddit-marketing`, `podcast-marketing`, `community-marketing`, `newsletter`
- **Video ads analysis:** `video-ad-analysis`, `ad-creative`, `facebook-ads`, `google-ads`, `linkedin-ads`, `paid-ads`, `google-ads-report`
- **Email:** `email-sequence`, `email-subject-lines`, `cold-email`, `apollo-outreach`
- **SEO:** `seo-audit`, `seo-content-brief`, `programmatic-seo`, `ai-seo`, `schema-markup`, `site-architecture`, `write-blog`, `write-landing`, `keyword-research`, `serp-analyzer`, `content-gap-analysis`, `ahrefs-research`, `semrush-research`, `backlink-audit`, `search-console`, `geo-query-finder`
- **CRO / Conversion:** `page-cro`, `signup-flow-cro`, `onboarding-cro`, `popup-cro`, `form-cro`, `paywall-upgrade-cro`, `ab-test-setup`, `analytics-tracking`, `google-analytics`
- **Growth / strategy:** `growth-strategy`, `launch-strategy`, `demand-gen`, `icp-builder`, `customer-research`, `competitor-analysis`, `competitor-alternatives`, `content-strategy`, `product-marketing`, `product-marketing-context`, `pricing-strategy`, `referral-program`, `affiliate-marketing`, `free-tool-strategy`, `lead-magnets`, `lead-magnet`, `sales-enablement`, `revops`, `churn-prevention`, `aso-audit`
- **Brand research / monitoring:** `brand-research`, `brand-monitor`, `google-reviews`, `domain-research`
- **Bots / integrations:** `telegram-bot`, `discord-bot`, `slack-bot`, `feishu-lark`, `hubspot`, `i18n`, `stock-images`, `ai-image-gen`
- **Platform-specific ads audits (19 sub-skills):** `ads-audit`, `ads-creative`, `ads-meta`, `ads-google`, `ads-tiktok`, `ads-youtube`, `ads-linkedin`, `ads-apple`, `ads-microsoft`, `ads-budget`, `ads-test`, `ads-competitor`, `ads-dna`, `ads-plan`, `ads-math`, `ads-landing`, `ads-photoshoot`, `ads-create`, `ads-generate`
- **YouTube creator (deep):** `youtube-creator` — channel audits, retention scripts, hooks, Shorts, analytics, monetization
- **X algorithm analyzer:** `x-impact-checker` — uses actual X recommendation algorithm
- **Custom deep insights:** `social-algorithm-insights-2026` — TikTok/IG Reels/YT Shorts/X/LinkedIn ranking signals, hook engineering, retention curves, posting cadence (current as of 2026)

### 8. Trading / Quant / Expert Advisors (~90) — **NEW**
Complete direct-response-to-execution trading stack.
- **Custom skills authored for this project:**
  - `xauusd-gold-trading` — Gold sessions, news events, correlations, MQL5 boilerplate, backtest gotchas
  - `profitable-ea-patterns` — the 7 laws of survivable EAs, what actually works, what blows accounts, Kennedy-grade math
- **MQL5 / MetaTrader:** `mql-developer` — full MQL4/MQL5 reference, EA architecture, indicators, risk mgmt, backtesting
- **Quant frameworks:** `trading-backtrader`, `trading-vectorbt`, `trading-pandas-ta`, `trading-ta-lib`, `trading-walk-forward-validation`, `trading-strategy-framework`
- **Risk / sizing:** `trading-risk-management`, `trading-kelly-criterion`, `trading-position-sizing`, `trading-portfolio-analytics`, `trading-exit-strategies`
- **Strategies:** `trading-mean-reversion`, `trading-regime-detection`, `trading-volatility-modeling`, `trading-cointegration-analysis`, `trading-correlation-analysis`, `trading-market-microstructure`, `trading-market-microstructure-traditional`
- **ML for trading:** `trading-signal-classification`, `trading-feature-engineering`, `trading-rl-execution`, `trading-sentiment-analysis`
- **Execution / data:** `trading-ohlcv-processing`, `trading-slippage-modeling`, `trading-custom-indicators`, `trading-trading-visualization`
- **Admin / tax:** `trading-trade-journal`, `trading-trade-accounting`, `trading-cost-basis-engine`, `trading-tax-liability-tracking`, `trading-tax-loss-harvesting`, `trading-wash-sale-detection`, `trading-crypto-tax-export`, `trading-regulatory-reporting`, `trading-fixed-income`, `trading-options-pricing`
- **DeFi / Solana on-chain:** `trading-solana-rpc`, `trading-solana-tx-building`, `trading-jito-bundles`, `trading-shredstream`, `trading-yellowstone-grpc`, `trading-mev-analysis`, `trading-dex-execution`, `trading-dex-pool-analysis`, `trading-raptor-dex`, `trading-pumpfun-mechanics`, `trading-helius-api`, `trading-birdeye-api`, `trading-defillama-api`, `trading-coingecko-api`, `trading-dexscreener-api`, `trading-solanatracker-api`, `trading-liquidity-analysis`, `trading-yield-analysis`, `trading-impermanent-loss`, `trading-lp-math`, `trading-token-economics`, `trading-token-holder-analysis`, `trading-whale-tracking`, `trading-wallet-profiling`, `trading-sybil-detection`, `trading-copy-trading`
- **Equity / stock analysis (10):** `equity-technical-analyst`, `equity-sector-analyst`, `equity-market-environment-analysis`, `equity-us-market-bubble-detector`, `equity-earnings-calendar`, `equity-economic-calendar-fetcher`, `equity-market-news-analyst`, `equity-us-stock-analysis`, `equity-breadth-chart-analyst`, `equity-stanley-druckenmiller-investment`

### 9. Persuasion / Copywriting / Psychology (Deep) — **NEW**
Everything about moving humans to decisions. The deep stack:
- **Custom deep skills:**
  - `persuasion-deep` — Cialdini's 7 principles, 50 most actionable cognitive biases, behavioral economics (Kahneman, Thaler, Ariely), Blair Warren's one-sentence persuasion, Halbert/Schwartz/Caples direct response principles
  - `subconscious-copywriting` — Milton Model (presuppositions, embedded commands, mind-reads, double binds), VAKOG sensory language, Epiphany Bridge story architecture, rhythm/cadence, pacing-and-leading, trance induction, negation trick
- **Books-as-skills (wondelai):** `influence-psychology` (Cialdini), `made-to-stick` (Heath SUCCESS), `storybrand-messaging` (Donald Miller), `hooked-ux` (Nir Eyal), `jobs-to-be-done`, `negotiation` (Chris Voss), `contagious` (Jonah Berger STEPPS), `drive-motivation` (Pink), `obviously-awesome` (April Dunford positioning), `one-page-marketing` (Dib), `predictable-revenue` (Ross), `mom-test` (Fitzpatrick), `scorecard-marketing`, `traction-eos` (Wickman), `blue-ocean-strategy`, `crossing-the-chasm`, `lean-startup`, `lean-ux`, `37signals-way`, `inspired-product` (Cagan), `continuous-discovery` (Torres), `design-everyday-things` (Norman), `design-sprint`, `microinteractions`, `top-design`, `refactoring-ui`, `ux-heuristics`, `cro-methodology`, `hundred-million-offers` (Hormozi)
- **Marketing psychology (az9713):** `marketing-psych-awareness-analyzer` (Schwartz diagnose), `marketing-psych-persuasion-auditor` (Cialdini audit), `marketing-psych-tribe-builder` (Blair Warren), `marketing-psych-nesb-scorer` (NEW-EASY-SAFE-BIG headline scorer), `marketing-psych-copy-optimizer` (Yes! 50 Ways), `marketing-psych-voice-extractor`, `marketing-psych-competitor-analyzer`, `marketing-psych-content-generator`

### 10. Business Next Level — the 6 master frameworks — **NEW**
The complete direct-response stack, written as 6 deep custom skills:
1. **`hormozi-offers`** — $100M Offers: Value Equation (Dream Outcome × Perceived Likelihood / Time Delay × Effort), Grand Slam Offer structure, bonus stacking, 4 guarantee types, real scarcity/urgency, MAGIC naming, pricing philosophy, audit checklist
2. **`brunson-hook-story-offer`** — Russell Brunson's universal content formula: Hook/Story/Offer, 3 hook types, 10-step Epiphany Bridge, Attractive Character archetypes, Value Ladder, Dream 100 traffic strategy, Expert Secrets movement building, application patterns for every content format
3. **`schwartz-awareness-levels`** — Eugene Schwartz's 5 Awareness Levels (Unaware → Most Aware) × 5 Market Sophistication Stages, diagnostic questions, quick lookup table for angle/length/channel, crossover with Brunson's hook types
4. **`eugene-schwartz-breakthrough-advertising`** — Deep Schwartz: Mass Desire theory, 3 attributes (urgency/intensity/scope), performance vs mechanism claims, 6 fundamental ways to sell (Promise+Proof, Identification, Secret, Gossip, Social Proof, Unique Mechanism), 36 proven headline formulas, Uniqueness Claim template, Schwartz's working process, 8 laws
5. **`dan-kennedy-direct-response`** — No BS philosophy, 10 Commandments, Message-Market-Media Match, full long-form sales letter structure with P.S. stack, Magnetic Marketing (Lead Magnet, Phantom Offer, Herd), No BS Pricing (takeaway selling, premium rule), 30/30/30/10 attention allocation, 15 copywriting rules, Renegade Millionaire mindset, advanced guarantees
6. **`russell-brunson-perfect-webinar`** — The 90-minute slide-by-slide script that has sold $100M+: Big Promise hook, Origin Story (Epiphany Bridge), One Thing (new vehicle), 3 Secrets belief-breaking (Vehicle/Internal/External), Transition script, Stack & Close visual, 6 rotating closes, Q&A as second close, 4-day post-webinar follow-up sequence

**Use together**: Schwartz awareness diagnose → Brunson HSO content → Hormozi offer → Kennedy accountability → Brunson Stack & Close → persuasion-deep + subconscious-copywriting for word-level craft.

### 11. Media / Video / Audio / AI-Gen (~12)
- **Video:** `ffmpeg`, `moviepy`, `remotion`, `playwright-recording`, `ltx2` (AI video gen)
- **Audio:** `elevenlabs` (voiceover, SFX, music), `acestep` (AI music)
- **Image:** `qwen-edit` (AI image editing)
- **Compute:** `runpod` (cloud GPU)

### 12. Testing / QA
`test-master`, `playwright-expert`, `webapp-testing`, `swift-testing`, `xcuitest`, `test-driven-development`, `test-flakiness`, `test-evidence-review`, `regression-suite`, `smoke-check`, `soak-test`, `qa-plan`, `test-setup`, `test-helpers`

## Performance & memory strategy

1. **This CLAUDE.md** — project-level persistent memory. Append important decisions here as they come up.
2. **Skills as second brain** — each skill has its own SKILL.md with references. I load the right skill on demand instead of keeping everything in head.
3. **✅ MCP memory server IS ACTIVE** — configured in `.claude/settings.json`, uses `@modelcontextprotocol/server-memory`. Knowledge graph stored in `.claude/memory.json` (gitignored, private). Claude can create entities, relations, and observations that persist across all future sessions in this project.
   - Use `mcp__memory__create_entities` to store new facts/decisions
   - Use `mcp__memory__add_observations` to enrich existing entities
   - Use `mcp__memory__search_nodes` to recall prior context
   - This complements CLAUDE.md: CLAUDE.md = static docs, memory.json = dynamic graph

## Workflow rules

- Always develop on `claude/install-ui-ux-repo-A8tE6` unless the user says otherwise.
- **Never** `git push --force` or `git reset --hard` without explicit confirmation.
- Prefer editing existing files over creating new ones.
- Speak German in the chat unless the user switches language.
- When a skill matches the task, **use** it instead of re-deriving from scratch.
- Before editing `grand-falls.map`, ALWAYS back it up first (`cp grand-falls.map grand-falls.map.bak`).

## Important facts about the user

- Requests are often short and in informal German — interpret generously.
- Deploys frequently to **Ubuntu servers** — the `ubuntu-server-deploy` skill is tailored for this.
- User wants **maximum capability + performance + memory** ("damit du nix mehr vergisst").
- User prefers that I decide and act rather than ask many clarification questions.

## Changelog

- **2026-04-14 (1):** Initial install of UI/UX Pro Max + 200 skills (Apple, web, game-dev). Created CLAUDE.md as persistent memory.
- **2026-04-14 (2):** Added 100+ skills closing all gaps: Android/Kotlin/Compose, Unreal + Godot, backend languages (Python/Rust/Go/Java/.NET/C++/PHP/Ruby), DevOps + Terraform + K8s + 20 workflow skills, Video/Audio/AI-gen (ffmpeg/moviepy/remotion/elevenlabs/acestep/ltx2/qwen-edit), Data Science. Built custom skill `ubuntu-server-deploy`.
- **2026-04-14 (3):** User clarified: repo name coincidental, **NOT about Rust game**. Removed `rust-map-format` custom skill. Added 84 marketing/growth skills (coreyhaines31/marketingskills + OpenClaudia/openclaudia-skills + create-viral-content) covering viral hooks, copywriting, SEO, CRO, ads, email, social platforms, growth. **Activated MCP memory server** (`@modelcontextprotocol/server-memory`) via `.claude/settings.json` for persistent cross-session knowledge graph in `.claude/memory.json`.
- **2026-04-14 (4):** Added Trading/EA stack (~86 skills): MQL5 dev, 62 agiprolabs trading/quant/DeFi skills (trading-* prefix), 10 equity analysis skills (equity-* prefix), plus 3 custom: `xauusd-gold-trading`, `profitable-ea-patterns`, `social-algorithm-insights-2026`. Added YouTube creator deep skill, 19 ads-* platform skills, and x-impact-checker (X algorithm analyzer).
- **2026-04-14 (5):** Added deep persuasion/copywriting stack: 29 wondelai business/psychology skills (influence-psychology/Cialdini, made-to-stick, storybrand-messaging, hooked-ux, negotiation/Voss, contagious, jobs-to-be-done, hundred-million-offers, plus 20 more), 8 marketing-psych-* skills from az9713, and 2 custom deep skills: `persuasion-deep` (Cialdini + 50 biases + behavioral economics) and `subconscious-copywriting` (Milton Model + NLP + hypnotic patterns).
- **2026-04-14 (6):** Added the **Business Next Level** stack — 6 custom deep skills synthesizing the complete direct-response canon: `hormozi-offers`, `brunson-hook-story-offer`, `schwartz-awareness-levels`, `eugene-schwartz-breakthrough-advertising`, `dan-kennedy-direct-response`, `russell-brunson-perfect-webinar`. Together they cover every major framework from the last 60 years of direct-response marketing.
