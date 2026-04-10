# Synaxis — UI/UX Design Brief

> **Purpose:** Complete specification for a UI/UX designer to produce a clickable prototype.
> **Note:** This document intentionally omits colors, palettes, and visual theme. The designer has full creative freedom over the aesthetic direction. Focus on layout, hierarchy, states, and content.

---

## 1. Product Overview

**Product:** Synaxis — a real-time multiplayer vocabulary challenge game.

**Platform:** Mobile-first (iOS/Android). The design should not break on wider screens (tablet/web), but mobile is the primary target.

**Core Loop:** Players join a room → play multiple rounds of a word-guessing game → see results after each round → final rankings at the end of the match.

**Key Interaction Model:** Players guess hidden English words one letter at a time under time pressure, competing against each other in real time.

---

## 2. Typography Requirements

- **Titles & Buttons:** Use a geometric or futuristic display font (e.g. Orbitron or similar).
- **Body Text, Inputs, Captions:** Use a clean sans-serif font that supports both **English (LTR)** and **Arabic (RTL)** text. Examples: Noto Sans, IBM Plex Sans Arabic, or system default.

---

## 3. Accessibility & Touch Targets

- All interactive elements (buttons, letter keys, tappable areas) must be **minimum 48×48dp**.
- Ensure sufficient contrast between text and backgrounds for readability.
- Letter buttons on the Game Screen must be comfortably tappable on small phone screens.

---

## 4. Responsive Notes

- **Mobile-first:** Design at ~375px width.
- **Max content width:** On wider screens, center content and cap width at ~560px to avoid awkward stretching.
- **Safe areas:** Respect notch/status bar insets on all screens. Never place CTAs in unsafe zones.

---

## 5. Global Components (Design System)

Design these as reusable components to be used across all screens:

| Component | Description |
|-----------|-------------|
| **Primary Button** | Filled, prominent CTA. Supports states: default, hover/pressed, disabled, loading (with spinner). |
| **Secondary Button** | Outlined/ghost variant. Same states as primary. |
| **Text Input Field** | Supports states: empty (with placeholder), filled, focused, error (with error message below), disabled. |
| **Dropdown / Select** | For settings selection. Supports: default, open, selected, disabled. |
| **Loading Overlay** | Semi-transparent overlay covering the entire screen with a centered spinner. Used during API calls to block interaction. |
| **Error Snackbar / Banner** | Dismissible notification for API failures or errors. Appears at the top or bottom of the screen. |
| **Player Tile** | Compact card showing a player's name + optional badges/indicators (see below). |
| **Host Badge** | Small visual indicator (icon or label) to mark the room host (e.g. crown, star). |
| **Offline Indicator** | Visual treatment on a Player Tile when a player is temporarily disconnected (e.g. dimmed, greyed, disconnected icon). |

---

## 6. Screen Specifications

---

### Screen 1 — Home

**Purpose:** Entry point. Two actions only.

**Content:**
- Game title: **"SYNAXIS"** — prominent, hero-sized, with a stylized/glowing treatment.
- Optional: Subtitle or tagline.
- Optional: Background pattern or decorative element.

**Actions:**
- **"Create Room"** — Primary Button → navigates to Create Room screen.
- **"Join Room"** — Secondary Button → navigates to Join Room screen.

**States:** None. No loading, no errors. Static screen.

---

### Screen 2 — Create Room

**Purpose:** Host creates a new game room by entering their name and selecting game settings.

**Content:**
- Screen title: **"CREATE ROOM"**
- Back navigation (arrow or similar) to return to Home.

**Inputs:**

| Field | Type | Validation |
|-------|------|------------|
| Player Name | Text input | Required. Max 32 characters. Show error if empty on submit. |
| CEFR Level | Dropdown | Options: A1, A2, B1, B2, C1, C2. Required. |
| Max Players | Dropdown | Range: 2–8. Required. |
| Total Rounds | Dropdown | Range: 1–20. Required. |
| Round Duration | Dropdown | Range: 15–120 seconds (step of 5 or 10). Required. |

**Actions:**
- **"Create Room"** — Primary Button.

**UX States:**
- **Disabled Button:** CTA is disabled until Player Name is filled and all dropdowns are selected.
- **Error State:** If Player Name is empty when user attempts to submit, show inline error message below the field.
- **Loading:** On submit, show Loading Overlay (block all interaction) until the API responds.
- **API Error:** On failure, dismiss overlay and show Error Snackbar with the failure message.

---

### Screen 3 — Join Room

**Purpose:** Player joins an existing room using a code.

**Content:**
- Screen title: **"JOIN ROOM"**
- Back navigation to Home.

**Inputs:**

| Field | Type | Validation |
|-------|------|------------|
| Player Name | Text input | Required. Max 32 characters. |
| Room Code | Text input | Required. Exactly **6 alphanumeric characters** (letters and digits, e.g. `ABC123`). |

**Actions:**
- **"Join Room"** — Primary Button.

**UX States:**
- **Disabled Button:** CTA disabled until both fields are valid.
- **Error States:** Inline error below each field (e.g. "Name is required", "Code must be 6 alphanumeric characters").
- **Loading:** Loading Overlay on submit.
- **API Errors:** Snackbar for errors like "Room not found", "Room is full", "Game already started".

---

### Screen 4 — Lobby (Waiting Room)

**Purpose:** Players wait here until the host starts the game. Players can see who has joined.

**Content:**

| Element | Description |
|---------|-------------|
| **Room Code** | Displayed prominently with a **Copy button** next to it for easy sharing. |
| **Room Settings Card** | Compact card showing: CEFR Level, Max Players, Total Rounds, Round Duration. |
| **Player List** | Vertical list of Player Tiles for each joined player. The host is marked with a **Host Badge** (crown/star icon). Disconnected players show an **Offline Indicator**. |
| **Empty State** | When the host is alone: show a message like _"No other players yet — share the room code!"_ in the player list area. |

**Actions:**
- **"Leave Room"** — Secondary/destructive button. Visible to **all** players. Navigates back to Home.
- **"Start Game"** — Primary Button. Visible **only to the Host**.

**UX States:**
- **Non-Host View:** Where the "Start Game" button would be, non-host players see a text message: _"Waiting for host to start..."_
- **Min Players Gate:** "Start Game" should be disabled if fewer than 2 players are in the lobby. Show a hint like _"Need at least 2 players"_.
- **Real-Time Updates:** The player list updates live as players join or leave — no manual refresh.
- **Loading:** "Start Game" shows loading state after tap. The game doesn't start immediately; it waits for a server confirmation event.

---

### Screen 5 — Countdown (Transition)

**Purpose:** Brief transitional screen before each round begins. Builds anticipation.

**Content:**
- **Round Label:** "Round X of Y" (e.g. "Round 1 of 5") — centered, secondary emphasis.
- **Countdown Number:** Large, centered, animated number counting down (values come from the server — typically 3, 2, 1).

**UX States:**
- This screen appears automatically and transitions to the Game Screen when the server signals "round started".
- No user interaction needed.

---

### Screen 6 — Game (Main Gameplay)

**Purpose:** The core gameplay screen. This is the most complex screen and requires careful visual hierarchy.

**Visual Hierarchy (top to bottom, in order of priority):**

#### 6A. Header Bar
- **Round indicator:** "Round X of Y"
- **Timer:** Circular or bar timer showing remaining seconds. The timer should have a **visual urgency state** — when time is running low (e.g. last 25%), the timer visually intensifies (pulsing, color shift, etc.) to communicate urgency.

#### 6B. Player Metrics
- **Score:** Current score with optional **+N / −N delta animation** when score changes after a guess.
- **Health Bar:** Visual bar showing current health (0–100). Should also show **delta feedback** on change.

#### 6C. Masked Word (PRIMARY FOCUS)
- The hidden word displayed as a series of blanks and revealed letters (e.g. `_ _ A _ X _`).
- **This must be the most visually prominent element on screen** — large typography, centered.
- Content comes directly from the server; the UI only renders it.

#### 6D. Letter Grid (Keyboard)
- Grid of **26 English letter buttons** (A–Z).
- Layout: 5–6 columns on mobile (with wrapping). Must be scrollable if needed.

**Letter Button States:**

| State | Meaning | Visual Treatment |
|-------|---------|-----------------|
| Untouched | Not yet guessed | Default/neutral |
| Correct | Letter is in the word | Success style (e.g. green) |
| Wrong | Letter is NOT in the word | Error style (e.g. red) |
| Disabled | Cannot tap (stunned, round over, already guessed) | Dimmed/greyed out |

#### 6E. Mini Players List
- Compact horizontal strip or sidebar showing all players in the room.
- Each player shows: **name** and **score**.
- **Solved indicator:** Players who have solved the word get a visual highlight (e.g. glowing border, checkmark).
- **Host badge** if relevant.
- **Offline indicator** for disconnected players.

#### Special Game States (Overlays / Banners):

**Stunned State:**
- When a player's health reaches 0, they are "stunned" — temporarily unable to interact.
- Show a **full-screen semi-transparent overlay** blocking the letter grid.
- Display a message: **"STUNNED"** with a brief timer or indication that recovery is coming.
- When recovered, the overlay lifts.

**Sudden Death State:**
- After the first player solves the word, all remaining players enter "Sudden Death".
- Show a **persistent warning banner** at the top or overlaying the header: **"SUDDEN DEATH"**
- The timer or background should visually communicate heightened urgency.

**Solved State (Current Player):**
- When the current player successfully solves the word, disable all letter buttons.
- Show a congratulatory indicator: **"SOLVED!"** — can be a banner or overlay.

**Round Ended / Time Up:**
- All interaction disabled.
- Brief transition to the next screen (Learning Reveal).

---

### Screen 7 — Learning Reveal

**Purpose:** Educational moment after each round. Shows the full word and its meaning.

**Content:**
- **Round Label:** "Round X of Y" — small, secondary.
- **The Word:** Fully revealed, large typography (e.g. "EXAMPLE").
- **Arabic Meaning:** Displayed in **RTL** direction (e.g. "مثال"). Clearly labeled.
- **English Definition:** Displayed in **LTR** direction (e.g. "a thing characteristic of its kind or illustrating a general rule"). Clearly labeled.

**Actions:**
- **"Go to Leaderboard"** — Primary Button.

**UX States:**
- **Loading Button:** When tapped, the button transitions to a **loading/spinner state**. The leaderboard data may not be ready yet (it arrives asynchronously from the server). The button stays in loading state until data is ready, then navigates automatically.
- **Timeout Error:** If data doesn't arrive within ~10 seconds, show an Error Snackbar and stop the loading state.

---

### Screen 8 — Round Leaderboard

**Purpose:** Shows cumulative player rankings after each round (not the final round).

**Content:**

| Column | Description |
|--------|-------------|
| **Rank** | Player position (1, 2, 3…). Ties are displayed as the server sends them. |
| **Name** | Player name. |
| **Score** | Cumulative score. |
| **Health** | Current health value. |
| **Solve Time** | How fast the player solved the word (in seconds). |

- The list should visually distinguish the **top 3 positions** (e.g. larger row, medal icon, or subtle emphasis).
- Show the current player's own row with a visual highlight so they can quickly find themselves.

**Actions (Host View):**
- **"Next Round"** — Primary Button. Visible **only to the Host**. Sends a command to the server and shows loading until the next countdown begins.

**Actions (Non-Host View):**
- Instead of the button, show: _"Waiting for host to start next round..."_

---

### Screen 9 — Final Leaderboard

**Purpose:** End-of-match results. This screen should feel **celebratory and special** — visually distinct from the Round Leaderboard.

**Content:**
- Same columns as Round Leaderboard (Rank, Name, Score, Health, Solve Time).
- **Podium treatment for Top 3:** The 1st, 2nd, and 3rd place players should have prominent, visually distinct treatment (e.g. a podium graphic, large cards, trophy/medal icons, special typography).
- Consider an animation or celebratory effect on screen entry (confetti, glow, etc.).
- The current player's row should be highlighted.

**Actions:**
- **"Leave Room"** — Primary Button. Returns all players to the Home screen.

**UX States:**
- **Loading Button:** "Leave Room" shows loading state while the server processes the leave request. Disable the button to prevent double-tap.
- **Error / Retry:** On network failure, show Snackbar with retry option. Do not navigate until the request succeeds or the room is confirmed gone.

---

## 7. Navigation Flow Summary

```
Home
 ├─→ Create Room ──→ Lobby
 └─→ Join Room ───→ Lobby
                      │
                      ▼
                   Countdown
                      │
                      ▼
                  Game Screen
                      │
                      ▼
                Learning Reveal
                      │
              ┌───────┴───────┐
              ▼               ▼
     Round Leaderboard   Final Leaderboard
              │               │
              ▼               ▼
           Countdown        Home
           (next round)   (leave room)
```

**Loop:** The cycle `Countdown → Game → Learning → Round Leaderboard → Countdown` repeats for each round. After the final round, the flow goes to `Final Leaderboard` instead.

---

## 8. Key UX Principles for the Designer

1. **Game Screen Hierarchy:** The masked word and letter grid must dominate the Game Screen. Score/health/timer are important but secondary. The mini player list is tertiary.

2. **State Clarity:** Every interactive element must clearly communicate its current state. A disabled button must look obviously disabled. A loading button must show a spinner. An error field must show a message.

3. **Real-Time Feel:** The Lobby player list, Game Screen player tiles, and score/health bars update in real time. Design them to feel alive — consider subtle animations for value changes (score ticking up, health bar sliding, player joining with a fade-in).

4. **Mobile Comfort:** The letter grid is the most-tapped area of the entire app. Prioritize comfortable tap targets and spacing. Test the layout mentally with thumb reach zones.

5. **Bilingual Support:** The Learning Reveal screen mixes English (LTR) and Arabic (RTL) content. Ensure both directions look intentional and well-laid-out, not like a broken layout.

6. **Emotional Arc:** The screens follow an emotional journey: calm (Home) → focused (Create/Join) → social (Lobby) → tense (Countdown) → intense (Game) → reflective (Learning) → competitive (Leaderboard) → celebratory (Final). The visual treatment should subtly support this arc.

7. **Error Resilience:** No screen should ever feel "stuck" without feedback. If something is loading, show it. If something fails, say it. If the user needs to wait, tell them why.

---

## 9. Deliverables Expected

- Clickable prototype covering all 9 screens.
- All UX states documented above (disabled, loading, error, empty, stunned, sudden death, solved).
- Mobile-first layouts at ~375px width.
- Component library showing all reusable components in their various states.
- Hover/pressed states for interactive elements (for web usage).

---

## 10. Screen-by-Screen State Checklist

Use this as a QA checklist — every state listed should have a corresponding design:

| Screen | States to Design |
|--------|-----------------|
| Home | Default only |
| Create Room | Default, field error, button disabled, button loading, loading overlay, error snackbar |
| Join Room | Default, field errors, button disabled, button loading, loading overlay, error snackbar |
| Lobby | Default (host view), default (non-host view), empty (solo host), player joined, player disconnected, start game loading, min-players-not-met |
| Countdown | Default with countdown values |
| Game | Default, letter correct, letter wrong, letter disabled, stunned overlay, sudden death banner, solved state, timer urgency, score/health delta feedback, player solved highlight, player disconnected |
| Learning Reveal | Default, button loading, timeout error |
| Round Leaderboard | Default (host view), default (non-host view), loading state, top-3 emphasis, current-player highlight |
| Final Leaderboard | Default, top-3 podium, celebration effects, leave button loading, leave error/retry, current-player highlight |

---

*End of UI/UX Design Brief.*
