# API and Event Contracts (Draft v1)

## Contract Rules

- All events should include `eventType`.
- All room-scoped events should include `roomCode`.
- All events should include `schemaVersion`.
- All events should include `serverTime`.
- The Backend is the source of truth for all gameplay state.
- Shared events are broadcast to all players in the room.
- Private events are delivered only to the relevant player.
- `playerToken` is required for all authenticated commands and sensitive REST actions.

---

## REST APIs

### Create Room

`POST` /api/v1/rooms
#### Request

```json
{
  "playerName": "Host"
}
```

#### Response

```json
{
  "roomCode": "ABCD12",
  "playerId": "p1",
  "playerToken": "secure-token",
  "isHost": true,
  "roomState": "WAITING",
  "players": [
    {
      "playerId": "p1",
      "playerName": "Host",
      "isHost": true
    }
  ]
}
```
---

### Join Room
`POST` /api/v1/rooms/{roomCode}/join

#### Request

```json
{
  "playerName": "Player2"
}
```
#### Response

```json
{
  "roomCode": "ABCD12",
  "playerId": "p2",
  "playerToken": "secure-token",
  "isHost": false,
  "roomState": "WAITING",
  "players": [
    {
      "playerId": "p1",
      "playerName": "Host",
      "isHost": true
    },
    {
      "playerId": "p2",
      "playerName": "Player2",
      "isHost": false
    }
  ]
}
```

---

### Leave Room

`POST` /api/v1/rooms/{roomCode}/leave

#### Request

```json
{
  "playerId": "p2",
  "playerToken": "secure-token"
}
```
#### Response

204 No Content
---

### Reconnect

`POST` /api/v1/rooms/{roomCode}/reconnect

#### Request

```json
{
  "playerId": "p2",
  "playerToken": "secure-token"
}
```
#### Response
```json
{
  "eventType": "RESYNC_SNAPSHOT",
  "roomCode": "ABCD12",
  "schemaVersion": 1,
  "roomState": "IN_GAME",
  "roundNumber": 2,
  "secondsRemaining": 25,
  "score": 120,
  "health": 80,
  "stunned": false,
  "maskedWord": "_ A _ _",
  "guessedLetters": ["A", "B"],
  "serverTime": "2026-03-25T10:00:25Z"
}
```

---

## WebSocket Commands

### Start Game Command

```json
{
  "command": "START_GAME",
  "roomCode": "ABCD12",
  "playerId": "p1",
  "playerToken": "secure-token"
}
```

### Guess Letter Command

```json
{
  "command": "GUESS_LETTER",
  "roomCode": "ABCD12",
  "playerId": "p2",
  "playerToken": "secure-token",
  "letter": "A"
}
```
---

## Shared Events (Room Broadcast)

### GAME_STARTED 
```json
{
  "eventType": "GAME_STARTED",
  "roomCode": "ABCD12",
  "schemaVersion": 1,
  "serverTime": "2026-03-25T10:00:00Z"
}
```

### ROUND_COUNTDOWN_STARTED
```json
{
  "eventType": "ROUND_COUNTDOWN_STARTED",
  "roomCode": "ABCD12",
  "schemaVersion": 1,
  "roundNumber": 1,
  "countdownSeconds": 3,
  "serverTime": "2026-03-25T10:00:00Z"
}
```
### ROUND_STARTED

```json
{
  "eventType": "ROUND_STARTED",
  "roomCode": "ABCD12",
  "schemaVersion": 1,
  "roundNumber": 1,
  "roundDurationSeconds": 60,
  "wordLength": 4,
  "serverTime": "2026-03-25T10:00:03Z"
}
```

### PLAYER_JOINED

```json
{
  "eventType": "PLAYER_JOINED",
  "roomCode": "ABCD12",
  "schemaVersion": 1,
  "playerId": "p2",
  "playerName": "Player2",
  "serverTime": "2026-03-25T10:00:04Z"
}
```
### PLAYER_LEFT
```json
{
  "eventType": "PLAYER_LEFT",
  "roomCode": "ABCD12",
  "schemaVersion": 1,
  "playerId": "p2",
  "playerName": "Player2",
  "serverTime": "2026-03-25T10:00:05Z"
}
```

### PLAYER_DISCONNECTED
```json
{
  "eventType": "PLAYER_DISCONNECTED",
  "roomCode": "ABCD12",
  "schemaVersion": 1,
  "playerId": "p2",
  "playerName": "Player2",
  "reconnectGraceSeconds": 30,
  "serverTime": "2026-03-25T10:00:10Z"
}
```

### PLAYER_RECONNECTED
```json
{
  "eventType": "PLAYER_RECONNECTED",
  "roomCode": "ABCD12",
  "schemaVersion": 1,
  "playerId": "p2",
  "playerName": "Player2",
  "serverTime": "2026-03-25T10:00:20Z"
}
```

### HOST_TRANSFERRED
```json
{
  "eventType": "HOST_TRANSFERRED",
  "roomCode": "ABCD12",
  "schemaVersion": 1,
  "previousHostPlayerId": "p1",
  "newHostPlayerId": "p2",
  "newHostPlayerName": "Player2",
  "serverTime": "2026-03-25T10:00:30Z"
}
```

### ROUND_LEADERBOARD
```json
{
  "eventType": "ROUND_LEADERBOARD",
  "roomCode": "ABCD12",
  "schemaVersion": 1,
  "roundNumber": 1,
  "players": [
    {
      "rank": 1,
      "playerId": "p1",
      "playerName": "Host",
      "score": 200,
      "health": 90,
      "totalSolveTimeMillis": 8200
    },
    {
      "rank": 2,
      "playerId": "p2",
      "playerName": "Player2",
      "score": 150,
      "health": 70,
      "totalSolveTimeMillis": 11300
    }
  ],
  "serverTime": "2026-03-25T10:00:50Z"
}
```

### FINAL_LEADERBOARD
```json
{
  "eventType": "FINAL_LEADERBOARD",
  "roomCode": "ABCD12",
  "schemaVersion": 1,
  "players": [
    {
      "rank": 1,
      "playerId": "p1",
      "playerName": "Host",
      "score": 420,
      "health": 100,
      "totalSolveTimeMillis": 18500
    },
    {
      "rank": 2,
      "playerId": "p2",
      "playerName": "Player2",
      "score": 350,
      "health": 80,
      "totalSolveTimeMillis": 22300
    }
  ],
  "serverTime": "2026-03-25T10:01:00Z"
}
```
---

## Private Events (Per Player)

### LETTER_GUESS_RESULT

```json
{
  "eventType": "LETTER_GUESS_RESULT",
  "roomCode": "ABCD12",
  "schemaVersion": 1,
  "letter": "A",
  "correct": true,
  "serverTime": "2026-03-25T10:00:08Z"
}
```

### PLAYER_ROUND_STATE
```json
{
  "eventType": "PLAYER_ROUND_STATE",
  "roomCode": "ABCD12",
  "schemaVersion": 1,
  "score": 150,
  "health": 70,
  "stunned": false,
  "maskedWord": "_ A _ _",
  "guessedLetters": ["A", "B"],
  "serverTime": "2026-03-25T10:00:08Z"
}
```

### PLAYER_STUNNED

```json
{
  "eventType": "PLAYER_STUNNED",
  "roomCode": "ABCD12",
  "schemaVersion": 1,
  "playerId": "p2",
  "durationSeconds": 5,
  "serverTime": "2026-03-25T10:00:10Z"
}
```
### PLAYER_RECOVERED
```json
{
  "eventType": "PLAYER_RECOVERED",
  "roomCode": "ABCD12",
  "schemaVersion": 1,
  "playerId": "p2",
  "health": 40,
  "stunned": false,
  "serverTime": "2026-03-25T10:00:15Z"
}
```

### RESYNC_SNAPSHOT
```json
{
  "eventType": "RESYNC_SNAPSHOT",
  "roomCode": "ABCD12",
  "schemaVersion": 1,
  "roomState": "IN_GAME",
  "roundNumber": 2,
  "secondsRemaining": 18,
  "score": 340,
  "health": 40,
  "stunned": false,
  "maskedWord": "_ O _ D",
  "guessedLetters": ["O", "D", "L"],
  "serverTime": "2026-03-25T10:00:25Z"
}
```

---
## Notes for Future Revisions

- This file is Draft v1 and may evolve as implementation progresses.
- Payload fields may be expanded later for stronger UI synchronization.
- If API or event payloads change, the contracts file must be updated before - - - implementation is considered complete.
- schemaVersion should be incremented only when contract changes require version awareness.