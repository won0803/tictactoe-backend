package seeya.insight.game.domain;

/**
 * 게임의 현재 상태를 나타내는 열거형 (Enum)
 */
public enum GameStatus {
  WAITING, // 대기 중 (1명)
  PLAYING, // 게임 진행 중 (2명)
  FINISHED // 게임 종료됨 (승패 또는 무승부)
}