# Coding Standards and Versioning

## Project Naming Conventions

### General
- Use clear and descriptive names.
- Avoid ambiguous abbreviations unless they are standard.
- Keep naming consistent across Backend, Frontend, and contracts.

### Backend Naming
- Java classes use PascalCase.
- methods and variables use camelCase.
- constants use UPPER_SNAKE_CASE.
- package names use lowercase.
- DTO names should end with Request, Response, Command, or Event where appropriate.
- service classes should clearly describe their responsibility.
- repository interfaces should be named by domain responsibility.

### Frontend Naming
- Dart files use snake_case.
- Flutter widgets use PascalCase.
- state classes should clearly reflect UI or feature responsibility.
- avoid vague file names like utils.dart or helpers.dart unless they are truly generic.

### API Naming
- REST paths use lowercase and plural resource naming where appropriate.
- keep endpoint naming predictable and resource-oriented.

### Contracts Naming
- event names should be explicit and action-oriented.
- shared events and private events must be clearly distinguishable by name and purpose.


---

## Branching Strategy

- The main branch is `main`.
- `main` must always remain stable.
- All work should be done in short-lived branches.
- Branches should be merged only after the task is complete and reviewed.

### Branch Naming
Use the following naming patterns:
- feature/<short-description>
- fix/<short-description>
- refactor/<short-description>
- docs/<short-description>
- test/<short-description>

### Examples
- feature/room-api
- feature/scoring-engine
- feature/flutter-game-screen
- fix/reconnect-validation
- docs/architecture-baseline
- test/round-state-machine

----
## Commit Convention

Use Conventional Commits for all commit messages.

### Format
<type>: <short description>

### Allowed Types
- feat: for new features
- fix: for bug fixes
- refactor: for code restructuring without behavior change
- docs: for documentation changes
- test: for tests
- chore: for maintenance tasks, setup, or tooling

### Examples
- feat: add create room API
- feat: implement score calculator
- fix: prevent duplicate letter guess handling
- refactor: split round logic into service classes
- docs: add architecture baseline
- test: add unit tests for health manager
- chore: configure local docker compose

----
## Versioning Strategy

The project uses Semantic Versioning (SemVer):

MAJOR.MINOR.PATCH

### Rules
- MAJOR: breaking changes or major release milestones
- MINOR: new features added in a backward-compatible way
- PATCH: bug fixes and small non-breaking improvements

### MVP Phase
The project will begin with pre-1.0 releases until the MVP is stable.

so the order of tasks is the best , and the new version file is :

### Example Progression
- 0.1.0 foundation and backend bootstrap
- 0.2.0 database and dictionary foundation
- 0.3.0 room runtime and room lifecycle APIs
- 0.4.0 WebSocket messaging and match setup
- 0.5.0 round state machine and guess validation
- 0.6.0 scoring, health, and stun system
- 0.7.0 round completion, leaderboards, and reconnect flows
- 0.8.0 frontend bootstrap and static gameplay UI
- 0.9.0 frontend network integration and match completion UI
- 1.0.0 MVP release
## Release Milestones 

### 0.1.0
- repository structure
- architecture baseline
- coding standards
- API and event contracts draft v1
- backend bootstrap
- Spring Boot project skeleton
- initial config profiles

### 0.2.0
- PostgreSQL setup
- Flyway migration baseline
- words table design
- dictionary seed preparation
- dictionary query layer

### 0.3.0
- room domain model
- in-memory room repository
- per-room synchronization baseline
- create room API
- join room API
- leave room API
- reconnect API
- room lifecycle test baseline

### 0.4.0
- WebSocket/STOMP infrastructure
- message DTO contracts in code
- command authentication and validation
- message publisher abstraction
- match creation flow
- CEFR word selector
- round learning data attachment

### 0.5.0
- round lifecycle state machine
- countdown flow
- round start flow
- timeout handling
- next round progression
- guess validation handler
- masked word update logic
- private player progress updates

### 0.6.0
- letter frequency classifier
- score calculator
- scoring integration
- health manager
- stun trigger and recovery
- penalty logic integration
- full scoring and health tests

### 0.7.0
- first solver detection
- sudden death logic
- learning reveal payload
- round leaderboard
- final leaderboard
- disconnect handling
- reconnect expiry and restore
- host transfer flow

### 0.8.0
- Flutter project bootstrap
- state management setup
- design system basics
- gameplay screen layout
- Synx states and reactions
- hidden word and keyboard UI
- mock-driven gameplay state

### 0.9.0
- REST client layer
- WebSocket/STOMP client layer
- backend event to frontend state mapping
- reconnect/resync handling in Frontend
- round result UI
- leaderboard UI
- final match completion UI

### 1.0.0
- backend unit test completion
- backend integration and WebSocket tests
- frontend widget and integration tests
- manual QA pass
- backend deployment setup
- frontend release preparation
- release documentation and final MVP delivery

## Working Rules

- Do not push incomplete experimental code directly to `main`.
- Prefer small, focused commits.
- Prefer small, focused branches.
- Keep documentation updated when architecture or contracts change.
- Do not mix unrelated changes in a single commit.
- Contracts must be updated when API or event payloads change.
- Backend remains the source of truth for gameplay rules.