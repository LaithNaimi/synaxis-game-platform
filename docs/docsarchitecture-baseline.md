# Architecture Baseline

## Core Principle
The Backend is the source of truth for all gameplay rules and real-time state.

## Backend Responsibilities
- room lifecycle management
- player session management
- match and round state transitions
- scoring calculation
- health and stun logic
- word selection
- reconnect and resync
- leaderboard calculation
- shared and private event publishing

## Frontend Responsibilities
- render UI state
- send user commands
- show timers, score, health, word progress, and reactions
- handle local interaction states
- recover UI from backend resync snapshot

## Contracts Responsibilities
- define REST request/response payloads
- define WebSocket commands
- define shared events
- define private events
- maintain schema consistency between Backend and Frontend

## High-Level Runtime Model
- REST is used for room/session bootstrap
- WebSocket/STOMP is used for gameplay events
- runtime room state is managed on the Backend
- persistent dictionary data is stored in PostgreSQL
- the Frontend does not own gameplay rules

----
## Source of Truth Rule

The Backend is the only source of truth for:
- score
- health
- stun
- masked word progress
- round state
- room state
- leaderboard
- reconnect recovery state

The Frontend must never calculate authoritative gameplay results.
It only sends commands and renders server-provided state.

----
## Domain Boundaries

### room
Responsible for room creation, join, leave, host transfer, and room-level state.

### match
Responsible for match setup, round progression, sudden death, and match completion.

### player
Responsible for player session identity, authorization, presence, disconnect, reconnect, and per-player progress.

### scoring
Responsible for score calculation, bonuses, penalties, tie-break rules, and score-related policies.

### word
Responsible for dictionary access, CEFR selection, word preload, and learning reveal data.

### messaging
Responsible for WebSocket/STOMP communication, shared event publishing, and private player event delivery.

### config
Responsible for environment settings, scheduler setup, WebSocket configuration, and app-level configuration.


----
## High-Level Flow

1. A player creates a room using REST.
2. Other players join the room using REST.
3. The host starts the game through a WebSocket command.
4. The Backend initializes the match and round state.
5. Players send guess commands through WebSocket.
6. The Backend validates guesses and updates player state.
7. The Backend publishes shared room events and private player events.
8. The Frontend renders state updates.
9. If a player disconnects, the Backend preserves temporary session state for reconnect.
10. After reconnect, the Backend returns a resync snapshot.


----
## Runtime and Persistence Model

### In-Memory Runtime State
The following data lives in memory during gameplay:
- active rooms
- player runtime sessions
- current match state
- current round state
- per-player guessed letters
- timer-related runtime data

### Persistent Data
The following data is stored persistently:
- dictionary words
- CEFR levels
- Arabic meanings
- English definitions

### Scalability Note
The MVP is designed as a single-instance server-authoritative runtime.
Future scaling may require moving runtime state to Redis or another shared store.


----
## High-Level Flow

1. A player creates a room using REST.
2. Other players join the room using REST.
3. The host starts the game through a WebSocket command.
4. The Backend initializes the match and round state.
5. Players send guess commands through WebSocket.
6. The Backend validates guesses and updates player state.
7. The Backend publishes shared room events and private player events.
8. The Frontend renders state updates.
9. If a player disconnects, the Backend preserves temporary session state for reconnect.
10. After reconnect, the Backend returns a resync snapshot.
-----
# High-Level Architecture Diagram

Frontend (Flutter)
  |
  | REST
  v
Backend (Spring Boot)
  |
  | WebSocket/STOMP
  v
Real-Time Room Engine (in-memory runtime state)
  |
  +--> Scoring Engine
  +--> Health/Stun Engine
  +--> Match/Round State Machine
  +--> Messaging Publisher
  |
  v
PostgreSQL (dictionary and learning content)
