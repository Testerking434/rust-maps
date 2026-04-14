# CLAUDE.md

> Persistent project memory for Claude Code. Loaded automatically at the start of every session.

## Project

- **Repo:** `testerking434/rust-maps`
- **Purpose:** Personal Rust (game) custom maps — `.map` files for the Rust game server.
- **Owner language:** German. Reply in German by default.
- **Primary working branch:** `claude/install-ui-ux-repo-A8tE6`
- **Never** push directly to `main` without explicit permission.

## Skill library (installed under `.claude/skills/`)

215 skills across Apple/iOS, web, game-dev, design and productivity — all auto-discovered by Claude Code. Key categories:

### Apple / iOS / macOS (≈110)
Full coverage of iOS 26+ frameworks, from `swift-ios-skills` (dpearson2699), `apple-skills` (vabole) and `SwiftUI-Agent-Skill` (twostraws):
- **SwiftUI core:** `swiftui`, `swiftui-pro`, `swiftui-patterns`, `swiftui-navigation`, `swiftui-layout-components`, `swiftui-animation`, `swiftui-gestures`, `swiftui-liquid-glass`, `swiftui-performance`, `swiftui-webkit`, `swiftui-uikit-interop`
- **Data:** `swiftdata`, `swift-codable`, `cloudkit`, `core-nfc`, `core-bluetooth`, `core-motion`, `sensorkit`
- **AI on device:** `apple-on-device-ai`, `coreml`, `vision-framework`, `natural-language`, `speech-recognition`
- **Media:** `avkit`, `musickit`, `photokit`, `pdfkit`, `swift-charts`, `realitykit`, `scenekit`, `spritekit`, `pencilkit`, `paperkit`, `tabletopkit`
- **Games:** `gamekit`, `spritekit`, `scenekit`, `realitykit`, `metrickit`
- **System/OS:** `widgetkit`, `activitykit`, `alarmkit`, `tipkit`, `app-intents`, `app-clips`, `background-processing`, `push-notifications`, `usernotifications`
- **HW / Integrations:** `homekit`, `healthkit`, `weatherkit`, `carplay`, `callkit`, `storekit`, `passkit`, `financekit`, `mapkit`, `eventkit`, `contacts-framework`, `shareplay-activities`, `accessorysetupkit`, `adattributionkit`, `appmigrationkit`, `audioaccessorykit`, `energykit`, `dockkit`, `browserenginekit`, `paperkit`, `permissionkit`, `relevancekit`, `cryptokit`, `cryptotokenkit`
- **Language / Tooling:** `swift-language`, `swift-concurrency`, `swift-testing`, `xcuitest`, `debugging-instruments`, `simulator-utils`, `ios-dev`, `ios-design-consultant`, `ios-ui-craft`, `ios-accessibility`, `ios-localization`, `ios-networking`, `ios-security`, `hig`, `apple-docs-index`, `uikit`, `combine`, `guide-*` (macos-spm-packaging, swift-concurrency, swift-testing, swiftdata, swiftui-animations, swiftui-charts, swiftui-performance-audit, swiftui-ui-patterns, swiftui-view-refactor)
- **App Store:** `app-store-review`, `apple-aso`, `device-integrity`, `authentication`

### Web / UI / UX (≈40)
- **UI/UX Pro Max** (already installed): `ui-ux-pro-max`, `ui-styling`, `design`, `design-system`, `brand`, `banner-design`, `slides`
- **Vercel official:** `react-best-practices`, `web-design-guidelines`, `composition-patterns`, `react-view-transitions`, `react-native-skills`, `deploy-to-vercel`, `vercel-cli-with-tokens`
- **Next.js stack:** `next-best-practices`, `nextjs-chatbot`, `nextjs-seo`, `nextjs-shadcn`, `cache-components`, `shadcn`
- **AI apps:** `ai-app`, `ai-elements`, `ai-sdk`, `ai-sdk-6`, `openai-agents-sdk`, `claude-api`
- **Backend:** `postgres-semantic-search`, `supabase-postgres-best-practices`
- **Anthropic official:** `frontend-design`, `webapp-testing` (Playwright), `canvas-design`, `theme-factory`, `web-artifacts-builder`, `algorithmic-art`, `skill-creator`, `mcp-builder`, `claude-api`
- **Office:** `pdf`, `docx`, `xlsx`, `pptx`, `doc-coauthoring`

### Game development (≈70)
From `Donchitos/Claude-Code-Game-Studios` — a full studio pipeline:
- **Orchestration teams:** `team-ui`, `team-combat`, `team-level`, `team-narrative`, `team-audio`, `team-polish`, `team-qa`, `team-release`, `team-live-ops`
- **Concept → Architecture:** `brainstorm`, `art-bible`, `create-architecture`, `architecture-decision`, `architecture-review`, `map-systems`, `create-epics`, `create-stories`, `create-control-manifest`, `setup-engine`, `review-all-gdds`, `consistency-check`
- **Workflow:** `dev-story`, `story-readiness`, `story-done`, `sprint-plan`, `sprint-status`, `milestone-review`, `retrospective`, `estimate`, `scope-check`, `gate-check`, `project-stage-detect`, `help`, `start`, `adopt`, `onboard`
- **Quality / perf / ops:** `perf-profile`, `code-review`, `design-review`, `ux-design`, `ux-review`, `qa-plan`, `smoke-check`, `soak-test`, `regression-suite`, `test-setup`, `test-helpers`, `test-evidence-review`, `test-flakiness`, `security-audit`, `tech-debt`, `balance-check`
- **Release:** `launch-checklist`, `release-checklist`, `day-one-patch`, `hotfix`, `patch-notes`, `changelog`, `localize`
- **Assets / content:** `asset-spec`, `asset-audit`, `content-audit`, `prototype`, `quick-design`, `playtest-report`, `bug-report`, `bug-triage`, `reverse-document`, `propagate-design-change`, `skill-improve`, `skill-test`

## Performance & memory strategy

1. **This CLAUDE.md** — project-level persistent memory. Append important decisions here as they come up.
2. **Skills as second brain** — every skill above has its own SKILL.md with references, so I don't have to "remember" details; I load the right skill on demand.
3. **Optional MCP memory server** for cross-session knowledge graph — can be added later via `.claude/settings.json`:
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
   (Not installed yet — install only when actually needed to avoid slowing startup.)

## Workflow rules

- Always develop on `claude/install-ui-ux-repo-A8tE6` unless the user says otherwise.
- **Never** `git push --force` or `git reset --hard` without explicit confirmation.
- Prefer editing existing files over creating new ones.
- Speak German in the chat unless the user switches language.
- When a skill matches the task, **use** it instead of re-deriving from scratch.

## Important facts about the user

- Requests are often short and in informal German — interpret generously.
- User wants **maximum capability + performance + memory** ("damit du nix mehr vergisst").
- User prefers that I decide and act rather than ask many clarification questions.

## Changelog

- **2026-04-14:** Initial install of `UI/UX Pro Max`, then 200+ additional skills (Apple, web, game-dev, Anthropic official, Vercel). Created this CLAUDE.md as persistent memory.
