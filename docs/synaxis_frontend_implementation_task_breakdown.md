# Synaxis Frontend Implementation Task Breakdown

> Version: 1.1  
> Scope: Flutter Frontend execution plan derived from the provided Frontend DDS  
> Audience: Front-end developer / tech lead / project manager  
> Goal: Translate the approved front-end design into a practical, low-risk delivery plan with clear Git flow, testing, dependencies, deliverables, and acceptance criteria.

---

## 1. Planning Assumptions

### 1.1 Product assumptions
- Platform target now: **Mobile-first Flutter app**.
- Future extensibility: **Web-ready** architecture.
- Backend is the **source of truth** for:
  - room state
  - match state
  - round state
  - score
  - health
  - stun/recovery
  - sudden death
  - leaderboards
  - reconnect eligibility
- Current UX scope:
  - `Home`
  - `Create Room`
  - `Join Room`
  - `Lobby`
  - `Countdown`
  - `Game`
  - `Learning Reveal`
  - `Round Leaderboard`
  - `Final Leaderboard`
- No local persistence on cold restart for now.
- Manual testing is allowed initially, but code must still be structured to support automated tests later.

### 1.2 Engineering assumptions
- Flutter + Riverpod + go_router + Dio + STOMP client are used.
- Backend contracts are largely stable, but event additions are possible.
- Real-time updates are required in lobby and gameplay screens.
- Session model is single-room only.

---

## 2. Delivery Strategy Overview

Implementation should follow this order:

1. **Project foundations and architecture**
2. **Entry flow** (`Home`, `Create`, `Join`)
3. **Session state + routing**
4. **Lobby realtime updates**
5. **Start game + countdown transition**
6. **Gameplay screen and guess command flow**
7. **Learning reveal + leaderboard screens**
8. **Reconnect/resync flow**
9. **UI polish + stabilization**
10. **Release hardening**

This sequence minimizes blockers because each step unlocks the next visible user flow.

---

## 3. Git Flow Model

### 3.1 Branching strategy
Use a lightweight Git flow:

- `main` → always stable, deployable / demoable
- `develop` → optional if multiple developers exist; for solo development it may be skipped
- `feature/<short-description>` → feature work (readable kebab-case; see §3.2)
- `release/<version>` → release preparation
- `hotfix/<ticket>-<slug>` → urgent fixes after merge/release

### 3.2 Recommended naming (readable branches)

Use **`feature/` + kebab-case** with a **verb + what it does** (no spaces). Prefer names that read well in `git branch -a` and in PR titles.

**Epic umbrella branches** (one branch per epic, or split into smaller task branches — see `synaxis_frontend_master_build_plan.md`):

| Epic | Suggested umbrella branch |
|------|---------------------------|
| FE-001 | `feature/foundation-app-infrastructure` |
| FE-002 | `feature/room-entry-and-session` |
| FE-003 | `feature/lobby-realtime-updates` |
| FE-004 | `feature/countdown-and-game-transition` |
| FE-005 | `feature/gameplay-screen-and-guessing` |
| FE-006 | `feature/learning-and-round-leaderboard` |
| FE-007 | `feature/final-leaderboard-and-exit` |
| FE-008 | `feature/reconnect-and-resync` |
| FE-009 | `feature/ui-polish-and-stabilization` |

**Per-task branches** (smaller PRs): e.g. `feature/add-home-screen`, `feature/scaffold-lib-folder-structure`. Full list: **`synaxis_frontend_master_build_plan.md` Appendix C** (aligned with task IDs FE-00x.y).

**Other branches:**
- `release/0.1.0-frontend-alpha`
- `hotfix/fix-stomp-reconnect` (or `hotfix/<issue>-<slug>`)

### 3.3 Merge rules
A feature branch can be merged only when:
- code is formatted
- `flutter analyze` passes
- all relevant tests for the scope pass
- manual smoke test for the feature passes
- acceptance criteria are met
- PR review checklist is satisfied

### 3.4 Commit convention
Use conventional commits:
- `feat:` new functionality
- `fix:` bug fix
- `refactor:` internal cleanup with no behavior change
- `test:` tests only
- `docs:` documentation only
- `chore:` tooling/config/build changes

Examples:
- `feat: add home router and initial app shell`
- `feat: implement create room form and api flow`
- `feat: add lobby websocket subscriptions`
- `fix: align game started event topic path`

---

## 4. Definition of Done (Global)

A task is considered done only if:
- implementation is complete
- edge cases in acceptance criteria are handled
- code is formatted and analyzed
- relevant tests are added or updated
- manual test steps were executed successfully
- user-visible error handling exists where appropriate
- no dead debug code remains
- documentation comments or README notes are updated if the task changes setup or flow

---

## 5. CI / Code Review / Error Prevention Rules

### 5.1 Mandatory CI steps for every PR
- `flutter pub get`
- `dart format --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`
- optional build smoke:
  - `flutter build apk --debug`
  - `flutter build web --debug` (when web compatibility starts mattering)

### 5.2 Code review checklist
Reviewer must verify:
- correct feature folder placement
- no business rules duplicated from backend
- state belongs to correct controller/provider
- navigation uses router conventions
- websocket subscriptions are cleaned up properly
- no UI widget contains networking logic directly
- no controller directly mutates unrelated feature state
- backend event names and destination paths are centralized
- error messages are user-readable

### 5.3 Error prevention patterns
- Use a **single source of truth** for:
  - REST base URL
  - WebSocket URL
  - STOMP destinations
  - route names
- Keep backend DTO mapping separate from UI state models.
- Never parse JSON inside widgets.
- Never call backend services directly inside reusable widgets.
- Keep WebSocket connection ownership centralized.
- Always update UI through controller/provider state.

---

## 6. Testing Strategy

### 6.1 Test layers

#### Unit tests
Target:
- controllers
- mappers
- event handlers
- reducers / state transition helpers
- validation helpers

#### Widget tests
Target:
- forms
- buttons and visibility rules
- loading/error states
- conditional UI rendering
- game keyboard button states
- leaderboard rendering

#### Integration tests
Target:
- create room flow
- join room flow
- lobby navigation
- start game navigation
- guess command flow
- reconnect flow

#### Manual end-to-end tests
Target:
- two-device room flow
- real websocket event reception
- host transfer visibility
- stunned player input blocking
- sudden death flow
- final leaderboard flow

### 6.2 Testing rule by phase
- Every feature must have at least:
  - controller/unit coverage for critical logic
  - one widget or integration test for the main happy path
  - a manual smoke checklist before merge

---

## 7. Dependency Map

### 7.1 Technical package dependencies
Core packages expected:
- `flutter_riverpod`
- `go_router`
- `dio`
- `stomp_dart_client`
- `equatable`
- `json_annotation` / `json_serializable` (optional depending on mapping strategy)

### 7.2 Architectural dependencies
- `Home` has no upstream dependencies.
- `Create Room` and `Join Room` depend on:
  - router
  - API client
  - room repository/service
  - session controller
- `Lobby` depends on:
  - room session state
  - websocket connection
  - live room event handling
- `Countdown` depends on:
  - lobby → `GAME_STARTED`
  - room topic subscription
- `Game` depends on:
  - private game queue
  - guess command sender
  - game state controller
- `Learning Reveal` depends on:
  - learning payload event
- `Round Leaderboard` depends on:
  - round leaderboard event
- `Final Leaderboard` depends on:
  - final leaderboard event
- `Reconnect` depends on:
  - active session state
  - reconnect endpoint
  - `RESYNC_SNAPSHOT`

---

## 8. Implementation Backlog by Feature

---

# Epic FE-001 — App Shell, Theme, Router, Core Infra

## Objective
Create a clean Flutter foundation that all features can build on.

## Branch
`feature/foundation-app-infrastructure` (umbrella; per-task branches: see master build plan Appendix C)

## Tasks

### FE-001.1 — Create final folder structure
**Dependencies:** none  
**Implementation:**
- create final `lib/` structure by feature and layer
- move current files into approved folders
- remove placeholder/test-only clutter

**Deliverables:**
- stable folder tree
- no orphan files

**Acceptance Criteria:**
- every current file has a clear home
- app still runs after moves
- no broken imports

**Tests:**
- run app
- `flutter analyze`

---

### FE-001.2 — Setup theme system
**Dependencies:** FE-001.1  
**Implementation:**
- add `app_colors.dart`
- add `app_spacing.dart`
- add `app_text_styles.dart`
- add `app_theme.dart`
- wire theme in `main.dart`

**Deliverables:**
- centralized theme definitions

**Acceptance Criteria:**
- app compiles with shared theme
- no hardcoded colors/spacings in new screens unless explicitly temporary

**Tests:**
- widget smoke on HomeScreen

---

### FE-001.3 — Setup router (`go_router`)
**Dependencies:** FE-001.1  
**Implementation:**
- add route names constants
- define routes for:
  - `/`
  - `/create-room`
  - `/join-room`
  - `/lobby`
  - `/countdown`
  - `/game`
  - `/learning`
  - `/round-leaderboard`
  - `/final-leaderboard`
- wire router into `main.dart`

**Deliverables:**
- centralized route map

**Acceptance Criteria:**
- app can navigate to each empty screen without crash

**Tests:**
- router smoke test
- manual navigation test

---

### FE-001.4 — Setup core networking layer
**Dependencies:** FE-001.1  
**Implementation:**
- finalize `AppConfig`
- create `ApiClient`
- create `WebSocketClient`
- create `WsDestinations`
- add centralized logging hooks

**Deliverables:**
- reusable network foundation

**Acceptance Criteria:**
- REST client configured with base URL and timeouts
- WebSocket client can connect successfully in debug
- destination constants exist in one file only

**Tests:**
- manual WS connection test
- manual REST ping/smoke

---

### FE-001.5 — CI and lint baseline
**Dependencies:** FE-001.1  
**Implementation:**
- enforce `flutter analyze`
- enforce formatting
- define PR checklist in repo docs

**Deliverables:**
- stable CI baseline

**Acceptance Criteria:**
- project passes analyze and format checks

**Tests:**
- CI pipeline run

---

# Epic FE-002 — Home, Create Room, Join Room, Session Bootstrapping

## Objective
Allow a user to enter the system, create or join a room, and store the active room session.

## Branch
`feature/room-entry-and-session` (umbrella; per-task branches: see master build plan Appendix C)

## Tasks

### FE-002.1 — Build `HomeScreen`
**Dependencies:** FE-001.3  
**Implementation:**
- add two CTA buttons:
  - Create Room
  - Join Room
- route each button correctly

**Deliverables:**
- `home_screen.dart`

**Acceptance Criteria:**
- tapping each button routes correctly

**Tests:**
- widget test for navigation buttons

---

### FE-002.2 — Build `CreateRoomScreen` UI
**Dependencies:** FE-001.2, FE-001.3  
**Implementation:**
- player name input
- CEFR dropdown
- max players dropdown
- total rounds dropdown
- round duration dropdown
- create CTA
- validation state rendering

**Deliverables:**
- screen + form widgets

**Acceptance Criteria:**
- empty/invalid fields block submit
- valid fields allow submit

**Tests:**
- widget tests for validation

---

### FE-002.3 — Build `JoinRoomScreen` UI
**Dependencies:** FE-001.2, FE-001.3  
**Implementation:**
- player name input
- room code input
- join CTA
- validation states

**Deliverables:**
- join form screen

**Acceptance Criteria:**
- invalid form blocks submit
- valid form allows submit

**Tests:**
- widget tests for validation

---

### FE-002.4 — Create room API integration
**Dependencies:** FE-001.4, FE-002.2  
**Implementation:**
- create room request model
- create room response model
- room repository/api method
- error mapping

**Deliverables:**
- create room backend integration

**Acceptance Criteria:**
- successful create returns parsed response
- validation/backend errors show readable message

**Tests:**
- integration test or mocked repository unit test
- manual create room against backend

---

### FE-002.5 — Join room API integration
**Dependencies:** FE-001.4, FE-002.3  
**Implementation:**
- join room request model
- join room response model
- repository/api method
- error handling

**Deliverables:**
- join room backend integration

**Acceptance Criteria:**
- successful join returns parsed response
- invalid code / room full / started game handled visibly

**Tests:**
- integration test or mocked repository unit test
- manual join room against backend

---

### FE-002.6 — Implement room session state
**Dependencies:** FE-002.4, FE-002.5  
**Implementation:**
- `PlayerSessionModel`
- `PlayerSummaryModel`
- `RoomSettingsModel`
- `RoomSessionModel`
- `RoomSessionController`
- session provider
- session clear method

**Deliverables:**
- active room session stored in Riverpod

**Acceptance Criteria:**
- create/join success stores room session
- leave/final exit can clear session

**Tests:**
- unit tests for controller

---

### FE-002.7 — Route to lobby after create/join
**Dependencies:** FE-002.6  
**Implementation:**
- save session after response
- connect websocket after success
- navigate to `/lobby`

**Deliverables:**
- full create/join entry flow

**Acceptance Criteria:**
- create and join both land user in lobby with active session

**Tests:**
- integration flow test
- manual create/join flow

---

# Epic FE-003 — Lobby Realtime State

## Objective
Display live room state and allow host to start the game.

## Branch
`feature/lobby-realtime-updates` (umbrella; per-task branches: see master build plan Appendix C)

## Tasks

### FE-003.1 — Build `LobbyScreen` static layout
**Dependencies:** FE-002.7  
**Implementation:**
- show room code
- show current player name
- show host state
- show settings
- show players list
- add leave button placeholder
- add start button placeholder for host only

**Deliverables:**
- base lobby screen

**Acceptance Criteria:**
- lobby renders from session snapshot

**Tests:**
- widget test for host/non-host visibility

---

### FE-003.2 — Create live lobby state
**Dependencies:** FE-002.6  
**Implementation:**
- `LobbyState`
- `LobbyController`
- `lobbyProvider`
- initialize state from create/join response

**Deliverables:**
- lobby state management layer

**Acceptance Criteria:**
- UI no longer depends on raw response maps

**Tests:**
- unit tests for initial state mapping

---

### FE-003.3 — Subscribe to room topic in lobby
**Dependencies:** FE-001.4, FE-003.2  
**Implementation:**
- subscribe after websocket connect
- route events to `LobbyController`
- support events:
  - `PLAYER_JOINED`
  - `PLAYER_REMOVED_AFTER_DISCONNECT`
  - `HOST_TRANSFERRED`
  - `GAME_STARTED`

**Deliverables:**
- realtime lobby event handling

**Acceptance Criteria:**
- players list updates without refresh
- host label updates when transferred

**Tests:**
- controller unit tests with sample event payloads
- manual two-device test

---

### FE-003.4 — Start game command from host
**Dependencies:** FE-003.3  
**Implementation:**
- add host-only `Start Game` button
- send STOMP command to start game
- do not navigate optimistically
- wait for `GAME_STARTED`

**Deliverables:**
- correct host command flow

**Acceptance Criteria:**
- non-host cannot trigger start
- host click sends correct command payload

**Tests:**
- manual host vs non-host test

---

### FE-003.5 — Navigate lobby → countdown on `GAME_STARTED`
**Dependencies:** FE-003.4  
**Implementation:**
- update lobby state
- route to `/countdown`

**Deliverables:**
- end-to-end lobby start flow

**Acceptance Criteria:**
- all connected players navigate on event

**Tests:**
- manual multiplayer test

---

# Epic FE-004 — Countdown Flow

## Objective
Handle the visual transition from lobby/post-round into active gameplay.

## Branch
`feature/countdown-and-game-transition` (umbrella; per-task branches: see master build plan Appendix C)

## Tasks

### FE-004.1 — Build `CountdownScreen`
**Dependencies:** FE-003.5  
**Implementation:**
- large numeric countdown
- round number label
- simple transition-safe layout

**Deliverables:**
- countdown screen UI

**Acceptance Criteria:**
- screen renders countdown value cleanly

**Tests:**
- widget snapshot test

---

### FE-004.2 — Build countdown state/controller
**Dependencies:** FE-004.1  
**Implementation:**
- `CountdownState`
- `CountdownController`
- provider
- apply `ROUND_COUNTDOWN_STARTED`

**Deliverables:**
- countdown state management

**Acceptance Criteria:**
- event updates countdown screen state

**Tests:**
- unit tests for countdown state updates

---

### FE-004.3 — Navigate countdown → game on `ROUND_STARTED`
**Dependencies:** FE-004.2  
**Implementation:**
- subscribe to room topic event
- route to `/game`

**Deliverables:**
- round start transition

**Acceptance Criteria:**
- all players transition to game screen on round start

**Tests:**
- manual start flow

---

# Epic FE-005 — Gameplay Screen and Guess Flow

## Objective
Render the active round UI and send/receive guess interactions correctly.

## Branch
`feature/gameplay-screen-and-guessing` (umbrella; per-task branches: see master build plan Appendix C)

## Tasks

### FE-005.1 — Build `GameScreen` static layout
**Dependencies:** FE-004.3  
**Implementation:**
- round number
- timer
- masked word area
- health display
- score display
- players summary list
- letter buttons grid

**Deliverables:**
- first game screen layout

**Acceptance Criteria:**
- screen renders without backend data using mock values

**Tests:**
- widget test for static screen render

---

### FE-005.2 — Build `GameState` and `GameController`
**Dependencies:** FE-005.1  
**Implementation:**
- `GameState` model
- provider
- controller methods to update from events

**Deliverables:**
- centralized game state

**Acceptance Criteria:**
- UI can render from controller state only

**Tests:**
- unit tests for state transitions

---

### FE-005.3 — Build keyboard widget with state colors
**Dependencies:** FE-005.2  
**Implementation:**
- render 26 letter buttons
- states:
  - untouched
  - correct (green)
  - wrong (red)
  - disabled while stunned / post-round

**Deliverables:**
- reusable `letter_grid_widget.dart`

**Acceptance Criteria:**
- button colors match guessed state
- no keyboard input while disabled

**Tests:**
- widget tests for button state rendering

---

### FE-005.4 — Send `GuessLetterCommand`
**Dependencies:** FE-005.3, FE-001.4  
**Implementation:**
- on letter tap send STOMP command using:
  - roomCode
  - playerId
  - playerToken
  - letter

**Deliverables:**
- real guess command sender

**Acceptance Criteria:**
- button click emits correct command JSON

**Tests:**
- controller unit test with mocked ws client
- manual backend verification

---

### FE-005.5 — Handle private game events
**Dependencies:** FE-005.4  
**Implementation:**
- receive and map:
  - `LETTER_GUESS_RESULT`
  - `PLAYER_ROUND_STATE`
  - `PLAYER_STUNNED`
  - `PLAYER_RECOVERED`
  - `RESYNC_SNAPSHOT`

**Deliverables:**
- private gameplay state sync

**Acceptance Criteria:**
- masked word, score, health, stun status update correctly

**Tests:**
- unit tests for event mapping
- manual guess flow test

---

### FE-005.6 — Handle shared game events
**Dependencies:** FE-005.5  
**Implementation:**
- receive and apply:
  - `PLAYER_SOLVED_WORD`
  - `SUDDEN_DEATH_STARTED`
  - `ROUND_TIMEOUT`
  - `SUDDEN_DEATH_ENDED`

**Deliverables:**
- shared round state sync in UI

**Acceptance Criteria:**
- solved players are marked visually
- sudden death warning is shown
- input stops when round no longer accepts guesses

**Tests:**
- unit tests for event mapping
- manual multiplayer test

---

# Epic FE-006 — Learning Reveal and Round Leaderboard

## Objective
Display post-round educational content and current cumulative rankings.

## Branch
`feature/learning-and-round-leaderboard` (umbrella; per-task branches: see master build plan Appendix C)

## Tasks

### FE-006.1 — Build `LearningRevealScreen`
**Dependencies:** FE-005.6  
**Implementation:**
- show word
- Arabic meaning
- English definition
- button to continue to round leaderboard

**Deliverables:**
- learning reveal UI

**Acceptance Criteria:**
- screen renders payload correctly

**Tests:**
- widget test for payload rendering

---

### FE-006.2 — Build learning state/controller
**Dependencies:** FE-006.1  
**Implementation:**
- `LearningState`
- `LearningController`
- store latest `LEARNING_REVEAL` payload

**Deliverables:**
- learning state handling

**Acceptance Criteria:**
- event drives screen rendering

**Tests:**
- unit test for payload application

---

### FE-006.3 — Build `RoundLeaderboardScreen`
**Dependencies:** FE-006.1  
**Implementation:**
- list rank / score / health / solve time
- host-only `Next Round` button

**Deliverables:**
- round leaderboard screen

**Acceptance Criteria:**
- leaderboard renders current round data correctly
- next round button visible for host only

**Tests:**
- widget test for host button visibility

---

### FE-006.4 — Build leaderboard state/controller
**Dependencies:** FE-006.3  
**Implementation:**
- `LeaderboardState`
- `LeaderboardController`
- map `ROUND_LEADERBOARD`

**Deliverables:**
- stateful leaderboard flow

**Acceptance Criteria:**
- event data appears correctly in screen

**Tests:**
- unit tests for model mapping

---

### FE-006.5 — Next round command flow
**Dependencies:** FE-006.4, FE-004.2  
**Implementation:**
- host button sends `/app/round.next`
- wait for next `ROUND_COUNTDOWN_STARTED`
- route to `/countdown`

**Deliverables:**
- round continuation flow

**Acceptance Criteria:**
- host can move match to next round
- non-host cannot

**Tests:**
- manual multiplayer test

---

# Epic FE-007 — Final Leaderboard and Match Exit

## Objective
Handle end-of-match experience cleanly.

## Branch
`feature/final-leaderboard-and-exit` (umbrella; per-task branches: see master build plan Appendix C)

## Tasks

### FE-007.1 — Build `FinalLeaderboardScreen`
**Dependencies:** FE-006.4  
**Implementation:**
- visually stronger summary layout
- winner emphasis
- list all players
- leave room button

**Deliverables:**
- final leaderboard UI

**Acceptance Criteria:**
- screen renders final ranking clearly

**Tests:**
- widget rendering test

---

### FE-007.2 — Handle `FINAL_LEADERBOARD` routing and state
**Dependencies:** FE-007.1  
**Implementation:**
- map event
- navigate to `/final-leaderboard`

**Deliverables:**
- end-of-match routing

**Acceptance Criteria:**
- users land on final leaderboard when match ends

**Tests:**
- manual match-complete flow

---

### FE-007.3 — Leave room and clear session
**Dependencies:** FE-007.2  
**Implementation:**
- leave button clears providers
- disconnect websocket
- route back to home

**Deliverables:**
- clean session exit

**Acceptance Criteria:**
- no stale session remains after leaving
- websocket disconnects cleanly

**Tests:**
- manual leave-from-final test

---

# Epic FE-008 — Reconnect / Resync Handling

## Objective
Restore state correctly when reconnect occurs during an active app session.

## Branch
`feature/reconnect-and-resync` (umbrella; per-task branches: see master build plan Appendix C)

## Tasks

### FE-008.1 — Build reconnect models and controller
**Dependencies:** FE-005.5, FE-006.2, FE-006.4  
**Implementation:**
- `ResyncSnapshotModel`
- `ReconnectState`
- `ReconnectController`

**Deliverables:**
- reconnect management layer

**Acceptance Criteria:**
- controller can accept snapshot and decide target screen

**Tests:**
- unit tests for snapshot handling

---

### FE-008.2 — Handle `PLAYER_DISCONNECTED` and `PLAYER_RECONNECTED`
**Dependencies:** FE-008.1  
**Implementation:**
- mark players offline/online in lobby/game UI

**Deliverables:**
- presence indicators

**Acceptance Criteria:**
- room UI reflects presence changes

**Tests:**
- controller state tests

---

### FE-008.3 — Apply `RESYNC_SNAPSHOT`
**Dependencies:** FE-008.1  
**Implementation:**
- map snapshot to session/lobby/game state
- navigate to correct screen

**Deliverables:**
- state restore flow

**Acceptance Criteria:**
- reconnect returns user to correct place with correct data

**Tests:**
- manual reconnect smoke test

---

# Epic FE-009 — UI Polish and Stabilization

## Objective
Make MVP visually coherent and safer to release.

## Branch
`feature/ui-polish-and-stabilization` (umbrella; per-task branches: see master build plan Appendix C)

## Tasks

### FE-009.1 — Loading and error UX cleanup
**Dependencies:** prior epics  
**Implementation:**
- loading overlays
- inline error banners where needed
- snackbars only where transient is appropriate

**Deliverables:**
- consistent loading/error UX

**Acceptance Criteria:**
- no silent failures
- no dead-end loading states

**Tests:**
- widget tests for loading/error rendering

---

### FE-009.2 — Visual state polish
**Dependencies:** prior epics  
**Implementation:**
- correct/wrong colors
- stunned state style
- sudden death style
- host/winner highlights

**Deliverables:**
- consistent visual language

**Acceptance Criteria:**
- state is understandable without console logs

**Tests:**
- manual UX pass

---

### FE-009.3 — Multiplayer manual QA matrix
**Dependencies:** prior epics  
**Implementation:**
Run manual scenarios:
- create + join
- host leaves
- non-host leaves
- reconnect within deadline
- reconnect after expiry
- first solver
- sudden death
- timeout
- final leaderboard
- leave room

**Deliverables:**
- QA checklist results
- bug list

**Acceptance Criteria:**
- all critical flows pass on at least two devices/emulators

---

## 9. Suggested Release Milestones

### Milestone 0.1.0 — Frontend Foundation
Includes:
- FE-001
- FE-002

### Milestone 0.2.0 — Lobby and Start Flow
Includes:
- FE-003
- FE-004

### Milestone 0.3.0 — Gameplay Core
Includes:
- FE-005

### Milestone 0.4.0 — Post-Round UX
Includes:
- FE-006
- FE-007

### Milestone 0.5.0 — Reconnect and Stability
Includes:
- FE-008
- FE-009

---

## 10. Suggested Developer Workflow

For each feature branch:

1. create branch
2. implement smallest coherent slice
3. write/update tests
4. run format + analyze + tests
5. manual smoke test
6. open PR
7. review + merge

### Example
```text
feature/lobby-realtime-updates
  ├── feat: add lobby state and provider
  ├── feat: add lobby websocket subscription
  ├── feat: handle player joined and host transferred events
  ├── test: add lobby controller event mapping tests
  └── fix: align room topic with backend destination
```

Smaller slices can use task branches from the master plan, e.g. `feature/add-lobby-live-state` → merge into the epic umbrella before merging to `main`.

---

## 11. PR Template Checklist

- [ ] task id referenced
- [ ] dependencies satisfied
- [ ] no unrelated files changed
- [ ] routes updated if needed
- [ ] websocket destination constants updated if contract changed
- [ ] provider/controller tests added or updated
- [ ] widget/integration/manual tests executed
- [ ] screenshots or screen recording attached for UI changes
- [ ] backend contract assumptions documented in PR description

---

## 12. Manual Test Matrix (Minimum)

### Entry Flow
- [ ] Home → Create Room
- [ ] Home → Join Room
- [ ] Create Room invalid form
- [ ] Join Room invalid room code

### Lobby
- [ ] second player appears in host lobby in real time
- [ ] host transfer updates UI
- [ ] host-only start button visibility works

### Game
- [ ] round start routes to game
- [ ] correct guess updates masked word and score
- [ ] wrong guess updates health and wrong letters
- [ ] stunned player cannot guess
- [ ] solved player gets marked visually
- [ ] sudden death warning appears

### Post-Round
- [ ] learning reveal shows correct word and meanings
- [ ] round leaderboard shows ranking
- [ ] next round host button works

### Final Flow
- [ ] final leaderboard appears
- [ ] leave room clears state and disconnects socket

### Reconnect
- [ ] player disconnect visible in room
- [ ] reconnect within window restores state
- [ ] expired reconnect removes player

---

## 13. Acceptance Criteria for Frontend MVP Completion

Frontend MVP is considered complete when:
- user can create or join a room from app start
- lobby reflects live player changes without refresh
- host can start game and all players transition correctly
- game screen supports letter-button guessing and live private updates
- score and health reflect backend events accurately
- learning reveal and leaderboards render correctly
- final leaderboard is shown at match end
- reconnect within active app session restores the player correctly
- no critical flow requires app restart to recover
- all critical flows pass manual QA matrix

---

## 14. Final Recommendation

Implement in the exact epic order above.
Do not jump directly into gameplay UI before:
- router
- session state
- lobby realtime flow
are stable.

The biggest risk areas are:
- STOMP destination mismatch
- event payload mismatch
- state duplication between session/lobby/game
- navigation being triggered from too many places
- reconnect restoring the wrong screen

To reduce bugs:
- centralize destinations
- centralize routing
- keep backend mapping strict
- let controllers own transitions, not widgets
- merge only coherent, tested slices
