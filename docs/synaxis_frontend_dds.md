# Synaxis Frontend Detailed Design Specification (DDS)

> Version: 1.1  
> Scope: Flutter Frontend (Mobile-first, Web-ready)  
> Audience: Flutter developer who will implement the client without ambiguity  
> Language style: Arabic + technical English terms

---

## 1. Document Purpose

هذا الملف يحدد **Detailed Design Specification (DDS)** للـ Frontend الخاص بمشروع **Synaxis** بحيث لا يحتاج المطور إلى التخمين عند تحويل التصميم إلى كود.

الهدف من هذا الملف:
- تثبيت **Frontend Architecture** بشكل نهائي وواضح.
- تحديد **screen flow** بشكل كامل.
- تحديد **folder structure** على مستوى منخفض.
- تحديد **state management** و**routing** و**networking** و**WebSocket handling**.
- تحديد **DTO mapping** و**event handling matrix**.
- تحديد **UI behavior** لكل شاشة ولكل حالة تشغيل.
- تحديد **manual testing checkpoints** لكل flow أساسي.
- تحديد **design tokens** (ألوان، مسافات، خطوط) و**responsive / a11y** و**عقود REST/WS** لتقليل الغموض التنفيذي.

هذا الـ DDS يفترض الآتي:
- الـ Backend هي **source of truth**.
- الـ Frontend لا تحسب business rules ولا score ولا health ولا round logic من نفسها.
- اللاعب يمتلك **room session واحدة فقط** داخل التطبيق.
- لا يوجد **local persistence** للجلسة عند غلق التطبيق الآن.
- التطبيق **Mobile-first**، مع كتابة الكود بطريقة لا تمنع دعم Web لاحقًا.

---

## 2. Product Goals for Frontend

### 2.1 Primary Goal
بناء Frontend تقدم:
- MVP functional كامل
- UI بسيطة الآن ولكن قابلة للتطوير لاحقًا
- Codebase منظمة وسهلة القراءة
- Architecture واضحة وقابلة للتوسع

### 2.2 Non-Goals for Current Scope
هذه الأمور **ليست ضمن التنفيذ الحالي**:
- Login / Account system
- local persistence عبر cold restart
- chat داخل الغرفة
- invite links / deep links
- notifications
- complex offline mode
- spectator mode

---

## 3. High-Level Product Flow

الرحلة الكاملة للمستخدم ستكون كما يلي:

1. **HomeScreen**
   - زر `Create Room`
   - زر `Join Room`

2. **CreateRoomScreen**
   - إدخال `player name`
   - اختيار settings:
     - `CEFR level`
     - `max players`
     - `total rounds`
     - `round duration`
   - عند submit:
     - call backend create room
     - save room session
     - navigate to `LobbyScreen`

3. **JoinRoomScreen**
   - إدخال `player name`
   - إدخال `room code`
   - عند submit:
     - call backend join room
     - save room session
     - navigate to `LobbyScreen`

4. **LobbyScreen**
   - عرض:
     - room code
     - players list
     - host
     - settings
     - leave button
     - start button للـ host فقط
   - تستقبل room events لحظيًا:
     - player joined
     - player removed
     - host transferred
     - game started
   - عند `GAME_STARTED`:
     - navigate to `CountdownScreen`

5. **CountdownScreen**
   - تعرض countdown قبل بدء الجولة
   - عند `ROUND_STARTED`:
     - navigate to `GameScreen`

6. **GameScreen**
   - تعرض:
     - masked word
     - letter buttons grid
     - score
     - health
     - remaining time
     - round number
     - players list summary
   - تستقبل private player state updates + shared round events

7. **LearningRevealScreen**
   - تعرض:
     - الكلمة
     - المعنى العربي
     - التعريف الإنجليزي
   - زر انتقال إلى round leaderboard

8. **RoundLeaderboardScreen**
   - تعرض الترتيب التراكمي الحالي
   - زر `Next Round` للـ host فقط
   - إذا ضغط الـ host:
     - navigate إلى `CountdownScreen`

9. **FinalLeaderboardScreen**
   - تعرض final ranking
   - عرض أجمل من round leaderboard
   - زر `Leave Room`

---

## 4. Architecture Decisions

### 4.1 UI Composition Strategy
**Decision:** استخدام **عدة شاشات مستقلة** وليس شاشة واحدة كبيرة تتبدل داخليًا.

#### Screens will be separated into:
- Home
- Create Room
- Join Room
- Lobby
- Countdown
- Game
- Learning Reveal
- Round Leaderboard
- Final Leaderboard

#### Rationale
- أوضح في القراءة
- أسهل في الصيانة
- يمنع تضخم الملفات
- أسهل في تعديل UX لاحقًا
- يسهل عزل logic لكل مرحلة

### 4.2 State Management
**Decision:** استخدام **Riverpod**.

#### Why Riverpod?
- منظم وواضح
- مناسب لمشروع سيكبر
- أفضل من `setState` المنتشر
- يسهل فصل state حسب feature
- يسهل اختبار المنطق لاحقًا حتى لو كانت الاختبارات الآن manual

### 4.3 Navigation
**Decision:** استخدام **go_router**.

#### Why go_router?
- التطبيق أصبح متعدد الشاشات والفلو واضح
- أسهل من `Navigator.push` العشوائي
- يسمح بتعريف routes مركزية
- يسهل الانتقال بين screens based on app state

### 4.4 Server Authority
**Decision:** الـ Frontend تعتمد على الـ Backend بالكامل في business rules.

#### Frontend responsibilities
- render UI
- collect input
- send commands
- display state
- handle transitions

#### Frontend does NOT do
- score calculation
- health calculation
- winner detection
- sudden death logic
- reconnect eligibility decisions
- leaderboard ranking logic

### 4.5 Local Persistence
**Decision:** لا يوجد local persistence حاليًا.

#### Consequence
- إذا أغلق المستخدم التطبيق وفتحه من جديد → يبدأ من Home
- لا يتم restore تلقائي للجلسة بعد cold restart
- reconnect موجود داخل عمر الجلسة الحالية فقط

### 4.6 Room Session Policy
**Decision:** اللاعب يملك **room session واحدة فقط**.

#### Consequence
- لا يمكن أن يكون داخل أكثر من room في نفس الوقت
- عند leave/final exit يتم clear كامل للجلسة

---

## 5. Frontend Module Structure (Low-Level)

```text
lib/
  app/
    router/
      app_router.dart
      route_names.dart
    theme/
      app_colors.dart
      app_spacing.dart
      app_text_styles.dart
      app_theme.dart

  core/
    config/
      app_config.dart
    errors/
      app_exception.dart
      error_mapper.dart
    network/
      api_client.dart
      websocket_client.dart
      ws_destinations.dart
    utils/
      json_utils.dart
      logger.dart

  features/
    home/
      presentation/
        screens/
          home_screen.dart

    room/
      data/
        api/
          room_api.dart
        models/
          create_room_request.dart
          create_room_response.dart
          join_room_request.dart
          join_room_response.dart
          player_summary_model.dart
          room_settings_model.dart
          room_session_model.dart
        repositories/
          room_repository.dart
      application/
        controllers/
          room_session_controller.dart
          lobby_controller.dart
        providers/
          room_session_provider.dart
          lobby_provider.dart
        state/
          lobby_state.dart
      presentation/
        screens/
          create_room_screen.dart
          join_room_screen.dart
          lobby_screen.dart
        widgets/
          player_tile.dart
          room_settings_card.dart
          start_game_button.dart

    countdown/
      application/
        controllers/
          countdown_controller.dart
        providers/
          countdown_provider.dart
        state/
          countdown_state.dart
      presentation/
        screens/
          countdown_screen.dart
        widgets/
          countdown_circle.dart

    game/
      data/
        models/
          guess_letter_command.dart
          player_round_state_model.dart
          letter_guess_result_event_model.dart
          player_round_state_event_model.dart
      application/
        controllers/
          game_controller.dart
        providers/
          game_provider.dart
        state/
          game_state.dart
      presentation/
        screens/
          game_screen.dart
        widgets/
          masked_word_widget.dart
          letter_grid_widget.dart
          player_status_panel.dart
          round_timer_widget.dart
          score_health_bar.dart

    learning/
      data/
        models/
          learning_reveal_payload_model.dart
      application/
        controllers/
          learning_controller.dart
        providers/
          learning_provider.dart
        state/
          learning_state.dart
      presentation/
        screens/
          learning_reveal_screen.dart
        widgets/
          learning_card.dart

    leaderboard/
      data/
        models/
          leaderboard_entry_model.dart
          round_leaderboard_payload_model.dart
          final_leaderboard_payload_model.dart
      application/
        controllers/
          leaderboard_controller.dart
        providers/
          leaderboard_provider.dart
        state/
          leaderboard_state.dart
      presentation/
        screens/
          round_leaderboard_screen.dart
          final_leaderboard_screen.dart
        widgets/
          leaderboard_list.dart

    reconnect/
      data/
        models/
          resync_snapshot_model.dart
      application/
        controllers/
          reconnect_controller.dart
        providers/
          reconnect_provider.dart
        state/
          reconnect_state.dart

  shared/
    widgets/
      app_button.dart
      app_loading_overlay.dart
      app_error_banner.dart
      section_title.dart

  main.dart
```

---

## 6. Responsibilities by Layer

### 6.1 `data/`
Contains:
- raw DTOs
- API services
- repositories for backend communication

### 6.2 `application/`
Contains:
- Riverpod controllers/notifiers
- providers
- feature states
- orchestration between services and UI

### 6.3 `presentation/`
Contains:
- screens
- widgets
- rendering logic only

### 6.4 `core/`
Contains:
- shared infra
- app-wide networking
- app config
- errors
- utility helpers

---

## 7. Routing Design

### 7.1 Route List

| Route | Screen | Notes |
|---|---|---|
| `/` | HomeScreen | initial screen |
| `/create-room` | CreateRoomScreen | room creation form |
| `/join-room` | JoinRoomScreen | join form |
| `/lobby` | LobbyScreen | requires active room session |
| `/countdown` | CountdownScreen | after game starts |
| `/game` | GameScreen | active round UI |
| `/learning` | LearningRevealScreen | after round end |
| `/round-leaderboard` | RoundLeaderboardScreen | after learning reveal |
| `/final-leaderboard` | FinalLeaderboardScreen | end of match |

### 7.2 Navigation Rules

#### Home → Create Room
- on tap `Create Room`
- `context.go('/create-room')`

#### Home → Join Room
- on tap `Join Room`
- `context.go('/join-room')`

#### Create Room success
- save session
- connect websocket
- `context.go('/lobby')`

#### Join Room success
- save session
- connect websocket
- `context.go('/lobby')`

#### Lobby receives `GAME_STARTED`
- update lobby state
- `context.go('/countdown')`

#### Countdown receives `ROUND_STARTED`
- `context.go('/game')`

#### Game receives `LEARNING_REVEAL`
- **GameController** parses event, writes `LearningState`, sets `GameState.learningRevealActive` (§11.7), then performs **sole** navigation: `context.go('/learning')` (§7.3)

#### Learning button press
- Call **`LeaderboardController.navigateAfterLearningTap(...)`** (§17.5): if leaderboard payload already buffered → `go` immediately; else loading until `ROUND_LEADERBOARD` / `FINAL_LEADERBOARD` arrives; choose `/round-leaderboard` vs `/final-leaderboard` from **`LeaderboardState`** (backend-driven), not from round number guessed in UI

#### Round Leaderboard host presses Next Round
- send STOMP command
- on `ROUND_COUNTDOWN_STARTED` → `context.go('/countdown')`

#### Final Leaderboard Leave button
- **always** call `POST /api/room/{roomCode}/leave` (see §15.9) — do not skip on the client
- clear session
- disconnect websocket
- `context.go('/')`

### 7.3 Navigation Decision Matrix (authoritative)

Use this table to resolve ambiguous transitions. **Single navigation call-site rule:** for `LEARNING_REVEAL`, only **GameController** (or a dedicated `NavigationCoordinator` it invokes) may call `context.go('/learning')` after pushing the parsed payload into `LearningController` / `LearningState` (§12.4–12.5).

| From | Condition | Route |
|---|---|---|
| Lobby | `GAME_STARTED` received | `/countdown` |
| Countdown | `ROUND_STARTED` received | `/game` |
| Game | `LEARNING_REVEAL` received, payload stored | `/learning` |
| Learning | User taps **Go to Leaderboard** | see below |

**Learning → Round vs Final leaderboard**

| Condition | Route | Notes |
|---|---|---|
| Match not finished (more rounds remain after this round) | `/round-leaderboard` | After user taps **Go to Leaderboard** on Learning screen (§15.7). |
| Last round completed | `/final-leaderboard` | Same — use payload from `FINAL_LEADERBOARD` when `isFinal` / last round per backend; **never** infer from UI alone. |

**Buffered leaderboard (authoritative):** `ROUND_LEADERBOARD` / `FINAL_LEADERBOARD` may arrive **while still on `/learning`**. **LeaderboardController** always **stores** payload in `LeaderboardState`. **Do not** call `context.go` to leaderboard routes from these events **until** the user taps **Go to Leaderboard** on LearningRevealScreen — then navigate immediately if payload already buffered; otherwise keep **loading** until the event arrives (§15.7).  
Exception: if a future product change **auto-skips** Learning, document it separately; MVP requires the tap.

**Recommended implementation:** `LeaderboardController` updates state on events; **Learning screen** (or a small `LeaderboardNavigationCoordinator`) performs **one** `go()` after tap + payload ready.

**Concurrent events:** if `ROUND_STARTED` arrives while still on Lobby, apply **§28.2** (event ordering).

---

## 8. Theme and Design System

### 8.1 Design Principles
- simple now
- easy to beautify later
- event/state colors must be explicit
- layout must prioritize readability
- all visual values below are **defaults for MVP**; adjust in `app_*` files only, not in feature widgets

### 8.2 Semantic color roles → design tokens

Map **meaning** to **token name** and **default hex** (sRGB). Use tokens in code (`AppColors.primary`), not raw hex in widgets.

| Meaning | Token | Default hex | Notes |
|---|---|---|---|
| Primary / brand | `colorPrimary` | `#1E88E5` | buttons, links, focus |
| Primary variant (pressed) | `colorPrimaryDark` | `#1565C0` | pressed states |
| Surface / card | `colorSurface` | `#FFFFFF` | cards on light background |
| Background | `colorBackground` | `#F5F5F5` | screen scaffold |
| On-primary text | `colorOnPrimary` | `#FFFFFF` | text on primary buttons |
| On-surface text | `colorOnSurface` | `#212121` | body text |
| Muted text | `colorOnSurfaceVariant` | `#757575` | captions, hints |
| Divider / border | `colorOutline` | `#E0E0E0` | list separators |
| Success / correct / solved | `colorSuccess` | `#2E7D32` | correct letter, solved player border |
| Error / wrong / danger | `colorError` | `#C62828` | wrong letter, errors |
| Warning / countdown / sudden death | `colorWarning` | `#F9A825` | timer low, sudden death banner |

**Contrast (a11y):** default palette targets **≥ 4.5:1** for normal text on `colorBackground` / `colorSurface`; primary button uses `colorOnPrimary` on `colorPrimary`. If changing hex, re-check contrast.

### 8.3 Spacing & layout tokens

| Token | Value (logical px) | Usage |
|---|---:|---|
| `spaceXs` | 4 | tight inline padding |
| `spaceSm` | 8 | icon gaps, small padding |
| `spaceMd` | 16 | default screen horizontal padding |
| `spaceLg` | 24 | section gaps |
| `spaceXl` | 32 | major vertical separation |

- **Screen horizontal padding:** `spaceMd` minimum; max content width on **web** see §8.10.
- **Min tap target:** **48×48** logical px for letter buttons and primary actions (Material guideline).

### 8.4 Typography scale

| Token | Size (sp) | Weight | Usage |
|---|---:|---|---|
| `textDisplay` | 34 | w600 | countdown number, hero masked word |
| `textTitle` | 22 | w600 | screen titles |
| `textBody` | 16 | w400 | body, forms |
| `textLabel` | 14 | w500 | buttons, labels |
| `textCaption` | 12 | w400 | hints, metadata |

- **Arabic + English:** use one family that supports both (e.g. system UI on mobile, or bundled `NotoSans` / `IBM Plex Sans Arabic` on web if unified look is required later). **Arabic meaning** on Learning screen: direction `TextDirection.rtl`; **English definition:** `ltr` inside a `Directionality` wrapper if mixed in one block.

### 8.5 Radius & elevation

| Token | Value | Usage |
|---|---|---|
| `radiusSm` | 8 | inputs, small chips |
| `radiusMd` | 12 | cards, dialogs |
| `radiusLg` | 16 | large panels |
| `elevationLow` | 1–2 | cards |
| `elevationModal` | 8 | overlays |

### 8.6 Responsive layout (mobile-first, web-ready)

| Rule | Specification |
|---|---|
| **Breakpoints (Flutter / `LayoutBuilder`)** | `compact`: under 600dp width; `medium`: 600–900; `expanded`: over 900. |
| **Web max content width** | Center content; **max width 560px** for “phone column” layouts on large screens; optional **max 720px** for leaderboard lists. |
| **Safe areas** | Respect `SafeArea` / notch on all screens; never place CTAs in unsafe zones. |
| **Letter grid (`LetterGridWidget`)** | On **narrow** width: use **5–6 columns** of letter buttons with `Wrap` + `spacing: spaceSm`; ensure vertical scroll if needed. On **wide** web, may use single row or two rows — **must remain usable with keyboard** on web (focus order left-to-right). |
| **Landscape** | Prefer vertical scroll over horizontal squeeze; timer + score remain visible in header. |

### 8.7 Accessibility (a11y)

- **Semantics:** `Semantics` / `MergeSemantics` on letter buttons with label e.g. “Letter A”; disabled state announces “Letter A, disabled, stunned” when applicable.
- **Focus:** web: ensure **tab order** matches visual order; primary actions reachable without trap.
- **Motion:** respect `MediaQuery.disableAnimations` where trivial; countdown may remain animated (essential feedback).
- **Touch targets:** §8.3 min 48dp.

### 8.8 Assets (icons & images)

| Asset ID | Usage | Format | Notes |
|---|---|---|---|
| `app_icon` | (future) launcher | png / adaptive | out of MVP scope |
| `ic_host_badge` | host marker on player tile | SVG or icon font | optional MVP: use `Icon(Icons.star)` with token color until asset exists |

**Naming:** `snake_case`, prefix feature: `game_`, `lobby_`, `leaderboard_`. Place under `assets/images/` with declaration in `pubspec.yaml`.

### 8.9 Required Theme Files
- `app_colors.dart` — exports tokens in §8.2
- `app_spacing.dart` — §8.3
- `app_text_styles.dart` — §8.4
- `app_theme.dart` — `ThemeData` wiring + `ColorScheme.fromSeed` or manual mapping

### 8.10 Widget Rules
- no hardcoded spacing inside screens; use spacing constants
- no hardcoded colors outside design system except temporary debug
- buttons must reuse `AppButton`
- loading overlays must reuse `AppLoadingOverlay`

---

## 9. Networking Design

### 9.1 REST Base Configuration

#### `AppConfig`
```dart
class AppConfig {
  static const String baseUrl = 'http://10.0.2.2:8080';
  static const String wsUrl = 'ws://10.0.2.2:8080/ws';
}
```

> If physical device is used later, replace `10.0.2.2` with machine LAN IP.

#### Web / different environments
- Use **`AppConfig`** as the **single place** for `baseUrl` / `wsUrl` per flavor (dev, staging, prod).
- **Browser WebSocket:** same host as REST unless backend documents otherwise; ensure backend **CORS** and **WebSocket origin** allow the web dev origin.
- **Mixed content:** HTTPS pages require `wss://`; keep dev URLs consistent with deployment docs.

### 9.2 API Client
`ApiClient` wraps `Dio` and provides a single `dio` instance.

#### Requirements
- 10s connect timeout
- 10s receive timeout
- map backend error payloads to readable UI messages later

#### Retry policy (REST)
- **Idempotent-safe reads / reconnect:** at most **2 retries** with exponential backoff (e.g. 300ms, 800ms) for **transient** failures (5xx, timeout, connection reset).
- **Mutations** (`POST` create/join/leave/guess if ever REST): **no automatic retry** unless backend documents idempotency keys; user may retry via button.
- **User feedback:** show SnackBar on final failure after retries (§19).

### 9.3 WebSocket Client
`WebSocketClient` wraps STOMP client and provides:
- `connect`
- `subscribe`
- `sendJson`
- `disconnect`

### 9.4 Destination Constants
Create file:
```text
lib/core/network/ws_destinations.dart
```

```dart
class WsDestinations {
  static String roomTopic(String roomCode) => '/topic/room/$roomCode';
  static String privateGameQueue() => '/user/queue/game';

  static String startGameCommand() => '/app/game.start';
  static String guessLetterCommand() => '/app/game.guess-letter';
  static String nextRoundCommand() => '/app/round.next';
}
```

> If backend topic/command names differ, this file is the **single source of truth** to update.

---

## 10. Backend Contract Mapping

### 10.1 REST Endpoints Used by Frontend

#### Create Room
- Method: `POST`
- Path: `/api/room`
- Request body:
```json
{
  "playerName": "Ahmad",
  "cefrLevel": "A1",
  "maxPlayers": 2,
  "totalRounds": 3,
  "roundDurationSeconds": 30
}
```

#### Join Room
- Method: `POST`
- Path: `/api/room/{roomCode}/join`
- Request body:
```json
{
  "playerName": "Ahmad"
}
```

#### Reconnect
- Method: `POST`
- Path: `/api/room/{roomCode}/reconnect`
- Request body:
```json
{
  "playerId": "p_001",
  "playerToken": "token_xyz"
}
```

#### Leave Room (mandatory on final exit)
- Method: `POST` (or `DELETE` if backend standardizes — **follow OpenAPI**)
- Path: `/api/room/{roomCode}/leave`
- Request body (illustrative; align with backend):
```json
{
  "playerId": "p_001",
  "playerToken": "token_xyz"
}
```
- **Rule:** call **always** when user leaves lobby (optional but recommended) and **always** when leaving from **FinalLeaderboardScreen** before clearing session (§15.9).

### 10.2 WebSocket Commands Used by Frontend

#### Start Game
Destination:
```text
/app/game.start
```
Body:
```json
{
  "roomCode": "ABC123",
  "playerId": "p_001",
  "playerToken": "token_xyz"
}
```

#### Guess Letter
Destination:
```text
/app/game.guess-letter
```
Body:
```json
{
  "roomCode": "ABC123",
  "playerId": "p_001",
  "playerToken": "token_xyz",
  "letter": "p"
}
```

#### Next Round
Destination:
```text
/app/round.next
```
Body:
```json
{
  "roomCode": "ABC123",
  "playerId": "p_001",
  "playerToken": "token_xyz"
}
```

### 10.3 REST response shapes (illustrative)

Backend is **source of truth**; field names must match **OpenAPI / actual JSON**. Below shapes minimize guesswork during implementation.

#### Create Room — success (`2xx`)
```json
{
  "roomCode": "ABC123",
  "player": {
    "playerId": "p_001",
    "playerName": "Ahmad",
    "playerToken": "token_xyz",
    "isHost": true
  },
  "players": [
    { "playerId": "p_001", "playerName": "Ahmad", "isHost": true }
  ],
  "settings": {
    "cefrLevel": "A1",
    "maxPlayers": 2,
    "totalRounds": 3,
    "roundDurationSeconds": 30
  }
}
```

#### Join Room — success (`2xx`)
Same top-level shape as create where applicable (`roomCode`, `player`, `players`, `settings`).

#### Reconnect — success (`2xx`)
Returns **`ResyncSnapshotModel`**-compatible payload or a wrapper `{ "snapshot": { ... } }` — **confirm with backend** and map in repository.

#### Error response (typical)
```json
{
  "error": "ROOM_FULL",
  "message": "Room has reached max players"
}
```
Map `error` / `message` via `error_mapper.dart` (§19).

### 10.4 Request validation (frontend + alignment)

| Field | Rule (MVP) | Notes |
|---|---|---|
| `playerName` | trim; length **1–32** chars | show inline error if empty |
| `roomCode` | trim; **alphanumeric** per backend (e.g. 6 chars) | validate before API |
| `cefrLevel` | one of **`A1`–`C2`** (or backend enum) | dropdown only |
| `maxPlayers` | **2–8** (adjust if backend differs) | |
| `totalRounds` | **1–20** | |
| `roundDurationSeconds` | **15–120** step 5 or 10 | |

Backend may enforce stricter rules; surface returned validation in SnackBar / field errors.

### 10.5 WebSocket message envelope & event payloads

#### Envelope (STOMP / application JSON)

Each inbound frame body is JSON. **Minimum contract:**

```json
{
  "type": "LEARNING_REVEAL",
  "payload": { }
}
```

If backend uses **flat** JSON without `type`/`payload`, the **mapper layer** must normalize to `{ type, payload }` once at subscription edge.

#### Examples — `payload` by `type` (illustrative)

**`LEARNING_REVEAL`**
```json
{
  "roundNumber": 2,
  "word": "example",
  "arabicMeaning": "معنى",
  "englishDefinition": "a thing characteristic of its kind"
}
```

**`ROUND_LEADERBOARD`**
```json
{
  "entries": [
    {
      "playerId": "p_001",
      "playerName": "Ahmad",
      "score": 120,
      "health": 80,
      "totalSolveTimeMs": 4500,
      "rank": 1
    }
  ],
  "isFinalRound": false
}
```

**`FINAL_LEADERBOARD`**
```json
{
  "entries": [ { "playerId": "p_001", "rank": 1, "score": 300, "health": 60, "totalSolveTimeMs": 12000, "playerName": "Ahmad" } ]
}
```

**`PLAYER_ROUND_STATE`** (private queue)
```json
{
  "roomCode": "ABC123",
  "roundNumber": 1,
  "maskedWord": "_ _ _ _ _",
  "guessedLetters": ["a", "e"],
  "correctLetters": ["a", "e"],
  "wrongLetters": ["x"],
  "currentScore": 10,
  "currentHealth": 80,
  "solved": false,
  "stunned": false,
  "stunnedUntil": null
}
```

**`LETTER_GUESS_RESULT`** (private queue)
```json
{
  "letter": "p",
  "result": "CORRECT",
  "scoreDelta": 5,
  "healthDelta": 0
}
```

**`RESYNC_SNAPSHOT`** (private queue)  
Payload fields align with §11.11; ensure `roomStatus`, `matchStatus`, `roundStatus` use **backend enum strings** documented in §21.5.

---

## 11. Frontend Data Models

### 11.1 `PlayerSessionModel`
Fields:
- `playerId`
- `playerName`
- `playerToken`
- `isHost`

### 11.2 `PlayerSummaryModel`
Fields:
- `playerId`
- `playerName`
- `isHost`

### 11.3 `RoomSettingsModel`
Fields:
- `cefrLevel`
- `maxPlayers`
- `totalRounds`
- `roundDurationSeconds`

### 11.4 `RoomSessionModel`
Fields:
- `roomCode`
- `player` (`PlayerSessionModel`)
- `players` (`List<PlayerSummaryModel>`)
- `settings` (`RoomSettingsModel?`) optional initially if not always returned

### 11.5 `LobbyState`
Fields:
- `roomCode`
- `players`
- `settings`
- `gameStarted`
- `loading`
- `errorMessage`

### 11.6 `CountdownState`
Fields:
- `roundNumber`
- `remainingSeconds`

### 11.7 `GameState`
Fields:
- `roomCode`
- `roundNumber`
- `remainingSeconds`
- `maskedWord`
- `guessedLetters`
- `correctLetters`
- `wrongLetters`
- `currentScore`
- `currentHealth`
- `scoreDelta`
- `healthDelta`
- `penaltyScoreDelta`
- `solved`
- `stunned`
- `stunnedUntil`
- `learningRevealActive` — `true` from `LEARNING_REVEAL` until leaving `GameScreen` / round phase reset; used to disable input (§15.6)
- `roundPhase` (optional enum) — e.g. `ACTIVE`, `SUDDEN_DEATH`, `TIMEOUT`, `ENDED` if backend exposes; else derive from events only
- `players` (player summary list with visual flags)

### 11.8 `LearningState`
Fields:
- `roundNumber`
- `word`
- `arabicMeaning`
- `englishDefinition`

### 11.9 `LeaderboardEntryModel`
Fields:
- `playerId`
- `playerName`
- `score`
- `health`
- `totalSolveTimeMs`
- `rank`

### 11.10 `LeaderboardState`
Fields:
- `roundEntries`
- `finalEntries`
- `isFinal`

### 11.11 `ResyncSnapshotModel`
Fields must mirror backend resync payload:
- `roomCode`
- `playerId`
- `playerName`
- `isHost`
- `roomStatus`
- `playerStatus`
- `connectedPlayerIds`
- `matchStatus`
- `currentRoundNumber`
- `roundStatus`
- `maskedWord`
- `guessedLetters`
- `correctLetters`
- `wrongLetters`
- `currentScore`
- `currentHealth`
- `stunned`
- `stunnedUntil`

---

## 12. State Ownership and Controllers

### 12.1 `RoomSessionController`
Owns:
- active room session
- session lifecycle
- websocket connect/disconnect lifecycle

Responsibilities:
- save create/join response into session state
- clear session on leave/final exit
- expose current roomCode/player identity

### 12.2 `LobbyController`
Owns:
- players list in lobby
- settings display
- gameStarted flag

Responsibilities:
- initialize lobby state from REST snapshot
- handle room shared events:
  - `PLAYER_JOINED`
  - `PLAYER_REMOVED_AFTER_DISCONNECT`
  - `HOST_TRANSFERRED`
  - `GAME_STARTED`
- trigger navigation to countdown when game starts

### 12.3 `CountdownController`
Owns:
- countdown state

Responsibilities:
- receive `ROUND_COUNTDOWN_STARTED`
- update countdown value
- when `ROUND_STARTED` arrives → trigger game navigation

### 12.4 `GameController`
Owns:
- private player game state
- shared round state needed for screen rendering

Responsibilities:
- send `GuessLetterCommand`
- receive private events:
  - `LETTER_GUESS_RESULT`
  - `PLAYER_ROUND_STATE`
  - `PLAYER_STUNNED`
  - `PLAYER_RECOVERED`
  - `RESYNC_SNAPSHOT`
- receive shared events:
  - `PLAYER_SOLVED_WORD`
  - `SUDDEN_DEATH_STARTED`
  - `ROUND_TIMEOUT`
  - `SUDDEN_DEATH_ENDED`
  - `LEARNING_REVEAL`
- update `GameState`
- on `LEARNING_REVEAL`: parse payload → **`LearningController.setFromPayload(...)`** (or equivalent) → set `learningRevealActive` → **single navigation** `context.go('/learning')` (§7.3). **LearningController does not subscribe to WS for this event** in MVP.

### 12.5 `LearningController`
Owns learning screen data (`LearningState`). **Does not** own WebSocket subscription for `LEARNING_REVEAL` in MVP; receives data from `GameController` before navigation.

### 12.6 `LeaderboardController`
Owns both:
- round leaderboard
- final leaderboard

Responsibilities:
- receive `ROUND_LEADERBOARD` and `FINAL_LEADERBOARD` and **buffer** into `LeaderboardState` (events may arrive while UI is still on `/learning`)
- **do not** navigate to leaderboard routes on event alone in MVP — navigation follows **Learning screen button** + buffered payload (§7.3)
- expose host-only `Next Round` button visibility on round leaderboard screen

### 12.7 `ReconnectController`
Responsibilities:
- call reconnect REST endpoint if session still alive in current app run
- handle `PLAYER_RECONNECTED`
- apply `RESYNC_SNAPSHOT` to correct feature state
- redirect to proper screen based on snapshot state

---

## 13. Realtime Event Handling Matrix

| Event Type | Channel | Owner | UI Effect |
|---|---|---|---|
| `PLAYER_JOINED` | room topic | LobbyController | add player to lobby list |
| `PLAYER_REMOVED_AFTER_DISCONNECT` | room topic | LobbyController / GameController | remove player from list |
| `HOST_TRANSFERRED` | room topic | LobbyController / GameController | update host indicator |
| `GAME_STARTED` | room topic | LobbyController | navigate to CountdownScreen |
| `ROUND_COUNTDOWN_STARTED` | room topic | CountdownController | show countdown value |
| `ROUND_STARTED` | room topic | CountdownController / GameController | navigate to GameScreen |
| `LETTER_GUESS_RESULT` | private queue | GameController | show immediate result feedback |
| `PLAYER_ROUND_STATE` | private queue | GameController | replace current player state |
| `PLAYER_STUNNED` | private queue | GameController | disable input and show stun state |
| `PLAYER_RECOVERED` | private queue | GameController | enable input and update health |
| `PLAYER_SOLVED_WORD` | room topic | GameController | mark solved player in players list |
| `SUDDEN_DEATH_STARTED` | room topic | GameController | show warning style / color |
| `ROUND_TIMEOUT` | room topic | GameController | stop input / prepare transition |
| `SUDDEN_DEATH_ENDED` | room topic | GameController | prepare learning transition |
| `LEARNING_REVEAL` | room topic | GameController → LearningController (hydrate) → **router** | update `GameState`, store `LearningState`, **navigate once** to LearningRevealScreen |
| `ROUND_LEADERBOARD` | room topic | LeaderboardController | **buffer** entries; navigate only after Learning **Go to Leaderboard** tap (§7.3) |
| `FINAL_LEADERBOARD` | room topic | LeaderboardController | same; route `/final-leaderboard` when payload is final |
| `PLAYER_DISCONNECTED` | room topic | LobbyController / GameController | mark player temporarily offline |
| `PLAYER_RECONNECTED` | room topic | LobbyController / GameController | mark player back online |
| `RESYNC_SNAPSHOT` | private queue | ReconnectController / GameController | restore state and navigate accordingly |

---

## 14. WebSocket Lifecycle Design

### 14.1 Connection Ownership
A single `WebSocketClient` instance is owned by `RoomSessionController` for the active room session.

### 14.2 Connect Timing
Connect after successful:
- create room
- join room

### 14.3 Subscriptions
Immediately after connection, subscribe to:
- room topic: `WsDestinations.roomTopic(roomCode)`
- private queue: `WsDestinations.privateGameQueue()`

### 14.4 Disconnect Timing
Disconnect when:
- user leaves room
- user exits final leaderboard via leave room action
- session is cleared

### 14.5 No Cold-Restart Restore
If app is killed and reopened:
- no auto reconnect
- start from HomeScreen

---

## 15. Screen Specifications (Low-Level)

### 15.0 Cross-cutting UI states (loading, empty, blocking)

| Screen / flow | Loading | Empty / edge | Blocking |
|---|---|---|---|
| Home | — | — | — |
| Create / Join | **Full-screen** `AppLoadingOverlay` or inline **disabled CTA** during submit | — | prevent double submit |
| Lobby | optional skeleton for player list on first paint | “No other players yet” if solo | — |
| Countdown | show placeholder “…” until first `ROUND_COUNTDOWN_STARTED` value | — | — |
| Game | subtle progress on letter tap optional | — | overlay when stunned / round not active |
| Learning | — | — | button shows **loading** if user taps before leaderboard event (§7.3) |
| Round / Final leaderboard | **loading** until payload; show `AppErrorBanner` if event missing after timeout (e.g. 10s) | “No entries” if backend sends empty | — |
| Final exit | `AppLoadingOverlay` while **leave** REST in flight | — | disable Leave to prevent double call |

**Snackbar SLA (manual QA):** on REST failure, user-visible feedback within **2s** of response; no silent failures.

## 15.1 HomeScreen
### UI
- app title
- `Create Room` button
- `Join Room` button

### Actions
- `Create Room` → navigate to CreateRoomScreen
- `Join Room` → navigate to JoinRoomScreen

### File
`features/home/presentation/screens/home_screen.dart`

---

## 15.2 CreateRoomScreen
### Inputs
- player name
- CEFR level dropdown
- max players dropdown
- total rounds dropdown
- round duration dropdown

### Primary CTA
- `Create Room`

### Validation
- player name not empty
- settings all selected

### Submit Flow
1. call create room REST API
2. parse response
3. create `RoomSessionModel`
4. save session
5. init lobby state from response
6. connect websocket
7. navigate to `/lobby`

### File
`features/room/presentation/screens/create_room_screen.dart`

---

## 15.3 JoinRoomScreen
### Inputs
- player name
- room code

### Primary CTA
- `Join Room`

### Submit Flow
1. call join room REST API
2. parse response
3. create `RoomSessionModel`
4. save session
5. init lobby state from response
6. connect websocket
7. navigate to `/lobby`

### File
`features/room/presentation/screens/join_room_screen.dart`

---

## 15.4 LobbyScreen
### Must Display
- room code
- current player name
- host status
- room settings
- players list
- `Leave Room` button
- `Start Game` button for host only

### Realtime Behavior
Must update players list on:
- `PLAYER_JOINED`
- `PLAYER_REMOVED_AFTER_DISCONNECT`
- `HOST_TRANSFERRED`

### Start Game Behavior
On host click:
- send STOMP command `/app/game.start`
- do not navigate immediately
- wait for `GAME_STARTED` event
- on event → navigate to `/countdown`

### File
`features/room/presentation/screens/lobby_screen.dart`

---

## 15.5 CountdownScreen
### Must Display
- round number
- big countdown number / visual indicator

### Behavior
- enter screen on `GAME_STARTED`
- update countdown on `ROUND_COUNTDOWN_STARTED`
- move to `GameScreen` on `ROUND_STARTED`

### File
`features/countdown/presentation/screens/countdown_screen.dart`

---

## 15.6 GameScreen
### Must Display
- round number
- remaining time
- current score
- current health
- masked word
- letters grid (A-Z buttons)
- players list summary

### Letter Grid Rules
Each button has one of these states:
- normal
- correct (green)
- wrong (red)
- disabled

### Button Disable Rules
Disable all input when:
- stunned = true
- round not ACTIVE (use `roundPhase` / backend-derived flags when available)
- `learningRevealActive` = true (§11.7) — set when `LEARNING_REVEAL` received until navigation completes
- final leaderboard flow active (e.g. after `FINAL_LEADERBOARD` or when `LeaderboardState.isFinal` and on that screen)

### Player List Visual Rule
If a player solved the word:
- show green border/highlight on that player tile

### On Letter Tap
1. send `GuessLetterCommand`
2. wait for backend result
3. update full state from events

### File
`features/game/presentation/screens/game_screen.dart`

---

## 15.7 LearningRevealScreen
### Must Display
- word
- arabic meaning
- english definition
- button: `Go to Leaderboard`

### Button behavior
- On tap: set **loading** on button; wait for **`ROUND_LEADERBOARD`** or **`FINAL_LEADERBOARD`** (§7.3).
- Navigate when the corresponding event arrives and `LeaderboardState` is populated; **do not** navigate on timer alone except **error path** (show SnackBar + clear loading after §15.0 timeout).

### File
`features/learning/presentation/screens/learning_reveal_screen.dart`

---

## 15.8 RoundLeaderboardScreen
### Must Display
- cumulative ranking
- score
- health
- total solve time
- host-only `Next Round` button

### On Host Click
- send STOMP command `/app/round.next`
- wait for `ROUND_COUNTDOWN_STARTED`
- navigate to countdown screen

### File
`features/leaderboard/presentation/screens/round_leaderboard_screen.dart`

---

## 15.9 FinalLeaderboardScreen
### Must Display
- final ranking
- more polished visual treatment than round leaderboard
- `Leave Room` button

### Leave Room Behavior
1. Call **`leaveRoom`** REST (**mandatory** — §10.1) with `playerId` + `playerToken`; await completion or failure.
2. On success **or** non-recoverable 4xx (e.g. room already gone): **clear** all frontend session and state.
3. `disconnectRealtime()` on `RoomSessionController`.
4. `context.go('/')`.
5. On transient network failure: show SnackBar; allow **retry** Leave; do not navigate until policy in §19 is satisfied.

> **Lobby “Leave”:** same `leaveRoom` call recommended for consistency; if backend allows implicit leave on disconnect only, still prefer explicit leave when user taps Leave.

### File
`features/leaderboard/presentation/screens/final_leaderboard_screen.dart`

---

## 16. Game Screen Component Layout

### 16.1 Required Widget Composition
Inside `GameScreen`, build UI in this order:

1. `RoundHeaderWidget`
   - round number
   - timer
   - game phase badge if needed

2. `PlayerMetricsWidget`
   - score
   - health
   - stun status if active

3. `MaskedWordWidget`
   - centered
   - large typography
   - current player private masked word only

4. `PlayersSummaryListWidget`
   - compact player tiles
   - green border on solved player
   - host marker if needed

5. `LetterGridWidget`
   - 26 buttons
   - color-coded states
   - disabled according to game state

### 16.2 Widget Rules
- `MaskedWordWidget` must not derive state locally; it renders state from provider only.
- `LetterGridWidget` must not guess correctness locally; it only reflects state from provider.
- `PlayersSummaryListWidget` must only show allowed shared indicators, not private progress.

---

## 17. Feature Controllers — Required Public API

### 17.1 `RoomSessionController`
Required methods:
- `setSession(RoomSessionModel session)`
- `clearSession()`
- `connectRealtime()`
- `disconnectRealtime()`

### 17.2 `LobbyController`
Required methods:
- `initializeFromSession(RoomSessionModel session)`
- `handlePlayerJoined(...)`
- `handlePlayerRemoved(...)`
- `handleHostTransferred(...)`
- `markGameStarted()`

### 17.3 `GameController`
Required methods:
- `initializeFromRoundStart(...)`
- `sendGuessLetter(String letter)`
- `handleLetterGuessResult(...)`
- `handlePlayerRoundState(...)`
- `handlePlayerStunned(...)`
- `handlePlayerRecovered(...)`
- `handlePlayerSolvedWord(...)`
- `handleSuddenDeathStarted(...)`
- `handleRoundTimeout(...)`
- `handleSuddenDeathEnded(...)`
- `handleLearningReveal(...)` — parse payload, hydrate learning state, navigate to `/learning`
- `applyResyncSnapshot(...)`

### 17.4 `LearningController`
Required methods:
- `setFromPayload(...)` — called by `GameController` when `LEARNING_REVEAL` arrives; idempotent if same round

### 17.5 `LeaderboardController`
Required methods:
- `handleRoundLeaderboard(...)` — update buffered state
- `handleFinalLeaderboard(...)` — update buffered state
- `navigateAfterLearningTap(Router router)` — called from Learning screen when user taps **Go to Leaderboard**; chooses `/round-leaderboard` vs `/final-leaderboard` from buffered `LeaderboardState`

### 17.6 `ReconnectController`
Required methods:
- `attemptReconnect(...)`
- `applyResyncSnapshot(...)`
- `redirectToProperScreen(...)`

---

## 18. Repository Interfaces

### 18.1 `RoomRepository`
Responsibilities:
- wrap REST API usage
- expose methods:
  - `createRoom(CreateRoomRequest)`
  - `joinRoom(JoinRoomRequest)`
  - `reconnect(...)`
  - `leaveRoom(...)`

### 18.2 `RealtimeRoomRepository`
Responsibilities:
- wrap websocket send operations
- expose methods:
  - `startGame(...)`
  - `guessLetter(...)`
  - `nextRound(...)`

---

## 19. Error Handling Rules

### 19.1 REST Errors
All REST errors must be mapped through a central mapper.

#### Initial MVP behavior
- show `SnackBar` for request failure
- keep controller state consistent
- do not navigate on failure

### 19.2 WebSocket Errors
If STOMP/websocket errors occur:
- log raw error in debug mode
- show non-blocking UI banner if relevant
- do not crash current screen

### 19.3 Validation Errors
- create/join forms validate locally first
- backend validation errors still shown if returned

---

## 20. Session Rules

### 20.1 Session Fields Stored In Memory Only
- roomCode
- playerId
- playerName
- playerToken
- isHost

### 20.2 When Session Is Cleared
- leave room
- final exit from final leaderboard
- app cold restart

---

## 21. Reconnect Rules (Frontend)

### 21.1 Scope
Reconnect only applies while app runtime is still alive or session context still exists.

### 21.2 No Cold Restart Restore
If app opens from scratch:
- do not restore session automatically
- always start from HomeScreen

### 21.3 Reconnect Within Current App Runtime
If websocket connection drops but app still has session in memory:
- `ReconnectController` may call reconnect REST endpoint
- apply `RESYNC_SNAPSHOT`
- redirect to proper screen based on snapshot

### 21.4 Redirect Rules From `RESYNC_SNAPSHOT`

| Snapshot State | Screen |
|---|---|
| room waiting / no match | LobbyScreen |
| countdown active | CountdownScreen |
| round active | GameScreen |
| learning reveal | LearningRevealScreen |
| between rounds / round leaderboard phase | RoundLeaderboardScreen |
| final leaderboard | FinalLeaderboardScreen |

### 21.5 Backend enum alignment (`roomStatus`, `matchStatus`, `roundStatus`, …)

These strings **must match** backend / OpenAPI. If backend renames, update **one** Dart enum + mappers.

| Field | Example values (illustrative — confirm with API) | Maps to screen (hint) |
|---|---|---|
| `roomStatus` | `OPEN`, `CLOSED` | lobby vs gone |
| `matchStatus` | `WAITING`, `IN_PROGRESS`, `FINISHED` | game flow |
| `roundStatus` | `COUNTDOWN`, `ACTIVE`, `LEARNING`, `BETWEEN_ROUNDS`, `FINISHED` | countdown / game / learning / leaderboard |

**Redirect logic:** implement `ResyncSnapshotMapper.toRoute()` centralizing §21.4 rules using these enums — avoid string compares scattered in UI.

---

## 22. Manual Testing Strategy

### 22.1 Create / Join
- create room from device A
- join room from device B
- verify both lobbies update

### 22.2 Start Game
- host presses start
- verify both devices navigate to countdown
- verify both devices navigate to game

### 22.3 Guess Flow
- send correct guess
- verify masked word updates for sender
- verify score updates
- send wrong guess
- verify health decreases
- send repeated guess
- verify backend rejection / no duplicate state mutation

### 22.4 Stun / Recovery
- force health to zero
- verify stunned state
- verify input disabled
- verify recovery to 40 HP

### 22.5 Round Completion
- solve word with player A first
- verify sudden death starts
- solve with player B during sudden death
- verify HP bonus only
- verify learning reveal screen
- verify round leaderboard screen

### 22.6 Reconnect
- disconnect one player
- verify offline state shown to others
- reconnect within grace window
- verify snapshot restore
- let another player expire
- verify removal + host transfer if needed

---

## 23. Low-Level Implementation Order

This is the exact recommended order.

### Stage 1
- finalize folder structure
- add `go_router`
- add app theme files
- stabilize `ApiClient` and `WebSocketClient`

### Stage 2
- HomeScreen
- CreateRoomScreen
- JoinRoomScreen
- room session models
- RoomSessionController
- create/join flow

### Stage 3
- LobbyState
- LobbyController
- LobbyScreen realtime updates
- Start Game command flow

### Stage 4
- CountdownState
- CountdownScreen
- `GAME_STARTED` and `ROUND_COUNTDOWN_STARTED` routing

### Stage 5
- GameState
- GameController
- `LETTER_GUESS_RESULT`
- `PLAYER_ROUND_STATE`
- button grid and masked word rendering

### Stage 6
- LearningRevealScreen
- LearningController
- `LEARNING_REVEAL`

### Stage 7
- RoundLeaderboardScreen
- FinalLeaderboardScreen
- LeaderboardController
- `ROUND_LEADERBOARD`
- `FINAL_LEADERBOARD`

### Stage 8
- reconnect controller
- resync snapshot handling
- navigation recovery

### Stage 9
- UI cleanup
- color tokens
- loading and error polish

---

## 24. File-by-File Build Order (Immediate)

The immediate next implementation order should be:

1. `app/router/route_names.dart`
2. `app/router/app_router.dart`
3. `features/home/presentation/screens/home_screen.dart`
4. `features/room/presentation/screens/create_room_screen.dart`
5. `features/room/presentation/screens/join_room_screen.dart`
6. `features/room/application/controllers/room_session_controller.dart`
7. `features/room/application/controllers/lobby_controller.dart`
8. `features/room/presentation/screens/lobby_screen.dart`
9. `features/countdown/...`
10. `features/game/...`

---

## 25. Final Decisions Summary

### Decisions locked by this DDS
- Flutter + Riverpod + go_router
- Feature-based structure with internal layering
- Multiple independent screens, not one giant screen
- Lobby is separate from Game
- Learning Reveal and Round Leaderboard are separate screens
- Backend remains authoritative
- No local persistence for now
- One active room session only
- Mobile-first architecture that can expand to Web later
- Realtime handled via central websocket client and feature controllers

---

## 26. Acceptance Criteria for This DDS

The DDS is considered implementable when a developer can answer these without guessing:
- What folders to create? ✅
- What screens exist and in what order? ✅
- What controllers own which state? ✅
- What REST and WebSocket flows are used? ✅
- What route names and navigation rules exist? ✅
- What data models are needed? ✅
- What events go to which controller? ✅
- How reconnect behaves on frontend? ✅
- What is intentionally out of scope? ✅
- Per-screen **measurable** checks exist? ✅ (§27)
- Edge cases and event ordering documented? ✅ (§28)

---

## 27. Per-Screen Acceptance Criteria (measurable)

Use as **Definition of Done** for MVP UI. Adjust thresholds if product changes.

### 27.1 HomeScreen
- [ ] Both buttons navigate within **300ms** of tap (no double-navigation).
- [ ] No network calls on this screen.

### 27.2 CreateRoomScreen / JoinRoomScreen
- [ ] Invalid form shows **inline** errors before API call.
- [ ] Submit shows loading; on failure, SnackBar within **2s** and **no** route change.
- [ ] Success → Lobby with session + WS connected (verify in debug log).

### 27.3 LobbyScreen
- [ ] Room code and settings visible; host sees Start, non-host does not.
- [ ] Second device joining updates list **without** manual refresh.
- [ ] Start → both clients reach Countdown after `GAME_STARTED` (manual two-device test §22).

### 27.4 CountdownScreen
- [ ] Countdown value updates from `ROUND_COUNTDOWN_STARTED` / tick events.
- [ ] Both clients reach Game on `ROUND_STARTED`.

### 27.5 GameScreen
- [ ] Letter tap disabled when `stunned` or `learningRevealActive` or round inactive.
- [ ] Correct/wrong colors match tokens §8.2.
- [ ] Solved player tile shows success border per §15.6.

### 27.6 LearningRevealScreen
- [ ] Arabic meaning uses RTL; English definition readable (§8.4).
- [ ] “Go to Leaderboard” shows loading until leaderboard event; navigates to correct route per §7.3.

### 27.7 RoundLeaderboardScreen / FinalLeaderboardScreen
- [ ] Rank **1..n** with no duplicate ranks for same score **as backend sends** (display-only).
- [ ] Final screen uses visually stronger treatment than round (spacing/typography §8).
- [ ] Final Leave completes REST leave + WS disconnect + Home (§15.9).

### 27.8 Reconnect / resync (runtime)
- [ ] After WS drop with session in memory, user can recover to correct screen via §21 (manual §22.6).

---

## 28. Edge Cases, Event Ordering, and Ambiguity Resolution

### 28.1 Leaderboard ties / identical scores
- **Display:** render ranks **exactly as backend** provides (`rank` field). If backend sends tied ranks, show duplicate rank numbers — **do not re-rank** client-side.

### 28.2 Concurrent / out-of-order events
- **Queue:** process room-topic events **sequentially** per subscription in order received; if `ROUND_STARTED` arrives before UI left Lobby, **prefer navigation to Game** and drop stale Lobby UI state.
- **Private queue:** apply `PLAYER_ROUND_STATE` as **full replace** of round UI state.
- **Learning + leaderboard:** `ROUND_LEADERBOARD` may arrive before user leaves `/learning` — **buffer only** (§7.3); navigation follows button tap.

### 28.3 Missing / delayed payloads
- If leaderboard button pressed and **no** event within **10s**, show error SnackBar and stop loading (§15.0).
- If `maskedWord` empty unexpectedly, show `AppErrorBanner` + log; optional “Reconnect” if session valid.

### 28.4 Network delay during countdown
- Timer UI may **jump** when sync event arrives — acceptable; **never** show negative time; clamp at **0**.

### 28.5 Web-specific
- CORS / `wss` must match deployment; document in `AppConfig` (§9.1).

---

## 29. Next Action After This DDS

The first coding step after approving this DDS is:

1. Add `go_router`
2. Create `app/router/route_names.dart`
3. Create `app/router/app_router.dart`
4. Split current combined entry screen into:
   - `HomeScreen`
   - `CreateRoomScreen`
   - `JoinRoomScreen`
5. Move current create/join flow into the new structure
