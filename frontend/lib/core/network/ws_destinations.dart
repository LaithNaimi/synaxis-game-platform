/// STOMP destinations — single source of truth (DDS §9.4).
class WsDestinations {
  static String roomTopic(String roomCode) => '/topic/room/$roomCode';
  static String privateGameQueue() => '/user/queue/game';

  static String startGameCommand() => '/app/game.start';
  static String guessLetterCommand() => '/app/game.guess-letter';
  static String nextRoundCommand() => '/app/round.next';
}
