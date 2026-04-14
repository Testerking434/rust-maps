# CLAUDE.md

> Persistent project memory for Claude Code. Loaded automatically at the start of every session.

## Project

- **Repo:** `testerking434/rust-maps`
- **Purpose:** Personal Rust (game) custom maps — `.map` files for the Rust game server.
- **Working file:** `grand-falls.map`
- **Owner language:** German. Reply in German by default.
- **Primary working branch:** `claude/install-ui-ux-repo-A8tE6`
- **Never** push directly to `main` without explicit permission.

## Skill library — 320+ skills in `.claude/skills/`

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
- **Custom:** `rust-map-format` — Rust (Facepunch) `.map` format, WorldSerialization protobuf, RustEdit conventions

### 7. Media / Video / Audio / AI-Gen (~12)
- **Video:** `ffmpeg`, `moviepy`, `remotion`, `playwright-recording`, `ltx2` (AI video gen)
- **Audio:** `elevenlabs` (voiceover, SFX, music), `acestep` (AI music)
- **Image:** `qwen-edit` (AI image editing)
- **Compute:** `runpod` (cloud GPU)

### 8. Testing / QA
`test-master`, `playwright-expert`, `webapp-testing`, `swift-testing`, `xcuitest`, `test-driven-development`, `test-flakiness`, `test-evidence-review`, `regression-suite`, `smoke-check`, `soak-test`, `qa-plan`, `test-setup`, `test-helpers`

## Performance & memory strategy

1. **This CLAUDE.md** — project-level persistent memory. Append important decisions here as they come up.
2. **Skills as second brain** — each skill has its own SKILL.md with references. I load the right skill on demand instead of keeping everything in head.
3. **Optional MCP memory server** for cross-session knowledge graph — can be added via `.claude/settings.json`:
   ```json
   {
     "mcpServers": {
       "memory": {
         "command": "npx",
         "args": ["-y", "@modelcontextprotocol/server-memory"]
       }
     }
   }
   ```
   Not installed yet — enable only when really needed to avoid slowing startup.

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
- **2026-04-14 (2):** Added 100+ skills closing all gaps: Android/Kotlin/Compose (android-skill, android-ninja, jetpack-compose), Unreal + Godot (unreal-randroids, godot-*), backend languages (python-pro, rust-engineer, golang-pro, java-architect, csharp-developer, cpp-pro, php-pro, rails-expert, …), DevOps + Terraform + K8s (devops-engineer, terraform-engineer, kubernetes-specialist, sre-engineer, monitoring-expert + 20 lgbarn workflow skills), Video/Audio (ffmpeg, moviepy, remotion, elevenlabs, acestep, ltx2, qwen-edit, runpod, playwright-recording), Data Science (scikit-learn, pytorch-lightning, transformers, matplotlib, seaborn, dask, statistical-analysis, exploratory-data-analysis, pandas-pro). Built 2 custom skills: `ubuntu-server-deploy` (production Ubuntu playbook) and `rust-map-format` (Rust game .map file format, protobuf, RustEdit).
