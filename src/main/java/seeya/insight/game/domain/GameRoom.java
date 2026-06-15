package seeya.insight.game.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
public class GameRoom {
  // 게임방 고유 ID (DB SEQ 매핑)
  private String roomId;
  // 게임방 제목
  private String roomTitle;
  // 방장 아이디 (생성자)
  private String managerId;
  // 선공 플레이어 아이디 (O)
  private String playerO;
  // 후공 플레이어 아이디 (X)
  private String playerX;

  // 게임 상태 (01:대기, 02:진행, 03:종료)
  private String status;

  // DB 저장용 보드 문자열 (9자리)
  private String boardData;
  // 게임 로직 처리용 2차원 배열
  private char[][] board;

  // 현재 차례인 유저 아이디
  private String currentTurn;

  // 승리한 유저 아이디
  private String winnerId;
  // 방 입장 가능 여부
  private boolean isFull;

  // 선공 유저 닉네임 (UI 표시용)
  private String playerONick;
  // 후공 유저 닉네임 (UI 표시용)
  private String playerXNick;
  // 선공 유저 프로필 아이콘 경로
  private String playerOIconPath;
  // 후공 유저 프로필 아이콘 경로
  private String playerXIconPath;
  // 상대방 아이디 정보
  private String opponentId;

  // 선공 유저 승리 횟수
  private int userWin;
  // 선공 유저 패배 횟수
  private int userLose;
  // 선공 유저 무승부 횟수
  private int userDraw;

  // 후공 유저 승리 횟수
  private int userXWin;
  // 후공 유저 패배 횟수
  private int userXLose;
  // 후공 유저 무승부 횟수
  private int userXDraw;

  // 게임 상태 코드에 따른 한글 라벨 반환
  public String getStatusLabel() {
    // 상태값 부재 시 기본값 반환
    if (this.status == null) return "대기 중";

    // 상태 코드 "01" (대기 중) 판별
    if ("01".equals(this.status)) {
      return "대기 중";
      // 상태 코드 "02" (게임 중) 판별
    } else if ("02".equals(this.status)) {
      return "게임 중";
      // 상태 코드 "03" (게임 종료) 판별
    } else if ("03".equals(this.status)) {
      return "게임 종료";
    }

    // 예외 상황 시 기본값 반환
    return "대기 중";
  }
}