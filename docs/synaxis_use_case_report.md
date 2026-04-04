# Synaxis System Use Case Report

## 1. Scope

This report provides a low-level architectural use-case analysis for the **Synaxis** system: a real-time multiplayer vocabulary race game built around room-based play, CEFR-driven word selection, private per-player progress, persistent health across rounds, sudden-death completion logic, learning reveal screens, leaderboards, and reconnect handling.

The document is intended for:
- front-end developers
- back-end developers
- technical leads
- architects
- QA engineers

It describes **how each use case propagates through the system layers**, including:
- front-end screens, controllers, and state stores
- transport layers (REST and WebSocket/STOMP)
- back-end controllers, services, repositories, schedulers, and publishers
- domain state mutations
- resulting events and UI transitions

---

## 2. System Context

### 2.1 Core Domain Summary

Synaxis is a room-based, real-time vocabulary game in which multiple players compete on the **same word** each round, but each player maintains a **private board** and private guessed-letter state. The server is the **source of truth** for room state, round state, scoring, health, stun/recovery, winners, and reconnect recovery.

### 2.2 Interaction Channels

The system uses two communication patterns:

#### REST
Used for non-real-time bootstrap and session recovery operations:
- create room
- join room
- leave room
- reconnect bootstrap
- room/session snapshot retrieval

#### WebSocket/STOMP
Used for real-time in-match operations:
- start game
- guess letter
- next round
- room shared events
- player private events
- leaderboard pushes
- disconnect/reconnect broadcast notifications

### 2.3 Primary Actors

- **Host Player**: creates room, starts game, moves to next round
- **Regular Player**: joins room and participates in rounds
- **Server**: authoritative execution engine
- **Scheduler**: time-driven component for timeout, stun recovery, reconnect expiry, and sudden death expiration

---

## 3. Architectural Layering

## 3.1 Front-End Reference Modules

### App / Platform Layer
- `main.dart`
- router (`go_router` or equivalent)
- app theme / app config

### Core Layer
- `ApiClient`
- `WebSocketClient`
- shared error handling
- app configuration (`baseUrl`, `wsUrl`)

### Feature Modules

#### Home
- `HomeScreen`

#### Room
- `CreateRoomScreen`
- `JoinRoomScreen`
- `LobbyScreen`
- `RoomSessionProvider`
- `RoomLiveStateProvider`
- `LobbyEventHandler`

#### Countdown
- `CountdownScreen`
- countdown state/controller

#### Game
- `GameScreen`
- `GameStateProvider`
- `GameEventHandler`
- on-screen letter button grid

#### Learning
- `LearningRevealScreen`

#### Leaderboard
- `RoundLeaderboardScreen`
- `FinalLeaderboardScreen`

### Shared Models
- `RoomSessionModel`
- `PlayerSessionModel`
- `PlayerSummaryModel`
- game UI view models derived from backend payloads

---

## 3.2 Back-End Reference Modules

### Room / Bootstrap Layer
- `RoomController`
- `RoomWsController`
- `RoomService`
- `RoomRepository` / `InMemoryRoomRepository`
- `RoomLockManager`

### Match / Round Layer
- `MatchService`
- `RoundService`
- `RoundState`
- `MatchState`
- `RoundWord`
- `PlayerRoundProgress`

### Word Selection Layer
- `WordRepository`
- `CefrWordSelector`

### Scoring / Health Layer
- `LetterFrequencyClassifier`
- `ScoreCalculator`
- `HealthManager`
- `StunManager`
- `PenaltyManager`

### Leaderboard Layer
- `LeaderboardService`

### Reconnect / Presence Layer
- `DisconnectManager`
- `ReconnectSnapshotBuilder`
- reconnect expiry / stun recovery schedulers

### Messaging Layer
- `GameEventPublisher`
- topic helpers / queue helpers

---

## 4. Shared State Objects

### 4.1 Room
Represents the long-lived multiplayer container.

Contains:
- room code
- room status (`WAITING`, `IN_GAME`, `ENDED`, `DESTROYED` or equivalent)
- settings
- player sessions
- match state reference

### 4.2 MatchState
Represents the active match spanning all rounds.

Contains:
- total rounds
- current round number
- selected round words (preloaded)
- match status (`NOT_STARTED`, `COUNTDOWN`, `IN_PROGRESS`, `FINISHED` or equivalent)
- current round state

### 4.3 RoundState
Represents the current round.

Contains:
- round number
- selected word payload (`RoundWord`)
- round status (`PREPARING`, `COUNTDOWN`, `ACTIVE`, `SUDDEN_DEATH`, `LEARNING_REVEAL`, `ROUND_RESULTS`, `COMPLETED`)
- timing markers (`startedAt`, `timeoutAt`, `suddenDeathAt`)
- first solver identity
- per-player progress map

### 4.4 PlayerSession
Represents a player inside a room/match.

Contains:
- player id
- player name
- player token
- host flag
- connected flag
- presence status (`ACTIVE`, `OFFLINE_TEMP`, `STUNNED`, etc.)
- reconnect deadline
- score
- health
- total solve time
- rounds won first
- stun-until marker

### 4.5 PlayerRoundProgress
Represents private progress for a single player in a single round.

Contains:
- guessed letters
- correct letters
- wrong letters
- masked word
- solved flag
- solved timestamp

---

## 5. Communication Conventions

## 5.1 REST Use Cases
Used for:
- room creation
- room join
- room leave
- reconnect bootstrap

### Typical Flow
`Screen -> Controller/Provider -> ApiClient -> REST endpoint -> Service -> Repository -> Response DTO -> Front-end state update`

## 5.2 WebSocket Use Cases
Used for:
- game start
- guess letter
- next round
- shared room updates
- private player updates
- leaderboard updates
- reconnect/disconnect broadcasts

### Typical Flow
`UI interaction -> Feature controller/provider -> WebSocketClient.sendJson -> @MessageMapping handler -> validation -> RoomService (locked) -> domain services -> save -> GameEventPublisher -> topic/user queue -> feature event handler -> state update -> UI repaint`

## 5.3 Shared vs Private Event Rule

### Shared Topic
Visible to all room participants:
- player joined
- player left
- host transferred
- game started
- round started
- sudden death started
- learning reveal
- round leaderboard
- final leaderboard
- player disconnected / reconnected

### Private Queue
Visible to one player only:
- guess result
- player round state
- stunned / recovered
- resync snapshot

---

## 6. Use Case Catalog

This section enumerates the operational use cases relevant to the Synaxis domain.

---

# UC-01 — Open App and Enter Home Screen

## Goal
Present the initial entry point with two primary actions:
- Create Room
- Join Room

## Trigger
User launches the mobile application.

## Preconditions
- App installed
- No persisted session restoration is required on cold start

## Front-End Participants
- `main.dart`
- router
- `HomeScreen`

## Back-End Participants
- none

## Low-Level Flow
1. Application process starts.
2. Router resolves initial route.
3. `HomeScreen` renders two buttons.
4. User chooses either `Create Room` or `Join Room`.

## Data Exchange
- none

## Conditions / Dependencies
- Router must be initialized.
- Theme and localization (if any) must already be configured.

---

# UC-02 — Open Create Room Form

## Goal
Allow a host player to enter name and room settings.

## Trigger
User taps `Create Room` on `HomeScreen`.

## Front-End Participants
- `HomeScreen`
- router
- `CreateRoomScreen`
- `CreateRoomFormController` (or equivalent local form state)

## Back-End Participants
- none yet

## Low-Level Flow
1. User taps `Create Room`.
2. Router navigates to `CreateRoomScreen`.
3. Form renders inputs:
   - player name
   - CEFR level
   - max players
   - total rounds
   - round duration
4. Local validation runs before submit.

## Data Exchange
- none yet

## Conditions / Dependencies
- Form validation rules must mirror backend request constraints to reduce noisy failures.

---

# UC-03 — Create Room

## Goal
Create a new room and initialize the host session.

## Trigger
Host submits `CreateRoomScreen` form.

## Entry Conditions
- valid player name
- valid room settings

## Front-End Participants
- `CreateRoomScreen`
- room form controller/provider
- `RoomApi.createRoom(...)`
- `ApiClient`
- `RoomSessionProvider`
- router
- `LobbyScreen`

## Back-End Participants
- `RoomController.createRoom(...)`
- request validation
- `RoomService.createRoom(...)`
- `RoomRepository.save(...)`

## REST Interface
`POST /api/rooms` (or implementation-specific equivalent)

## Low-Level Flow
1. User submits form.
2. Front-end validates required fields.
3. `RoomApi.createRoom(...)` serializes request body.
4. `ApiClient` sends HTTP POST.
5. Back-end controller receives request DTO.
6. Bean validation verifies fields.
7. `RoomService`:
   - generates room code
   - generates player id/token
   - builds `PlayerSession` for host
   - builds `RoomSettings`
   - builds `Room`
   - saves room in repository
8. Controller returns success response with:
   - room code
   - player identity/token
   - host status
   - players snapshot
9. Front-end parses response into models.
10. `RoomSessionProvider` stores:
    - room code
    - player identity
    - token
    - host flag
11. Router navigates to `LobbyScreen`.

## Data Exchange
### Request
- `playerName`
- `cefrLevel`
- `maxPlayers`
- `totalRounds`
- `roundDurationSeconds`

### Response
- `roomCode`
- `playerId`
- `playerName`
- `playerToken`
- `isHost`
- `roomState`
- `players`

## Failure Paths
- validation error
- duplicate room code collision (resolved server-side via regeneration)
- generic server error

## Dependencies
- REST bootstrap layer must be available.
- Room creation request/response contracts must match between Flutter and backend.

---

# UC-04 — Open Join Room Form

## Goal
Allow a non-host player to submit name and room code.

## Trigger
User taps `Join Room` on `HomeScreen`.

## Front-End Participants
- `HomeScreen`
- router
- `JoinRoomScreen`

## Back-End Participants
- none yet

## Low-Level Flow
1. User taps `Join Room`.
2. Router navigates to `JoinRoomScreen`.
3. Screen renders fields:
   - player name
   - room code
4. Local validation runs before submit.

## Data Exchange
- none yet

---

# UC-05 — Join Room

## Goal
Join an existing room before match start.

## Trigger
User submits `JoinRoomScreen` form.

## Entry Conditions
- room code entered
- player name entered

## Front-End Participants
- `JoinRoomScreen`
- `RoomApi.joinRoom(...)`
- `ApiClient`
- `RoomSessionProvider`
- router
- `LobbyScreen`

## Back-End Participants
- `RoomController.joinRoom(...)`
- validation
- `RoomService.joinRoom(...)`
- `RoomLockManager`
- `RoomRepository.findByCode(...)`
- `RoomRepository.save(...)`

## REST Interface
`POST /api/rooms/{roomCode}/join`

## Low-Level Flow
1. User submits name + room code.
2. Front-end validates presence of both fields.
3. `RoomApi.joinRoom(...)` sends HTTP POST.
4. Controller resolves `{roomCode}`.
5. `RoomService.joinRoom(...)` executes inside per-room lock.
6. Service validates:
   - room exists
   - room status still waiting
   - room not full
7. Service creates player session.
8. Room repository saves updated room.
9. Response returns joined player snapshot and player list.
10. Front-end saves room session.
11. Router navigates to `LobbyScreen`.

## Failure Paths
- room not found
- room full
- game already started
- validation error

## Dependencies
- Room must already exist.
- Join is only allowed before first round start.

---

# UC-06 — Establish Lobby WebSocket Connection

## Goal
Connect the client to shared lobby updates for the current room.

## Trigger
`LobbyScreen` initializes after create/join.

## Front-End Participants
- `LobbyScreen`
- `WebSocketClient`
- `RoomLiveStateProvider`
- `LobbyEventHandler`

## Back-End Participants
- WebSocket endpoint `/ws`
- STOMP broker

## Low-Level Flow
1. `LobbyScreen` reads `RoomSessionProvider`.
2. Screen initializes `RoomLiveStateProvider` from initial REST snapshot.
3. `WebSocketClient.connect(...)` opens STOMP connection.
4. On connect, client subscribes to room shared topic.
5. Lobby screen waits for shared events.

## Data Exchange
### Subscription destination
- room topic (implementation-specific)

## Dependencies
- WebSocket endpoint must be reachable.
- Front-end topic path must exactly match publisher path.

---

# UC-07 — Live Lobby Update: Player Joined

## Goal
Reflect new player presence in all lobby clients.

## Trigger
A second client successfully joins the room.

## Front-End Participants
- `LobbyScreen`
- `RoomLiveStateProvider`
- `LobbyEventHandler.handlePlayerJoined(...)`

## Back-End Participants
- `RoomService.joinRoom(...)`
- `GameEventPublisher.publishRoomEvent(...)`

## Low-Level Flow
1. Joining client completes REST join.
2. Back-end emits `PLAYER_JOINED` to room topic.
3. Existing clients receive event in WebSocket subscription callback.
4. `LobbyEventHandler` appends player if not already present.
5. `RoomLiveStateProvider` updates players list.
6. `LobbyScreen` rebuilds.

## Data Exchange
Event fields should include at least:
- `type`
- `roomCode`
- `playerId`
- `playerName`
- `isHost`

## Dependencies
- Room topic subscription must already be active.

---

# UC-08 — Live Lobby Update: Player Leaves / Removed / Host Transfer

## Goal
Keep lobby membership and host ownership synchronized.

## Trigger
- player leaves explicitly
- player removed after reconnect expiry
- host changes

## Front-End Participants
- `LobbyScreen`
- `RoomLiveStateProvider`
- `LobbyEventHandler`

## Back-End Participants
- `RoomService.leaveRoom(...)`
- `RoomService.removeExpiredDisconnectedPlayer(...)`
- `GameEventPublisher.publishPlayerRemovedAfterDisconnect(...)`
- `GameEventPublisher.publishHostTransferred(...)`

## Low-Level Flow
1. Back-end mutates room membership.
2. Back-end publishes shared event(s).
3. Flutter lobby receives event.
4. Local player list is updated.
5. Host badge moves if required.

## Dependencies
- Shared topic must remain connected.
- Front-end handler must support both removal and host-transfer updates.

---

# UC-09 — Host Starts Game

## Goal
Transition room from waiting lobby into match start flow.

## Trigger
Host taps `Start Game` in `LobbyScreen`.

## Entry Conditions
- current player is host
- game not already started
- WebSocket connected

## Front-End Participants
- `LobbyScreen`
- `WebSocketClient.sendJson(...)`
- room live state provider
- router

## Back-End Participants
- `RoomWsController.startGame(...)`
- `CommandValidationService.validateHostStartGameCommand(...)`
- `RoomService.startGame(...)`
- `MatchService.createMatchState(...)`
- `CefrWordSelector.selectWordsForMatch(...)`
- `RoomRepository.save(...)`
- `GameEventPublisher.publishGameStarted(...)`
- `GameEventPublisher.publishRoundCountdownStarted(...)`

## WebSocket Interface
Client send destination:
- `/app/game.start` (or implementation-specific equivalent)

## Low-Level Flow
1. Host taps start button.
2. Flutter sends `StartGameCommand` with:
   - room code
   - player id
   - player token
3. Back-end WebSocket controller receives command.
4. Validation service checks:
   - room exists
   - player session valid
   - token valid
   - player is host
5. `RoomService.startGame(...)` executes under room lock.
6. `MatchService.createMatchState(...)`:
   - initializes player match fields
   - preloads round words
   - creates first `RoundState`
7. Room status moves to `IN_GAME`.
8. Room repository saves room.
9. Publisher emits `GAME_STARTED` shared event.
10. Publisher emits `ROUND_COUNTDOWN_STARTED` shared event.
11. Lobby clients receive `GAME_STARTED`.
12. Router navigates each client to `CountdownScreen`.

## Dependencies
- Lobby socket connection must be active.
- Match setup must succeed before publish.

---

# UC-10 — Countdown Screen Transition

## Goal
Present a dedicated pre-round countdown screen before round activation.

## Trigger
Client receives `GAME_STARTED` and/or `ROUND_COUNTDOWN_STARTED`.

## Front-End Participants
- router
- `CountdownScreen`
- countdown controller/provider

## Back-End Participants
- `GameEventPublisher.publishRoundCountdownStarted(...)`
- `MatchService.startRoundCountdown(...)`

## Low-Level Flow
1. Front-end receives shared event.
2. Router transitions to `CountdownScreen`.
3. Countdown state is initialized from event payload.
4. Screen displays countdown value until round starts.

## Dependencies
- Front-end event mapping must distinguish lobby state from countdown state.

---

# UC-11 — Round Starts

## Goal
Activate the current round and present gameplay screen.

## Trigger
Backend completes countdown and starts the round.

## Front-End Participants
- `CountdownScreen`
- router
- `GameScreen`
- `GameStateProvider`

## Back-End Participants
- `MatchService.activateRound(...)`
- `RoomService.startRound(...)`
- `GameEventPublisher.publishRoundStarted(...)`

## Low-Level Flow
1. Back-end activates current `RoundState`.
2. `startedAt` and `timeoutAt` are assigned.
3. Shared event `ROUND_STARTED` is published.
4. Front-end receives event.
5. Router moves from `CountdownScreen` to `GameScreen`.
6. `GameStateProvider` initializes round-level UI state.

## Dependencies
- Countdown must already be in progress.

---

# UC-12 — Render Active Game Screen

## Goal
Show full interactive gameplay UI for one player.

## Front-End Participants
- `GameScreen`
- `GameStateProvider`
- on-screen letter buttons widget
- player summary widgets
- timer widget

## Back-End Participants
- none directly at render time; backend provides state via events

## UI Composition Requirements
The active gameplay screen should present:
- masked word
- letter buttons grid (not system keyboard)
- player score
- player health
- remaining time
- round number
- player list / room participants
- solver highlight indication

## Dependencies
- private player state must already be available
- shared round context must already be available

---

# UC-13 — Send Guess Letter Command

## Goal
Submit one guessed letter from the game UI.

## Trigger
Player taps one letter button.

## Entry Conditions
- current round active
- player not stunned
- player not offline
- guessed letter not already used by that player

## Front-End Participants
- `GameScreen`
- `GameController` / `GameStateNotifier`
- `WebSocketClient.sendJson(...)`

## Back-End Participants
- `RoomWsController.guessLetter(...)`
- `CommandValidationService.validatePlayerCommand(...)`
- `RoomService.handleGuess(...)`
- `RoundService.validateGuess(...)`
- `RoundService.applyGuess(...)`

## WebSocket Interface
Client send destination:
- `/app/game.guess-letter` (or implementation-specific equivalent)

## Low-Level Flow
1. Player taps a letter button.
2. Front-end marks the button as pending/disabled if desired.
3. Client sends `GuessLetterCommand` with:
   - room code
   - player id
   - player token
   - letter
4. WebSocket handler receives command.
5. Validation checks room/session authorization.
6. `RoomService.handleGuess(...)` enters room lock.
7. `RoundService.validateGuess(...)` confirms:
   - active round
   - player connected
   - not stunned
   - single valid letter
   - not duplicate
8. `RoundService.applyGuess(...)` mutates progress.

## Dependencies
- GameScreen must be connected to private game queue and command channel.

---

# UC-14 — Apply Correct Guess

## Goal
Update player private progress and score on a correct guess.

## Trigger
`RoundService.applyGuess(...)` determines the guessed letter exists in the current round word.

## Front-End Participants
- `GameStateProvider`
- `GameScreen`

## Back-End Participants
- `RoundService.applyGuess(...)`
- `LetterFrequencyClassifier`
- `ScoreCalculator`
- `RoomService.handleGuess(...)`
- `GameEventPublisher.publishLetterGuessResult(...)`
- `GameEventPublisher.publishPlayerRoundState(...)`

## Low-Level Flow
1. `applyGuess(...)` adds letter to guessed set.
2. Letter is placed into `correctLetters`.
3. `maskedWord` is rebuilt from the canonical word and correct letters.
4. `solved` is recalculated.
5. `RoomService` classifies letter frequency.
6. `ScoreCalculator` computes score breakdown.
7. `PlayerSession.score` is incremented.
8. Room is saved.
9. Publisher sends private events to `/user/queue/game`:
   - `LETTER_GUESS_RESULT`
   - `PLAYER_ROUND_STATE`
10. Front-end private game handler updates GameState.
11. UI re-renders:
   - selected letter button turns green
   - masked word reveals correct positions
   - score increases

## Dependencies
- Scoring engine must already be integrated.

---

# UC-15 — Apply Wrong Guess

## Goal
Update player private progress, health, and possibly stun state on a wrong guess.

## Trigger
`RoundService.applyGuess(...)` determines the guessed letter does not exist in the word.

## Front-End Participants
- `GameStateProvider`
- `GameScreen`

## Back-End Participants
- `RoundService.applyGuess(...)`
- `HealthManager.applyWrongGuessDamage(...)`
- `StunManager.triggerStunIfNeeded(...)`
- `PenaltyManager.applyStunPenalty(...)` (if health reaches zero)
- `RoomService.handleGuess(...)`
- `GameEventPublisher.publishLetterGuessResult(...)`
- `GameEventPublisher.publishPlayerRoundState(...)`
- optionally `publishPlayerStunned(...)`

## Low-Level Flow
1. `applyGuess(...)` adds letter to guessed set.
2. Letter is added to `wrongLetters`.
3. `maskedWord` remains unchanged.
4. `HealthManager` calculates health delta based on letter category.
5. Player health is reduced.
6. If health reaches zero:
   - `StunManager` marks player stunned for 5 seconds
   - `PenaltyManager` applies score penalty
   - player stunned event is published
7. Room is saved.
8. Publisher sends updated private round/player state.
9. Front-end updates UI:
   - selected button turns red
   - health decreases
   - if stunned, input becomes disabled and stun overlay/timer appears

## Dependencies
- Health/stun engine must be active.
- UI must respect `stunned` flag.

---

# UC-16 — Reject Invalid or Duplicate Guess

## Goal
Prevent illegal input from mutating gameplay state.

## Trigger
Player sends a guess that is:
- duplicate
- not a single English letter
- while round not active
- while stunned
- while offline

## Front-End Participants
- `GameScreen`
- `GameStateProvider`
- error UI (snackbar/toast or inline message)

## Back-End Participants
- `CommandValidationService`
- `RoundService.validateGuess(...)`
- optional error event publisher

## Low-Level Flow
1. Client sends invalid guess command.
2. Back-end validation fails before state mutation.
3. No change occurs to score, health, or progress.
4. Optional error event or error response path is emitted.
5. Front-end displays error feedback and keeps existing state intact.

## Dependencies
- Validation guards must execute before mutation.

---

# UC-17 — Detect First Solver

## Goal
Determine the first player who completes the word and trigger sudden death.

## Trigger
A guess causes `PlayerRoundProgress.solved = true`.

## Front-End Participants
- `GameScreen`
- shared room event handler
- private game state handler

## Back-End Participants
- `RoomService.handleGuess(...)`
- `RoundService.registerFirstSolverIfNeeded(...)`
- `GameEventPublisher.publishPlayerSolvedWord(...)`
- `GameEventPublisher.publishSuddenDeathStarted(...)`

## Low-Level Flow
1. Player completes the full word.
2. `RoundService` checks whether current round already has a first solver.
3. If no first solver exists:
   - set `firstSolverPlayerId`
   - set `firstSolvedAt`
   - set `suddenDeathAt = now + 10s`
   - move round status from `ACTIVE` to `SUDDEN_DEATH`
4. `RoomService` applies first-finisher reward:
   - `+150 score`
   - `health = 100`
5. Room is saved.
6. Shared events are published:
   - `PLAYER_SOLVED_WORD`
   - `SUDDEN_DEATH_STARTED`
7. Front-end room/game views reflect the winner and sudden death state.

## Dependencies
- Must execute under room lock to avoid double first-solver assignment.

---

# UC-18 — Later Solver During Sudden Death

## Goal
Allow non-first solvers to finish within the 10-second sudden death window.

## Trigger
A player solves while round status is `SUDDEN_DEATH` and player is not the first solver.

## Front-End Participants
- `GameScreen`
- shared room event handler
- private state handler

## Back-End Participants
- `RoomService.handleGuess(...)`
- `RoundState.isInSuddenDeath()`
- `GameEventPublisher.publishPlayerSolvedDuringSuddenDeath(...)`

## Low-Level Flow
1. Player solves during sudden death.
2. Server verifies this player is not the first solver.
3. Player receives:
   - normal letter points only
   - `+20 HP` capped at `100`
4. Room is saved.
5. Shared event is published to room.
6. Private state event updates the solving player's health and solved state.

## Dependencies
- Sudden death must already be active.
- No first-finisher bonus should be applied here.

---

# UC-19 — Round Timeout Without Winner

## Goal
End the round when time expires before any player solves.

## Trigger
Scheduler detects `now >= timeoutAt` while round status is `ACTIVE`.

## Front-End Participants
- `GameScreen`
- room shared event handler
- router / post-round navigation logic

## Back-End Participants
- `RoundTimeoutScheduler`
- `RoomService.timeoutCurrentRound(...)`
- `RoundState.showLearningReveal()`
- `GameEventPublisher.publishRoundTimeout(...)`
- `GameEventPublisher.publishLearningReveal(...)`
- `GameEventPublisher.publishRoundLeaderboard(...)`

## Low-Level Flow
1. Scheduler scans active rooms.
2. For each room, service checks current round timeout.
3. If expired and still `ACTIVE`:
   - round moves to `LEARNING_REVEAL`
4. Room is saved.
5. Shared events are published:
   - `ROUND_TIMEOUT`
   - `LEARNING_REVEAL`
   - `ROUND_LEADERBOARD`
6. Front-end leaves active gameplay and transitions to post-round flow.

## Dependencies
- Round must still be `ACTIVE`.
- Timeout flow must not conflict with first solver / sudden death flow.

---

# UC-20 — End Sudden Death

## Goal
Close the 10-second sudden death window and move to learning reveal.

## Trigger
Scheduler detects `now >= suddenDeathAt` while round status is `SUDDEN_DEATH`.

## Front-End Participants
- `GameScreen`
- shared event handler
- router / post-round navigation logic

## Back-End Participants
- `SuddenDeathScheduler`
- `RoomService.endSuddenDeathIfNeeded(...)`
- `GameEventPublisher.publishSuddenDeathEnded(...)`
- `GameEventPublisher.publishLearningReveal(...)`
- `GameEventPublisher.publishRoundLeaderboard(...)`

## Low-Level Flow
1. Scheduler scans rooms.
2. If sudden death expired:
   - round moves from `SUDDEN_DEATH` to `LEARNING_REVEAL`
3. Room is saved.
4. Shared events are published.
5. Front-end transitions out of gameplay.

## Dependencies
- `suddenDeathAt` must have been set previously by first-solver flow.

---

# UC-21 — Learning Reveal Screen

## Goal
Show the educational payload for the just-completed round.

## Trigger
Client receives `LEARNING_REVEAL` event.

## Front-End Participants
- `LearningRevealScreen`
- post-round state provider/controller

## Back-End Participants
- `RoundService.buildLearningRevealPayload(...)`
- `GameEventPublisher.publishLearningReveal(...)`

## Low-Level Flow
1. Server builds `LearningRevealPayload` from current round word.
2. Event is published to room.
3. Front-end receives payload.
4. Router navigates to `LearningRevealScreen`.
5. Screen displays:
   - word
   - Arabic meaning
   - English definition
6. User taps continue to move to leaderboard screen.

## Dependencies
- Round must already be completed or otherwise ended.

---

# UC-22 — Round Leaderboard

## Goal
Display the cumulative per-round ranking after round completion.

## Trigger
Client receives `ROUND_LEADERBOARD` event.

## Front-End Participants
- `RoundLeaderboardScreen`
- leaderboard state provider

## Back-End Participants
- `LeaderboardService.buildRoundLeaderboard(...)`
- `GameEventPublisher.publishRoundLeaderboard(...)`

## Low-Level Flow
1. Back-end ranks current players.
2. Ranking uses comparator chain:
   - score descending
   - health descending
   - solve time ascending
3. Shared round leaderboard event is published.
4. Front-end receives payload.
5. Screen renders ordered entries.
6. If player is host, a `Next Round` button is rendered.

## Dependencies
- Learning reveal may precede this screen.
- Current player host flag determines visibility of next-round control.

---

# UC-23 — Host Starts Next Round

## Goal
Move the match from post-round state into the next round.

## Trigger
Host presses `Next Round` on `RoundLeaderboardScreen`.

## Front-End Participants
- `RoundLeaderboardScreen`
- `WebSocketClient.sendJson(...)`

## Back-End Participants
- WebSocket `next round` command handler
- command validation (host-only)
- `RoomService.proceedAfterRound(...)`
- `MatchService.advanceToNextRound(...)`
- `MatchService.startRoundCountdown(...)`
- `GameEventPublisher.publishRoundCountdownStarted(...)`

## Low-Level Flow
1. Host presses `Next Round`.
2. Front-end sends next-round command with room/player/token.
3. Backend validates host authority.
4. `proceedAfterRound(...)` checks whether another round exists.
5. If yes:
   - increment `currentRoundNumber`
   - create next `RoundState`
   - move to countdown state
6. Save room.
7. Publish round countdown event.
8. Front-end navigates to `CountdownScreen`.

## Dependencies
- Only host may trigger this.
- Current round must already be completed.

---

# UC-24 — Final Match Completion

## Goal
Finish the match after the last round and expose final ranking.

## Trigger
`proceedAfterRound(...)` is executed and `hasNextRound() == false`.

## Front-End Participants
- `FinalLeaderboardScreen`
- router

## Back-End Participants
- `RoomService.proceedAfterRound(...)`
- `MatchService.finishMatch(...)`
- `LeaderboardService.buildFinalLeaderboard(...)`
- `GameEventPublisher.publishMatchFinished(...)`
- `GameEventPublisher.publishFinalLeaderboard(...)`

## Low-Level Flow
1. Service detects there is no next round.
2. Match status becomes `FINISHED`.
3. Room may become `ENDED` or equivalent post-match state.
4. Final leaderboard payload is built.
5. Shared events are published:
   - `MATCH_FINISHED`
   - `FINAL_LEADERBOARD`
6. Front-end navigates to `FinalLeaderboardScreen`.
7. Final screen presents richer summary and leave-room action.

## Dependencies
- All rounds must already be completed.

---

# UC-25 — Leave Room Explicitly

## Goal
Allow player to leave lobby or room session intentionally.

## Trigger
User taps `Leave Room` button.

## Front-End Participants
- `LobbyScreen`
- `ApiClient`
- `RoomApi.leaveRoom(...)`
- session provider
- router

## Back-End Participants
- `RoomController.leaveRoom(...)`
- `RoomService.leaveRoom(...)`
- `RoomLockManager`
- `RoomRepository`
- `GameEventPublisher.publishHostTransferred(...)` if needed

## REST Interface
`POST /api/rooms/{roomCode}/leave`

## Low-Level Flow
1. User taps leave.
2. Front-end sends room code + player id + player token.
3. Backend validates ownership.
4. Under room lock, player is removed.
5. If removed player was host:
   - assign new host
6. If room becomes empty:
   - delete room
7. Save room.
8. Publish shared update(s).
9. Front-end clears session and returns to `HomeScreen`.

## Dependencies
- Room session must exist locally.

---

# UC-26 — Player Disconnects (Temporary Offline)

## Goal
Mark player as temporarily offline rather than removing immediately.

## Trigger
WebSocket/session disconnect hook or explicit disconnect detection.

## Front-End Participants
- none direct at trigger time; state changes are received as events

## Back-End Participants
- WebSocket session hook
- `RoomService.handleDisconnect(...)`
- `DisconnectManager.markDisconnected(...)`
- `RoomRepository.save(...)`
- `GameEventPublisher.publishPlayerDisconnected(...)`

## Low-Level Flow
1. Server detects socket/session disconnect.
2. It resolves room + player identity from session context.
3. `RoomService.handleDisconnect(...)` executes under room lock.
4. `DisconnectManager` sets:
   - connected = false
   - status = `OFFLINE_TEMP`
   - reconnect deadline = now + 30s
5. Room is saved.
6. Shared `PLAYER_DISCONNECTED` event is published.
7. Other clients update room presence indicators.

## Dependencies
- Session mapping from WebSocket connection to player identity must exist.

---

# UC-27 — Reconnect Window Expires

## Goal
Remove an offline-temporary player after the grace period.

## Trigger
Reconnect expiry scheduler sees `now >= reconnectDeadline`.

## Front-End Participants
- shared room listeners update lobby/game player list

## Back-End Participants
- `ReconnectExpiryScheduler`
- `DisconnectManager.isReconnectExpired(...)`
- `RoomService.removeExpiredDisconnectedPlayer(...)`
- `GameEventPublisher.publishPlayerRemovedAfterDisconnect(...)`
- `GameEventPublisher.publishHostTransferred(...)` if host removed

## Low-Level Flow
1. Scheduler iterates rooms and players.
2. For each offline-temp player, expiry is evaluated.
3. Under room lock, expired player is removed.
4. If room becomes empty:
   - delete room
   - clear lock
5. If removed player was host:
   - transfer host to next player
6. Save room.
7. Publish removal and host-transfer events.
8. Front-end removes player from local lobby/game state.

## Dependencies
- Grace period must already be set at disconnect time.

---

# UC-28 — Reconnect Within Grace Window

## Goal
Restore the same player session without creating a new identity.

## Trigger
Client calls reconnect bootstrap API before deadline expiry.

## Front-End Participants
- reconnect controller
- `RoomApi.reconnect(...)`
- `RoomSessionProvider`
- `GameStateProvider` / `LobbyStateProvider`

## Back-End Participants
- `RoomController.reconnect(...)`
- `RoomService.reconnectPlayer(...)`
- `ReconnectSnapshotBuilder.build(...)`
- `GameEventPublisher.publishPlayerReconnected(...)`
- `GameEventPublisher.publishResyncSnapshot(...)`

## REST Interface
`POST /api/rooms/{roomCode}/reconnect`

## Low-Level Flow
1. Client sends room code + player id + player token.
2. Backend validates:
   - room exists
   - player exists
   - token valid
   - status = `OFFLINE_TEMP`
   - deadline not expired
3. Service restores session:
   - connected = true
   - status = `ACTIVE`
   - reconnectDeadline = null
4. Snapshot builder constructs `ResyncSnapshot`.
5. Room is saved.
6. Shared `PLAYER_RECONNECTED` event is published.
7. Private `RESYNC_SNAPSHOT` event is sent to the reconnecting player.
8. Front-end rebuilds the correct screen from snapshot.

## Dependencies
- No local persistence on cold start is assumed in current frontend scope; reconnect is in-session flow.

---

# UC-29 — Resync Snapshot Consumption

## Goal
Restore the correct front-end screen and state after reconnect.

## Trigger
Client receives `RESYNC_SNAPSHOT` private event.

## Front-End Participants
- `WebSocketClient`
- reconnect controller
- room/game state providers
- router

## Back-End Participants
- none after snapshot dispatch

## Low-Level Flow
1. Private queue receives `RESYNC_SNAPSHOT`.
2. Front-end parses payload.
3. Session provider updates current room/player identity.
4. Depending on payload:
   - lobby state is restored if match not active
   - game state is restored if round active or post-round
5. Router navigates to the appropriate screen.
6. UI continues from recovered state.

## Dependencies
- Snapshot payload must be sufficiently complete.

---

# UC-30 — Display Final Leaderboard and Exit Room

## Goal
Allow users to observe final results and leave cleanly.

## Trigger
`FINAL_LEADERBOARD` received and final screen shown.

## Front-End Participants
- `FinalLeaderboardScreen`
- leave-room handler
- router
- session provider

## Back-End Participants
- leave room API as in UC-25

## Low-Level Flow
1. Final leaderboard screen renders entries.
2. User taps `Leave Room`.
3. Leave-room REST flow executes.
4. Front-end clears session and room/game state.
5. Router returns user to `HomeScreen`.

## Dependencies
- Final leaderboard must already have been delivered.

---

## 7. Cross-Cutting Conditions and Constraints

## 7.1 Authoritative Backend Rule
The frontend never computes authoritative values for:
- score
- health
- masked word truth
- solver ranking
- sudden death state
- tie-break resolution

The frontend only renders server-approved state and derived UI-friendly projections.

## 7.2 Shared vs Private Data Rule

### Shared
May go to room topic:
- room membership changes
- game start
- round status changes
- solver announcements
- learning reveal
- leaderboards

### Private
Must only go to player queue:
- guess result details
- masked word
- guessed/correct/wrong letters
- stunned/recovered state
- reconnect snapshot

## 7.3 Concurrency Rule
All room/match mutations with gameplay impact should occur under **per-room synchronization** to prevent:
- double first-solver assignment
- over-capacity joins
- overlapping timeout / sudden death transitions
- inconsistent reconnect/removal behavior

## 7.4 Timing Rule
Schedulers are responsible for:
- round timeout checks
- sudden death expiry checks
- stun recovery checks
- reconnect expiry checks

Schedulers must never contain the full business mutation logic themselves; they delegate to service methods executing under room locks.

---

## 8. Dependency Graph Summary

### Foundational Dependencies
- Room creation must exist before join/reconnect/lobby flows.
- WebSocket infrastructure must exist before start game / guess / shared updates.
- Match setup must exist before round start.
- Round state machine must exist before guessing, timeout, and sudden death.
- Guess handling must exist before scoring and health.
- Scoring + health must exist before first solver and stun flows are complete.
- Learning reveal must exist before round-complete UX is coherent.
- Reconnect snapshot depends on room, match, round, and player state being serializable.

### Front-End Dependencies
- Session state must exist before lobby navigation.
- Lobby live state depends on room topic subscriptions.
- Game screen depends on private queue subscription and room session.
- Learning/leaderboard screens depend on post-round shared events.

---

## 9. Recommended Developer Reading Order

1. Room lifecycle use cases (UC-03 to UC-08)
2. Match bootstrap and round start (UC-09 to UC-11)
3. Guess + progress + scoring + health (UC-13 to UC-18)
4. Round completion (UC-19 to UC-24)
5. Presence/reconnect (UC-26 to UC-29)
6. Final screen flow (UC-30)

This reading order mirrors the system build order and reduces cognitive overhead during implementation.

---

## 10. Practical Implementation Guidance

To keep implementation deterministic and maintainable:
- treat **RoomService** as the orchestration boundary for room-level use cases
- keep **RoundService** focused on round-local gameplay rules
- keep **ScoreCalculator**, **HealthManager**, **StunManager**, and **PenaltyManager** pure or near-pure where possible
- keep **GameEventPublisher** as the single transport abstraction for messaging
- let Flutter feature controllers/providers translate backend payloads into view state, rather than letting widgets manipulate raw transport payloads directly

---

## 11. Final Note

This use-case report is intentionally biased toward **implementation clarity** rather than abstract business-only notation. It is designed so that an engineer can answer, for any interaction:
- where it starts
- what layer receives it
- what state mutates
- what event/response leaves the server
- and what UI should update as a result

That makes it suitable as both:
- a design reference
- and a coding guide during implementation
