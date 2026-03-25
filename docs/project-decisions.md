# Project Decisions

## Decision 1
Backend is the source of truth for all gameplay rules.

## Decision 2
REST is used for room bootstrap and reconnect flows.

## Decision 3
WebSocket/STOMP is used for real-time gameplay communication.

## Decision 4
Runtime room state is stored in memory for MVP.

## Decision 5
Dictionary and learning data are stored in PostgreSQL.

## Decision 6
Frontend is a reactive rendering layer and must not own gameplay rules.

## Decision 7
Shared room events and private player events must remain separate.

## Decision 8
The MVP targets maintainability first, then scalability extensions later.
