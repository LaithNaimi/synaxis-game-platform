# Synaxis Backend — Code Repair & Enhancement Plan

This document decomposes improvement work for the Spring Boot multiplayer word-game backend into **small, verifiable tasks**. Each task includes problem context, trace through the system, impact, proposed fix, and validation.

**Scope reference:** `backend/src/main/java` (room, match, word, messaging, common).

---

## How to use this plan

- Tasks are ordered roughly by **dependency** (unblock gameplay first, then presence/messaging polish).
- Severity tags: **P0** (blocking correct play), **P1** (correctness/reliability), **P2** (consistency, maintainability).
- Estimated size: **S** (≤1h), **M** (half day), **L** (1+ days).

---

# Phase A — Core gameplay correctness (P0)

## A1. Fix English letter validation in `RoundService`

| Field | Detail |
|-------|--------|
| **ID** | A1 |
| **Size** | S |
| **Severity** | P0 |

### Problem description

`RoundService.isEnglishLetter(char)` uses `letter >= 'a' && letter <= 'b'`, which only allows **`a` and `b`**. All other letters fail validation inside `validateGuess` before `applyGuess` mutates state.

**Trace**

1. Client sends WebSocket message to `/app/game.guess-letter` with `GuessLetterCommand`.
2. `RoomWsController.guessLetter` validates length, then calls `RoomService.handleGuess(roomCode, playerId, letter)`.
3. `RoomService` (under room lock) calls `RoundService.applyGuess(room, playerId, letter)`.
4. `applyGuess` calls `validateGuess`, which invokes `isEnglishLetter(letter)` for non-control paths.
5. Letters `c`–`z` throw `IllegalArgumentException` → gameplay broken for almost all guesses.

### Impact analysis

- **Functionality:** Letter guessing effectively limited to two letters; game unplayable as designed.
- **UX:** Persistent failures or generic errors on valid input.
- **Performance:** Negligible; failure is logical, not load-related.

### Solution proposal

- Replace the range check with `letter >= 'a' && letter <= 'z'` after `Character.toLowerCase` (already applied upstream in `applyGuess`), or use a small helper: ASCII Latin a–z only, excluding non-letters.
- Add a **unit test** covering `c`, `z`, and rejecting non-letters.

### Validation strategy

- Unit tests: `validateGuess` / `isEnglishLetter` for boundary characters.
- Manual: WebSocket guess with letters `c`, `m`, `z` during `ACTIVE` round — expect success path (or wrong/correct guess), not validation error.

---

## A2. Fix masked word construction in `RoundService.buildMaskedWord`

| Field | Detail |
|-------|--------|
| **ID** | A2 |
| **Size** | S |
| **Severity** | P0 |

### Problem description

`buildMaskedWord` initializes `StringBuilder` with the full plaintext `word`, then appends per-character reveal logic incorrectly, producing **corrupted** masked strings inconsistent with `buildInitialMaskedWord` (`"_ "` pattern).

**Trace**

1. `applyGuess` updates `correctLetters` / `wrongLetters`, then calls `buildMaskedWord(word, correctLetters)`.
2. Result is stored in `PlayerRoundProgress.maskedWord`.
3. `RoomService.handleGuess` reads progress and publishes `PLAYER_ROUND_STATE` and related events.
4. Clients display a broken mask → trust and UX collapse even when logic elsewhere is fixed.

### Impact analysis

- **Functionality:** Masked word UI and any server-side logic depending on format are wrong.
- **UX:** Players cannot interpret progress.

### Solution proposal

- Rebuild mask from scratch: for each character in `word`, if `correctLetters` contains that letter, append the letter; else append placeholder (e.g. `_`) and a space if matching initial style `"_ "` per letter.
- Align format exactly with `MatchService.buildInitialMaskedWord` / initial `PlayerRoundProgress` expectations.
- Unit test: known word `"hello"`, incremental correct sets → expected mask strings.

### Validation strategy

- Unit tests for several words and guess sequences.
- Compare payload in `publishPlayerRoundState` to expected mask after integration test or manual STOMP capture.

---

## A3. Fix `RoundTimeoutScheduler` null-safety guard

| Field | Detail |
|-------|--------|
| **ID** | A3 |
| **Size** | S |
| **Severity** | P1 |

### Problem description

Condition uses `room.getMatchState() == null && room.getMatchState().getCurrentRound() == null`. When `matchState` is null, Java still evaluates the second clause if using `&&` incorrectly — actually when first is **true** (`matchState == null`), the second part calls `getMatchState()` again and **dereferences null** → `NullPointerException`.

**Trace**

1. `@Scheduled` method `scheduledRoundTimeout` runs every second.
2. Iterates `roomService.getRooms()`.
3. For any room with `getMatchState() == null`, the buggy condition throws.
4. Scheduler thread logs errors; timeout processing may be skipped globally depending on exception handling.

### Impact analysis

- **Reliability:** Scheduler thread exceptions; noisy logs; possible skipped iterations.
- **Functionality:** Rooms without match state may crash the scheduled pass.

### Solution proposal

- Replace with:  
  `if (room.getMatchState() == null || room.getMatchState().getCurrentRound() == null) continue;`
- Optionally skip non-`IN_GAME` rooms first (already partially done).

### Validation strategy

- Unit/integration test with room in `WAITING` and null `matchState` — scheduler runs without NPE.
- Logs: no NPE from `RoundTimeoutScheduler` over several ticks.

---

## A4. Activate round after countdown (server-driven path)

| Field | Detail |
|-------|--------|
| **ID** | A4 |
| **Size** | M |
| **Severity** | P0 |

### Problem description

`RoomService.startGame` sets match + round to countdown and publishes `ROUND_COUNTDOWN_STARTED`, but **`startRound` is never invoked** from controllers or schedulers. `RoundState.activate` is only reachable through `RoomService.startRound`, which has **no callers**. Guesses require `RoundStatus.ACTIVE` via `isAcceptingGuesses()`.

**Trace**

1. REST: create/join room → WebSocket: `StartGameCommand` → `validateHostStartGameCommand` → `RoomService.startGame`.
2. `MatchService.createMatchState` + `startRoundCountdown` → round status `COUNTDOWN`.
3. **No step** transitions to `ACTIVE` with `startedAt` / `timeoutAt`.
4. Client sends guess → `validateGuess` → `"Round is not accepting guesses"`.

### Impact analysis

- **Functionality:** Game cannot enter playable state without external/manual hook not present in repo.
- **UX:** Stuck after “countdown started.”

### Solution proposal

Choose **one** authoritative approach (document in code comment):

- **Option A — Scheduler:** `RoundCountdownScheduler` (or extend existing scheduler): for each `IN_GAME` room, if current round `COUNTDOWN` and `now >= countdownStartedAt + N seconds`, call locked `RoomService` method that invokes `MatchService.activateRound(matchState, roundDurationSeconds)`, save, publish `ROUND_STARTED`.
- **Option B — WebSocket command:** e.g. `/app/game.start-round` with host validation, client fires after local timer — server validates `COUNTDOWN` and calls existing `startRound` logic.

Persist **countdown start time** on `RoundState` if not already present (may require model field) so Option A is deterministic.

### Validation strategy

- Integration: after `startGame`, within N seconds (or after command), round status `ACTIVE`, `timeoutAt` set.
- Guess letter succeeds without “not accepting guesses.”
- Logs/events: `ROUND_STARTED` received on expected topic.

---

## A5. Complete round state machine after learning reveal (`proceedAfterRound`)

| Field | Detail |
|-------|--------|
| **ID** | A5 |
| **Size** | M |
| **Severity** | P0 |

### Problem description

`timeoutCurrentRound` and `endSuddenDeathIfNeed` call `currentRound.showLearningReveal()` then `proceedAfterRound`. `proceedAfterRound` returns early unless `currentRound.getStatus() == RoundStatus.COMPLETED`. **`showRoundResults()` and `complete()` are never called** anywhere in the codebase, so status stays `LEARNING_REVEAL` → next round and match finish never run.

**Trace**

1. Timeout: `RoundTimeoutScheduler` → `RoomService.timeoutCurrentRound` → `showLearningReveal` → publish events → `proceedAfterRound`.
2. Sudden death end: `SuddenDeathScheduler` → `endSuddenDeathIfNeed` → same.
3. `proceedAfterRound`: checks `COMPLETED` → **always fails** → no `advanceToNextRound`, no `finishMatch`.

### Impact analysis

- **Functionality:** No progression to round 2+; no final leaderboard from server flow.
- **UX:** Infinite or stuck session after first round ends.

### Solution proposal

- After learning reveal + leaderboard publish (or inside `proceedAfterRound` before branching):
  - `showRoundResults()` then `complete()` on `RoundState`, **or**
  - Change `proceedAfterRound` to advance from `LEARNING_REVEAL` with explicit transitions in one place.
- Ensure single ordering: persist → publish → advance match state.

### Validation strategy

- Integration: multi-round match — after round 1 ends, `ROUND_COUNTDOWN_STARTED` for round 2 or `MATCH_FINISHED` + `FINAL_LEADERBOARD` on last round.
- Assert `RoundStatus.COMPLETED` before `advanceToNextRound` / `finishMatch` in tests.

---

## A6. Allow guesses during `SUDDEN_DEATH`

| Field | Detail |
|-------|--------|
| **ID** | A6 |
| **Size** | S |
| **Severity** | P1 |

### Problem description

`RoundState.isAcceptingGuesses()` returns true only for `ACTIVE`. After `enterSuddenDeath`, status is `SUDDEN_DEATH`, so `validateGuess` rejects all guesses — contradicts rules for secondary solvers / +HP during sudden death.

**Trace**

1. First solver solves → `registerFirstSolver` → `enterSuddenDeath`.
2. Second player sends guess → `validateGuess` → `round.isAcceptingGuesses()` false → error.

### Impact analysis

- **Functionality:** Sudden death phase cannot be played as designed.
- **UX:** Confusing rejections for valid play.

### Solution proposal

- Extend `isAcceptingGuesses()` to include `SUDDEN_DEATH`, or add `round.isPlayableForGuesses()` used by `validateGuess`.
- Keep distinct rules if needed (e.g. only unsolved players) in `validateGuess`.

### Validation strategy

- Unit/integration: round in `SUDDEN_DEATH`, second player guess processed (correct wrong-letter path as applicable).
- Event: `PLAYER_SOLVED_DURING_SUDDEN_DEATH` path reachable.

---

## A7. Align sudden-death HP bonus with published deltas in `RoomService.handleGuess`

| Field | Detail |
|-------|--------|
| **ID** | A7 |
| **Size** | S |
| **Severity** | P2 |

### Problem description

`GuessHandlingResult` is built before the block that adds +20 HP when solving during sudden death. Published `healthDelta` / state may omit the bonus.

**Trace**

1. `applyGuess` → scoring → `guessResult` constructed.
2. Later: `solvedDuringSuddenDeath` adjusts `player.setHealth` and `healthDelta` variable.
3. `publishPlayerRoundState` uses `guessResult.getHealthDelta()` — may be stale for that branch.

### Impact analysis

- **UX:** Client shows wrong health delta after sudden-death solve.

### Solution proposal

- Rebuild `GuessHandlingResult` after all mutations, or compute final deltas immediately before publish.
- Single method `buildGuessPublishPayload(...)` to avoid ordering bugs.

### Validation strategy

- Unit test: sudden death solve — aggregated `healthDelta` matches +20 (and caps) in published payload.
- Manual STOMP capture of `PLAYER_ROUND_STATE`.

---

# Phase B — Messaging & clients (P1)

## B1. Correct STOMP user destinations in `GameEventPublisher`

| Field | Detail |
|-------|--------|
| **ID** | B1 |
| **Size** | M |
| **Severity** | P1 |

### Problem description

`SimpMessagingTemplate.convertAndSendToUser(username, destination, payload)` expects **principal name** (typically `playerId`). Several methods pass **`roomCode`** as the first argument (`publishSuddenDeathEnded`, `publishLearningReveal`, `publishRoundLeaderboard`, `publishFinalLeaderboard`).

**Trace**

1. Business logic completes → `GameEventPublisher.publishLearningReveal(roomCode, payload)`.
2. `convertAndSendToUser(roomCode, "/queue/game", event)` — wrong user; message not delivered to real players.

### Impact analysis

- **Functionality:** Learning reveal and leaderboards may never reach clients.
- **UX:** Silent missing updates.

### Solution proposal

- For **room-wide** events: use `publishRoundEvent`, `publishLeaderboardEvent`, or `publishRoomEvent` with `TopicNames` already defined.
- If product requires user queue only: loop all `playerId`s in room and send to each, or use room subscription the client already uses.

Align with frontend contract (`contracts` module / docs).

### Validation strategy

- Integration test with STOMP client subscribed to `/topic/rooms/{code}/round` (and leaderboard) — receive payloads after round end.
- Confirm no `convertAndSendToUser(roomCode, ...)`.

---

## B2. Broadcast `SUDDEN_DEATH_STARTED` to the room (or all players)

| Field | Detail |
|-------|--------|
| **ID** | B2 |
| **Size** | S |
| **Severity** | P2 |

### Problem description

`publishSuddenDeathStarted` sends only to `firstSolverPlayerId` private queue. Other participants may need the same event on a **room topic**.

**Trace**

1. `RoomService.handleGuess` → first solver branch → `publishSuddenDeathStarted`.
2. Only one client receives if using private queue.

### Impact analysis

- **UX:** Other players miss phase change unless inferred from other events.

### Solution proposal

- Publish to `roomTopic` or `roomRoundTopic` in addition to or instead of private-only; match product spec.

### Validation strategy

- Two STOMP clients — non-solver receives event on expected subscription.

---

## B3. Event field naming alignment (`correctedLetters` vs `correctLetters`)

| Field | Detail |
|-------|--------|
| **ID** | B3 |
| **Size** | S |
| **Severity** | P2 |

### Problem description

`PlayerRoundStateEvent` exposes `correctedLetters` while domain uses `correctLetters` — contract drift risk.

### Solution proposal

- Rename setter/field to `correctLetters` everywhere (publisher + DTO + OpenAPI/contract if any).
- Coordinate breaking change with frontend.

### Validation strategy

- Contract tests or snapshot of JSON payload.

---

# Phase C — Presence & reconnect (P1)

## C1. Wire WebSocket/session disconnect to `RoomService.handleDisconnect`

| Field | Detail |
|-------|--------|
| **ID** | C1 |
| **Size** | M |
| **Severity** | P1 |

### Problem description

`handleDisconnect(String roomCode, String playerId)` exists but **no component** calls it on TCP/STOMP disconnect.

**Trace**

- Expected: `SessionDisconnectEvent` or `ChannelInterceptor` resolves session attributes (roomCode, playerId) → `handleDisconnect`.
- Actual: disconnect path unused → no `OFFLINE_TEMP`, no deadline, no `PLAYER_DISCONNECTED`.

### Impact analysis

- **Functionality:** Reconnect rules and `ReconnectExpiryScheduler` never trigger from real disconnects.
- **UX:** Players appear online; no resync workflow.

### Solution proposal

- On WebSocket connect (handshake or STOMP CONNECT): store `roomCode` + `playerId` in session attributes (after auth).
- Implement `ApplicationListener<SessionDisconnectEvent>` or equivalent; call `handleDisconnect` with lock-safe service API.

### Validation strategy

- Kill client connection — server logs/state show `OFFLINE_TEMP`, `PLAYER_DISCONNECTED` published, deadline set.
- `ReconnectExpiryScheduler` removes player after grace period.

---

## C2. Reconnect grace period and HTTP error mapping

| Field | Detail |
|-------|--------|
| **ID** | C2 |
| **Size** | S |
| **Severity** | P2 |

### Problem description

- `DisconnectManager` uses **60s**; spec may say **30s**.
- `reconnectPlayer` throws `IllegalStateException` for invalid token / expired window → may map to **500** via generic handler.

### Solution proposal

- Externalize `RECONNECT_GRACE_SECONDS` in config.
- Replace `IllegalStateException` with `BaseBusinessException` subclasses + codes for REST.

### Validation strategy

- REST tests: expired reconnect returns 4xx with stable error code, not 500.

---

## C3. Remove or wire dead code `RoomService.reconnectRoom`

| Field | Detail |
|-------|--------|
| **ID** | C3 |
| **Size** | S |
| **Severity** | P2 |

### Problem description

`reconnectRoom` returns `ReconnectRoomResponse`; controller uses `reconnectPlayer` + `ResyncSnapshot` only.

### Solution proposal

- Delete unused method or expose a deprecated REST endpoint intentionally; avoid duplicate reconnect semantics.

---

# Phase D — Quality, safety, docs (P2)

## D1. STOMP exception handling

| Field | Detail |
|-------|--------|
| **ID** | D1 |
| **Size** | M |
| **Severity** | P2 |

### Problem description

`IllegalArgumentException` from gameplay and `IllegalStateException` from controller may not convert to client-friendly STOMP errors.

### Solution proposal

- `@ControllerAdvice` for REST stays; add `@MessageExceptionHandler` or channel error handler mapping domain exceptions to error frames / user queue.

---

## D2. Reduce `RoomService` god-class (incremental extract)

| Field | Detail |
|-------|--------|
| **ID** | D2 |
| **Size** | L |
| **Severity** | P2 |

### Problem description

`RoomService` mixes locking, scoring, stun, first solver, and publishing.

### Solution proposal

- Extract `GuessOrchestrator` or `GameplayCommandHandler` (pure logic + return “effects” list).
- Keep `RoomService` as thin coordinator + lock boundaries.

---

## D3. Automated tests

| Field | Detail |
|-------|--------|
| **ID** | D3 |
| **Size** | L |
| **Severity** | P2 |

### Problem description

Almost no unit/integration tests for gameplay.

### Solution proposal

- Unit: `RoundService`, `RoundState` transitions, `RoundTimeoutScheduler` guard.
- Integration: `@SpringBootTest` + embedded broker or test WebSocket client — one full match: start → active → guess → timeout → round 2 → finish.

---

## D4. Centralize magic numbers

| Field | Detail |
|-------|--------|
| **ID** | D4 |
| **Size** | S |
| **Severity** | P2 |

### Problem description

Duplicates: first solver bonus in `RoomService` vs `ScoreCalculator`; stun/sudden death seconds scattered.

### Solution proposal

- `@ConfigurationProperties` class `GameRulesProperties` loaded from `application.yml`.

---

# Summary task checklist

| ID | Task | Priority |
|----|------|----------|
| A1 | Fix `isEnglishLetter` | P0 |
| A2 | Fix `buildMaskedWord` | P0 |
| A3 | Fix `RoundTimeoutScheduler` null guard | P1 |
| A4 | Wire countdown → ACTIVE (`startRound` path) | P0 |
| A5 | Learning reveal → COMPLETED → `proceedAfterRound` | P0 |
| A6 | Guesses in `SUDDEN_DEATH` | P1 |
| A7 | HP delta publish order | P2 |
| B1 | Fix `GameEventPublisher` user vs room routing | P1 |
| B2 | Sudden death started broadcast scope | P2 |
| B3 | `correctLetters` naming | P2 |
| C1 | Wire disconnect → `handleDisconnect` | P1 |
| C2 | Grace period config + reconnect exceptions | P2 |
| C3 | Dead `reconnectRoom` cleanup | P2 |
| D1 | STOMP error handling | P2 |
| D2 | Extract guess orchestration | P2 |
| D3 | Test suite | P2 |
| D4 | Centralize constants | P2 |

---

# Suggested implementation order (measurable milestones)

1. **Milestone 1 — Playable guess:** A1, A2, A3, A4  
2. **Milestone 2 — Full round/match flow:** A5, (A6, A7 as needed)  
3. **Milestone 3 — Clients see truth:** B1, B2, B3  
4. **Milestone 4 — Presence:** C1, C2, C3  
5. **Milestone 5 — Hardening:** D1–D4  

---

*Document version: 1.0 — aligned with codebase audit (Synaxis backend).*
