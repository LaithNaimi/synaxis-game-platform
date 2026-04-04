# Synaxis Frontend — Master Build Plan

> **Version:** 1.1  
> **Purpose:** Single execution guide for building the Flutter frontend by task, aligned with three sources of truth below.  
> **Conflict resolution:** If anything disagrees, follow **`synaxis_frontend_dds.md`** (latest), then this plan, then the task breakdown; use **`synaxis_use_case_report.md`** for end-to-end system context and backend flow only.

---

## How the three documents map here

| Document | Role in this plan |
|----------|-------------------|
| **`synaxis_frontend_dds.md`** | Architecture, routes, theme tokens, REST/WS contracts, navigation rules (e.g. §7.3 buffered leaderboard, `GameController` owns `LEARNING_REVEAL` → `/learning`), leave API, acceptance §27–28. |
| **`synaxis_frontend_implementation_task_breakdown.md`** | Epic/task IDs (FE-00x.y), branches, CI/testing expectations, milestones. |
| **`synaxis_use_case_report.md`** | UC references: who triggers what, event ordering, shared vs private channels (§7.2), reading order §9. |

**Repository root for code:** `frontend/` (adjust paths if your app lives elsewhere).

---

## Git model — branch naming (readable)

Use **kebab-case**, prefix `feature/`, and a **short verb + what it does** (no spaces; Git branch names cannot contain spaces). Examples: `feature/add-home-screen`, `feature/scaffold-lib-folder-structure`.

| Approach | When to use |
|----------|-------------|
| **One branch per task** | Smallest PRs; branch name = **Task branch** in each section below (recommended for clarity). |
| **One branch per epic** | Fewer branches; use the **Epic umbrella branch** and stack multiple commits until the epic merges. |

Each **task** still maps to one or more **commits**; open **one PR per task** or **one PR per epic** depending on approach — never leave `main` broken.

- **Commit style:** [Conventional Commits](https://www.conventionalcommits.org/) — `feat:`, `fix:`, `test:`, `chore:`.
- Task IDs (`FE-001.1`, …) stay for traceability in commits/PRs: e.g. `feat(fe-002.1): add home screen navigation`.

---

# Epic FE-001 — App Shell, Theme, Router, Core Infra

**Epic umbrella branch (optional):** `feature/foundation-app-infrastructure`  
**Milestone:** 0.1.0 (with FE-002)  
**Use cases (context):** UC-03–08 infrastructure pieces; layering §3.1 in use case report.

---

## FE-001.1 — Create final folder structure

| Field | Content |
|-------|---------|
| **Goals** | Establish the feature-based `lib/` tree so every file has one home; matches DDS §5. |
| **How** | Create directories under `lib/app`, `lib/core`, `lib/features/*`, `lib/shared`; move existing entry code; fix imports. |
| **Files add/edit** | `lib/**` (new folders), `lib/main.dart` (import paths only if needed). |
| **Result** | `flutter analyze` clean; app runs; no orphan files. |
| **Branch** | `feature/scaffold-lib-folder-structure` |
| **Suggested commit** | `feat: scaffold feature-based lib folder structure` |

**Step-by-step (reason)**

1. Copy DDS §5 tree into the repo under `frontend/lib/` — **reason:** single structural contract.  
2. Move `main.dart` and any prototype screens into `features/.../presentation/screens` — **reason:** avoids duplicate roots.  
3. Run `dart fix --apply` / fix imports — **reason:** compile safety.  
4. Run `flutter analyze` — **reason:** gate before next task.

---

## FE-001.2 — Setup theme system

| Field | Content |
|-------|---------|
| **Goals** | Centralize colors, spacing, typography per DDS §8; no magic numbers in widgets later. |
| **How** | Add `app_colors.dart`, `app_spacing.dart`, `app_text_styles.dart`, `app_theme.dart`; wire `ThemeData` in `main.dart`. |
| **Files add/edit** | `lib/app/theme/*.dart`, `lib/main.dart` |
| **Result** | App builds with shared theme; tokens ready for FE-002+. |
| **Branch** | `feature/add-app-theme-system` |
| **Suggested commit** | `feat: add app theme tokens and ThemeData wiring` |

**Step-by-step (reason)**

1. Implement token tables from DDS §8.2–8.5 — **reason:** match spec and a11y/contrast notes.  
2. Export a single `AppTheme.light()` (or dark later) — **reason:** one entry for `MaterialApp`.  
3. Replace any hardcoded colors in existing UI with tokens — **reason:** enforces §8.10 rules early.  
4. Widget smoke: open app — **reason:** visual regression catch.

---

## FE-001.3 — Setup router (`go_router`)

| Field | Content |
|-------|---------|
| **Goals** | All DDS routes exist; navigation API ready for session guards later. |
| **How** | `go_router` + `route_names.dart` + `app_router.dart`; register placeholder screens. |
| **Files add/edit** | `lib/app/router/route_names.dart`, `lib/app/router/app_router.dart`, `lib/main.dart`, minimal `*_screen.dart` placeholders per route |
| **Result** | Manual navigation to every path without crash (DDS §7.1). |
| **Branch** | `feature/add-go-router-and-routes` |
| **Suggested commit** | `feat: add go_router with all MVP routes` |

**Step-by-step (reason)**

1. Define route constants matching DDS §7.1 — **reason:** avoids string drift.  
2. Register stub `Scaffold` screens — **reason:** proves router wiring before business logic.  
3. Replace `MaterialApp(home:)` with `MaterialApp.router` — **reason:** required for `go_router`.  
4. Manual tap-through from a dev menu or temporary buttons — **reason:** acceptance “no crash”.

---

## FE-001.4 — Setup core networking layer

| Field | Content |
|-------|---------|
| **Goals** | One `ApiClient`, one `WebSocketClient` wrapper, STOMP destinations centralized (DDS §9–10, §7.2 UC channels). |
| **How** | `AppConfig`, Dio timeouts, STOMP client facade, `WsDestinations` class. |
| **Files add/edit** | `lib/core/config/app_config.dart`, `lib/core/network/api_client.dart`, `lib/core/network/websocket_client.dart`, `lib/core/network/ws_destinations.dart`, `lib/core/utils/logger.dart` (optional) |
| **Result** | Debug build can open WS to backend URL; REST ready for POST room. |
| **Branch** | `feature/add-api-and-websocket-clients` |
| **Suggested commit** | `feat: add ApiClient, WebSocketClient, and STOMP destination constants` |

**Step-by-step (reason)**

1. Implement `AppConfig` with dev URLs (DDS §9.1) — **reason:** single place for LAN/web later.  
2. Wrap Dio with 10s timeouts (DDS §9.2) — **reason:** predictable failure.  
3. Implement WS connect/subscribe/send/disconnect API (DDS §9.3) — **reason:** controllers stay thin.  
4. Add `WsDestinations` only — **reason:** STOMP path mismatch is top risk (task breakdown §14).  
5. Manual: connect WS in debug — **reason:** infra proof.

---

## FE-001.5 — CI and lint baseline

| Field | Content |
|-------|---------|
| **Goals** | PRs cannot merge without analyze/format/test (task breakdown §5). |
| **How** | CI workflow or documented scripts; `analysis_options.yaml` if missing. |
| **Files add/edit** | `.github/workflows/*.yml` or `melos`/`scripts`, `analysis_options.yaml`, `README` snippet |
| **Result** | `flutter analyze` + `dart format --set-exit-if-changed` + `flutter test` in CI. |
| **Branch** | `feature/add-ci-and-lint-baseline` |
| **Suggested commit** | `chore: add CI pipeline for analyze, format, and tests` |

**Step-by-step (reason)**

1. Add strict `analysis_options.yaml` — **reason:** catch issues early.  
2. Add workflow running on PR — **reason:** team gate.  
3. Document local commands in README — **reason:** junior onboarding.

**→ Merge FE-001 to `develop`/`main` when all FE-001.* complete.**

---

# Epic FE-002 — Home, Create, Join, Session Bootstrapping

**Epic umbrella branch (optional):** `feature/room-entry-and-session`  
**Milestone:** 0.1.0  
**Use cases:** UC-03 Create Room, UC-04 Join, UC-05–06 lobby bootstrap; DDS §10.1, §15.1–15.3.

---

## FE-002.1 — Build `HomeScreen`

| **Goals** | Entry UI with two CTAs (DDS §15.1). |
| **How** | Screen + `AppButton` to `/create-room` and `/join-room`. |
| **Files** | `lib/features/home/presentation/screens/home_screen.dart`, router updates |
| **Result** | Tappable navigation to forms. |
| **Branch** | `feature/add-home-screen` |
| **Commit** | `feat: add HomeScreen with create and join navigation` |

**Steps (reason):** (1) Build UI with theme tokens — match DDS. (2) Use `context.go` — router convention. (3) Widget test: buttons fire navigation — regression safety.

---

## FE-002.2 — Build `CreateRoomScreen` UI

| **Goals** | Form: name + settings dropdowns (DDS §15.2, §10.4 validation). |
| **How** | `TextFormField` + dropdowns; local validation; no API yet. |
| **Files** | `lib/features/room/presentation/screens/create_room_screen.dart`, shared widgets if needed |
| **Result** | Submit disabled until valid. |
| **Branch** | `feature/add-create-room-screen` |
| **Commit** | `feat: add CreateRoomScreen form and validation` |

**Steps (reason):** (1) Match field list to DDS — avoid missing settings. (2) Validation ranges per DDS §10.4 — align backend. (3) Widget tests for invalid/valid — acceptance.

---

## FE-002.3 — Build `JoinRoomScreen` UI

| **Goals** | Name + room code (DDS §15.3). |
| **How** | Same pattern as create. |
| **Files** | `lib/features/room/presentation/screens/join_room_screen.dart` |
| **Result** | Valid form enables submit. |
| **Branch** | `feature/add-join-room-screen` |
| **Commit** | `feat: add JoinRoomScreen form and validation` |

---

## FE-002.4 — Create room API integration

| **Goals** | POST `/api/room` mapped to models (DDS §10.1, §10.3). |
| **How** | DTOs, `RoomRepository.createRoom`, `ErrorMapper`. |
| **Files** | `lib/features/room/data/models/*`, `lib/features/room/data/api/room_api.dart`, `lib/core/errors/*` |
| **Result** | Successful parse + SnackBar on error; no navigation here yet. |
| **Branch** | `feature/integrate-create-room-api` |
| **Commit** | `feat: integrate create room REST API and error mapping` |

**Steps (reason):** (1) Request/response models match DDS shapes — fewer runtime surprises. (2) Repository only returns typed models — UI stays dumb. (3) Unit/mocked test — contract safety.

---

## FE-002.5 — Join room API integration

| **Goals** | POST join endpoint (DDS §10.1). |
| **How** | Same as FE-002.4 for join path + room-full / started errors (use case UC-05 failures). |
| **Files** | extend `room_api.dart`, models, repository |
| **Result** | Join success returns `RoomSessionModel`. |
| **Branch** | `feature/integrate-join-room-api` |
| **Commit** | `feat: integrate join room REST API` |

---

## FE-002.6 — Implement room session state

| **Goals** | Single in-memory session (DDS §11, §20, §12.1). |
| **How** | Riverpod `RoomSessionController` + models. |
| **Files** | `lib/features/room/application/controllers/room_session_controller.dart`, `lib/features/room/application/providers/*`, `lib/features/room/data/models/*` |
| **Result** | Create/join can `setSession`; `clearSession` exists. |
| **Branch** | `feature/add-room-session-state` |
| **Commit** | `feat: add RoomSessionController and session models` |

**Steps (reason):** (1) Models mirror DDS §11.1–11.4 — one source. (2) Controller owns lifecycle — avoids duplicate session. (3) Unit tests — session clear/create.

---

## FE-002.7 — Route to lobby after create/join

| **Goals** | End-to-end: success → save session → WS connect → `/lobby` (DDS §7.2, UC-06). |
| **How** | Wire forms to repository; on success call `connectRealtime()` then `go('/lobby')`. |
| **Files** | `create_room_screen.dart`, `join_room_screen.dart`, `room_session_controller.dart`, `app_router.dart` (redirect/guard optional later) |
| **Result** | User lands in lobby with active session + socket (verify logs). |
| **Branch** | `feature/connect-websocket-and-route-to-lobby` |
| **Commit** | `feat: complete create and join flow with websocket connect and lobby route` |

**Steps (reason):** (1) WS after REST success — UC-06 order. (2) No navigation on error — DDS §19. (3) Integration/manual two-step — acceptance.

---

# Epic FE-003 — Lobby Realtime

**Epic umbrella branch (optional):** `feature/lobby-realtime-updates`  
**Milestone:** 0.2.0  
**Use cases:** UC-06–09; DDS §12.2, §13, §15.4.

---

## FE-003.1 — Build `LobbyScreen` static layout

| **Goals** | Show code, player, host, settings, list, leave/start placeholders (DDS §15.4). |
| **How** | Read session + lobby state provider (next task can init). |
| **Files** | `lib/features/room/presentation/screens/lobby_screen.dart`, widgets `player_tile.dart`, etc. |
| **Result** | Renders from snapshot. |
| **Branch** | `feature/add-lobby-screen-layout` |
| **Commit** | `feat: add LobbyScreen layout and placeholders` |

---

## FE-003.2 — Create live lobby state

| **Goals** | `LobbyState` + `LobbyController` (DDS §11.5, §12.2). |
| **How** | Initialize from `RoomSessionModel`; no WS yet. |
| **Files** | `lib/features/room/application/state/lobby_state.dart`, `lobby_controller.dart`, `lobby_provider.dart` |
| **Result** | UI binds to provider, not raw JSON. |
| **Branch** | `feature/add-lobby-live-state` |
| **Commit** | `feat: add LobbyController and lobby state` |

---

## FE-003.3 — Subscribe to room topic in lobby

| **Goals** | Room topic events → controller (DDS §14, §13; UC-07–08). |
| **How** | Parse envelope `{type, payload}` (DDS §10.5); handle `PLAYER_JOINED`, `PLAYER_REMOVED_*`, `HOST_TRANSFERRED`, `GAME_STARTED`. |
| **Files** | `lobby_controller.dart`, WS subscription in `RoomSessionController` or lobby, mappers |
| **Result** | List updates live (two-device test). |
| **Branch** | `feature/subscribe-lobby-room-events` |
| **Commit** | `feat: subscribe to room topic and handle lobby events` |

---

## FE-003.4 — Start game command from host

| **Goals** | Host-only STOMP `/app/game.start`; no optimistic nav (DDS §15.4, UC-09). |
| **How** | `RealtimeRoomRepository.startGame`; validate host in UI + backend. |
| **Files** | `lib/features/room/data/repositories/realtime_room_repository.dart` (or equivalent), `lobby_screen.dart` |
| **Result** | Command sent with correct body (DDS §10.2). |
| **Branch** | `feature/add-start-game-command` |
| **Commit** | `feat: add host start game STOMP command` |

---

## FE-003.5 — Navigate lobby → countdown on `GAME_STARTED`

| **Goals** | On `GAME_STARTED` → `go('/countdown')` (DDS §7.2). |
| **How** | `LobbyController` / router callback; single navigation owner per DDS. |
| **Files** | `lobby_controller.dart`, `app_router.dart` |
| **Result** | All clients move to countdown. |
| **Branch** | `feature/navigate-lobby-to-countdown` |
| **Commit** | `feat: navigate to countdown on GAME_STARTED` |

---

# Epic FE-004 — Countdown

**Epic umbrella branch (optional):** `feature/countdown-and-game-transition`  
**Milestone:** 0.2.0  
**Use cases:** UC-10–11; DDS §15.5.

---

## FE-004.1 — Build `CountdownScreen`

| **Goals** | Large countdown + round label (DDS §15.5). |
| **How** | UI only; state in FE-004.2. |
| **Files** | `lib/features/countdown/presentation/screens/countdown_screen.dart`, `countdown_circle.dart` |
| **Result** | Renders remaining seconds from state. |
| **Branch** | `feature/add-countdown-screen` |
| **Commit** | `feat: add CountdownScreen UI` |

---

## FE-004.2 — Build countdown state/controller

| **Goals** | `ROUND_COUNTDOWN_STARTED` updates `CountdownState` (DDS §12.3). |
| **How** | Subscribe on room topic; parse ticks/value. |
| **Files** | `lib/features/countdown/application/*`, `countdown_provider.dart` |
| **Result** | Display updates from events. |
| **Branch** | `feature/add-countdown-controller` |
| **Commit** | `feat: add CountdownController and ROUND_COUNTDOWN_STARTED handling` |

---

## FE-004.3 — Navigate countdown → game on `ROUND_STARTED`

| **Goals** | `ROUND_STARTED` → `/game` (DDS §7.2, UC-11). |
| **How** | CountdownController or coordinator calls `go('/game')`; align §28.2 if events race. |
| **Files** | `countdown_controller.dart`, `app_router.dart` |
| **Result** | All players enter game. |
| **Branch** | `feature/navigate-countdown-to-game` |
| **Commit** | `feat: navigate to game screen on ROUND_STARTED` |

---

# Epic FE-005 — Gameplay

**Epic umbrella branch (optional):** `feature/gameplay-screen-and-guessing`  
**Milestone:** 0.3.0  
**Use cases:** UC-12–20; DDS §15.6, §16, §7.3.

---

## FE-005.1 — Build `GameScreen` static layout

| **Goals** | Layout order DDS §16.1 (header, metrics, masked word, players, grid). |
| **How** | Mock data first. |
| **Files** | `lib/features/game/presentation/screens/game_screen.dart`, widget stubs |
| **Result** | Static render with mocks. |
| **Branch** | `feature/add-game-screen-layout` |
| **Commit** | `feat: add GameScreen layout and widget stubs` |

---

## FE-005.2 — Build `GameState` and `GameController`

| **Goals** | Central game state incl. `learningRevealActive` (DDS §11.7). |
| **How** | Providers + reducers from events. |
| **Files** | `lib/features/game/application/state/game_state.dart`, `game_controller.dart`, `game_provider.dart` |
| **Result** | UI reads only from controller. |
| **Branch** | `feature/add-game-state-and-controller` |
| **Commit** | `feat: add GameState and GameController skeleton` |

---

## FE-005.3 — Build keyboard widget with state colors

| **Goals** | 26 letters; states per DDS §15.6; tokens §8. |
| **How** | `LetterGridWidget` + semantics (DDS §8.7). |
| **Files** | `lib/features/game/presentation/widgets/letter_grid_widget.dart` |
| **Result** | Correct/wrong/disabled visuals. |
| **Branch** | `feature/add-letter-grid-widget` |
| **Commit** | `feat: implement letter grid with guess state styling` |

---

## FE-005.4 — Send `GuessLetterCommand`

| **Goals** | Tap → STOMP `/app/game.guess-letter` (DDS §10.2). |
| **How** | Guard: not stunned, round active, not `learningRevealActive`. |
| **Files** | `game_controller.dart`, realtime repository |
| **Result** | JSON matches contract. |
| **Branch** | `feature/send-guess-letter-command` |
| **Commit** | `feat: send guess letter command from GameController` |

---

## FE-005.5 — Handle private game events

| **Goals** | Private queue: `LETTER_GUESS_RESULT`, `PLAYER_ROUND_STATE`, stun, `RESYNC_SNAPSHOT` (DDS §13, UC-12+). |
| **How** | Map to `GameState`; full replace for round state. |
| **Files** | `game_controller.dart`, event mappers under `features/game/data/` |
| **Result** | Masked word, score, health, stun sync. |
| **Branch** | `feature/handle-private-game-events` |
| **Commit** | `feat: handle private game queue events` |

---

## FE-005.6 — Handle shared game events

| **Goals** | Room topic: solved, sudden death, timeout, ended (DDS §13; UC-16–20). |
| **How** | Update shared UI flags; prepare for `LEARNING_REVEAL` handoff. |
| **Files** | `game_controller.dart` |
| **Result** | Warnings + list highlights; input stops when required. |
| **Branch** | `feature/handle-shared-game-events` |
| **Commit** | `feat: handle shared round events for game UI` |

---

# Epic FE-006 — Learning + Round Leaderboard

**Epic umbrella branch (optional):** `feature/learning-and-round-leaderboard`  
**Milestone:** 0.4.0  
**Use cases:** UC-21–23; **DDS §7.3 buffered leaderboard** overrides “navigate immediately on event” in use case report.

---

## FE-006.1 — Build `LearningRevealScreen`

| **Goals** | Word, Arabic (RTL), English (LTR), CTA (DDS §15.7, §8.4). |
| **How** | Layout only; data from controller. |
| **Files** | `lib/features/learning/presentation/screens/learning_reveal_screen.dart`, `learning_card.dart` |
| **Result** | Renders `LearningState`. |
| **Branch** | `feature/add-learning-reveal-screen` |
| **Commit** | `feat: add LearningRevealScreen UI` |

---

## FE-006.2 — Build learning state + `LEARNING_REVEAL` handling

| **Goals** | **DDS §12.4–12.5:** `GameController` parses `LEARNING_REVEAL`, calls `LearningController.setFromPayload`, sets `learningRevealActive`, **sole** `go('/learning')`. |
| **How** | Do **not** subscribe LearningController to WS for this event in MVP. |
| **Files** | `lib/features/learning/application/*`, `game_controller.dart` |
| **Result** | One navigation to learning; payload on screen. |
| **Branch** | `feature/wire-learning-reveal-from-game-controller` |
| **Commit** | `feat: wire LEARNING_REVEAL through GameController to Learning screen` |

---

## FE-006.3 — Build `RoundLeaderboardScreen`

| **Goals** | Table/list of entries; host Next Round (DDS §15.8). |
| **How** | Reads `LeaderboardState`. |
| **Files** | `lib/features/leaderboard/presentation/screens/round_leaderboard_screen.dart`, `leaderboard_list.dart` |
| **Result** | Ranks visible. |
| **Branch** | `feature/add-round-leaderboard-screen` |
| **Commit** | `feat: add RoundLeaderboardScreen` |

---

## FE-006.4 — Build leaderboard state/controller (buffered)

| **Goals** | **DDS §7.3, §12.6:** On `ROUND_LEADERBOARD` / `FINAL_LEADERBOARD`, **buffer** only; navigate after **Go to Leaderboard** via `navigateAfterLearningTap` / equivalent. |
| **How** | `LeaderboardController.handleRoundLeaderboard`, `handleFinalLeaderboard`; no `go` to leaderboard routes on event alone while MVP requires Learning tap. |
| **Files** | `lib/features/leaderboard/application/*`, `learning_reveal_screen.dart` (button handler) |
| **Result** | Payload ready before/after tap; single `go` to correct route. |
| **Branch** | `feature/add-buffered-leaderboard-controller` |
| **Commit** | `feat: add LeaderboardController with buffered events and post-learning navigation` |

---

## FE-006.5 — Next round command flow

| **Goals** | Host `/app/round.next` → `ROUND_COUNTDOWN_STARTED` → `/countdown` (DDS §15.8). |
| **How** | Same pattern as start game: no optimistic countdown. |
| **Files** | `round_leaderboard_screen.dart`, `leaderboard_controller.dart`, realtime repo |
| **Result** | Next round loop works. |
| **Branch** | `feature/add-next-round-flow` |
| **Commit** | `feat: add next round command and return to countdown` |

---

# Epic FE-007 — Final Leaderboard + Exit

**Epic umbrella branch (optional):** `feature/final-leaderboard-and-exit`  
**Milestone:** 0.4.0  
**Use cases:** UC-24–25, UC-30; DDS §15.9, §10.1 leave.

---

## FE-007.1 — Build `FinalLeaderboardScreen`

| **Goals** | Stronger visual than round (DDS §15.9). |
| **How** | Reuse list component with variant styles. |
| **Files** | `lib/features/leaderboard/presentation/screens/final_leaderboard_screen.dart` |
| **Result** | Final entries + Leave button. |
| **Branch** | `feature/add-final-leaderboard-screen` |
| **Commit** | `feat: add FinalLeaderboardScreen UI` |

---

## FE-007.2 — Handle `FINAL_LEADERBOARD` (buffered + route)

| **Goals** | Buffer final payload; after learning flow user reaches `/final-leaderboard` when match ends (DDS §7.3). |
| **How** | Same controller as FE-006.4; route choice from `LeaderboardState`, not guesswork. |
| **Files** | `leaderboard_controller.dart`, router |
| **Result** | Match end shows final screen. |
| **Branch** | `feature/handle-final-leaderboard-routing` |
| **Commit** | `feat: handle FINAL_LEADERBOARD state and navigation from learning flow` |

---

## FE-007.3 — Leave room + clear session

| **Goals** | **DDS §15.9:** REST `leaveRoom` **mandatory** before clear; then disconnect WS; `go('/')`. |
| **How** | `RoomRepository.leaveRoom`; retry SnackBar on transient failure. |
| **Files** | `room_repository.dart`, `room_session_controller.dart`, `final_leaderboard_screen.dart` |
| **Result** | No stale session; socket closed. |
| **Branch** | `feature/add-leave-room-and-clear-session` |
| **Commit** | `feat: implement leave room API, session clear, and websocket disconnect` |

---

# Epic FE-008 — Reconnect / Resync

**Epic umbrella branch (optional):** `feature/reconnect-and-resync`  
**Milestone:** 0.5.0  
**Use cases:** UC-26–29; DDS §21, §11.11.

---

## FE-008.1 — Reconnect models + controller

| **Goals** | `ResyncSnapshotModel`, `ReconnectController` (DDS §11.11, §12.7). |
| **How** | Map enums per DDS §21.5. |
| **Files** | `lib/features/reconnect/**/*` |
| **Result** | Controller can apply snapshot + choose route. |
| **Branch** | `feature/add-reconnect-controller` |
| **Commit** | `feat: add reconnect models and ReconnectController` |

---

## FE-008.2 — `PLAYER_DISCONNECTED` / `PLAYER_RECONNECTED`

| **Goals** | Presence in lobby/game lists (DDS §13). |
| **How** | Update summaries in `LobbyController` / `GameController`. |
| **Files** | respective controllers |
| **Result** | Offline/online indicators. |
| **Branch** | `feature/handle-player-presence-events` |
| **Commit** | `feat: handle player presence events in lobby and game` |

---

## FE-008.3 — Apply `RESYNC_SNAPSHOT`

| **Goals** | Private queue snapshot → restore state + navigate (DDS §21.4; UC-29). |
| **How** | `ResyncSnapshotMapper.toRoute()` central map; avoid scattered string compares. |
| **Files** | `reconnect_controller.dart`, `game_controller.dart`, mappers |
| **Result** | Reconnect smoke passes. |
| **Branch** | `feature/apply-resync-snapshot` |
| **Commit** | `feat: apply RESYNC_SNAPSHOT and redirect to correct screen` |

---

# Epic FE-009 — Polish + QA

**Epic umbrella branch (optional):** `feature/ui-polish-and-stabilization`  
**Milestone:** 0.5.0

---

## FE-009.1 — Loading and error UX

| **Goals** | DDS §15.0 cross-cutting states; no silent failures. |
| **How** | `AppLoadingOverlay`, `AppErrorBanner`, SnackBars per DDS §19. |
| **Files** | `lib/shared/widgets/*`, screen updates |
| **Result** | Consistent loading/error. |
| **Branch** | `feature/polish-loading-and-error-ux` |
| **Commit** | `feat: unify loading and error UX across flows` |

---

## FE-009.2 — Visual polish

| **Goals** | Token use for stun, sudden death, winner (DDS §8, §27.5). |
| **How** | Pass through game/leaderboard widgets. |
| **Files** | theme + feature widgets |
| **Result** | States obvious without logs. |
| **Branch** | `feature/polish-visual-game-states` |
| **Commit** | `refactor: apply visual tokens for game and leaderboard states` |

---

## FE-009.3 — Multiplayer manual QA matrix

| **Goals** | Task breakdown §12 matrix + DDS §22 all green on 2 devices. |
| **How** | Run checklist; file issues. |
| **Files** | Optional `docs/qa/FE-MVP-results.md` or issue tracker |
| **Result** | Signed-off MVP per §13 task breakdown. |
| **Branch** | `feature/run-manual-qa-matrix` |
| **Commit** | `docs: record frontend MVP manual QA results` |

---

## Appendix A — Reading order for developers

1. DDS §1–7 (scope + routing rules)  
2. Use case report §9 (UC reading order)  
3. This master plan by epic order  
4. Task breakdown §5–6 (CI/testing) when opening PRs  

---

## Appendix B — Quick reference: DDS sections by concern

| Concern | DDS section |
|---------|-------------|
| Folder structure | §5 |
| Routes | §7 |
| Theme / responsive / a11y | §8 |
| REST / WS / payloads | §9–10 |
| Models | §11 |
| Controllers | §12–17 |
| Events matrix | §13 |
| Screens | §15–16 |
| Reconnect | §21 |
| Acceptance / edge cases | §27–28 |

---

## Appendix C — Suggested Git branch names (readable)

Use **kebab-case** after `feature/`. One branch per task, or merge several tasks on the **Epic umbrella** branch listed under each epic header.

| Task | Branch name |
|------|-------------|
| FE-001.1 | `feature/scaffold-lib-folder-structure` |
| FE-001.2 | `feature/add-app-theme-system` |
| FE-001.3 | `feature/add-go-router-and-routes` |
| FE-001.4 | `feature/add-api-and-websocket-clients` |
| FE-001.5 | `feature/add-ci-and-lint-baseline` |
| FE-002.1 | `feature/add-home-screen` |
| FE-002.2 | `feature/add-create-room-screen` |
| FE-002.3 | `feature/add-join-room-screen` |
| FE-002.4 | `feature/integrate-create-room-api` |
| FE-002.5 | `feature/integrate-join-room-api` |
| FE-002.6 | `feature/add-room-session-state` |
| FE-002.7 | `feature/connect-websocket-and-route-to-lobby` |
| FE-003.1 | `feature/add-lobby-screen-layout` |
| FE-003.2 | `feature/add-lobby-live-state` |
| FE-003.3 | `feature/subscribe-lobby-room-events` |
| FE-003.4 | `feature/add-start-game-command` |
| FE-003.5 | `feature/navigate-lobby-to-countdown` |
| FE-004.1 | `feature/add-countdown-screen` |
| FE-004.2 | `feature/add-countdown-controller` |
| FE-004.3 | `feature/navigate-countdown-to-game` |
| FE-005.1 | `feature/add-game-screen-layout` |
| FE-005.2 | `feature/add-game-state-and-controller` |
| FE-005.3 | `feature/add-letter-grid-widget` |
| FE-005.4 | `feature/send-guess-letter-command` |
| FE-005.5 | `feature/handle-private-game-events` |
| FE-005.6 | `feature/handle-shared-game-events` |
| FE-006.1 | `feature/add-learning-reveal-screen` |
| FE-006.2 | `feature/wire-learning-reveal-from-game-controller` |
| FE-006.3 | `feature/add-round-leaderboard-screen` |
| FE-006.4 | `feature/add-buffered-leaderboard-controller` |
| FE-006.5 | `feature/add-next-round-flow` |
| FE-007.1 | `feature/add-final-leaderboard-screen` |
| FE-007.2 | `feature/handle-final-leaderboard-routing` |
| FE-007.3 | `feature/add-leave-room-and-clear-session` |
| FE-008.1 | `feature/add-reconnect-controller` |
| FE-008.2 | `feature/handle-player-presence-events` |
| FE-008.3 | `feature/apply-resync-snapshot` |
| FE-009.1 | `feature/polish-loading-and-error-ux` |
| FE-009.2 | `feature/polish-visual-game-states` |
| FE-009.3 | `feature/run-manual-qa-matrix` |

---

*End of master build plan.*
