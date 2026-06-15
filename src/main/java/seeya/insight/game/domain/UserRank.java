package seeya.insight.game.domain;

/**
 * 사용자의 게임 전적을 기록하는 도메인 객체
 */
public class UserRank {

  // 전적 데이터를 소유한 사용자 아이디
  private String userId;

  // 화면에 표시될 사용자 닉네임
  private String nickname;

  // 프로필 이미지 파일명을 저장할 필드
  private String userIcon;

  // 전적 기록
  private int wins;       // 승리 횟수
  private int losses;     // 패배 횟수
  private int draws;      // 무승부 횟수

  // MyBatis용 기본 생성자
  public UserRank() {}
 // 신규 유저용 초기화 생성자
  public UserRank(String userId) {
    this.userId = userId;
    this.wins = 0;
    this.losses = 0;
    this.draws = 0;
  }

  // 아이콘 정보 가져오기
  public String getUserIcon() {
    return userIcon;
  }
 // 아이콘 정보 설정하기
  public void setUserIcon(String userIcon) {
    this.userIcon = userIcon;
  }

  // 닉네임 정보 가져오기
  public String getNickname() {
    return nickname;
  }
 // 닉네임 정보 설정하기
  public void setNickname(String nickname) {
    this.nickname = nickname;
  }
 // 유저 아이디 가져오기
  public String getUserId() {
    return userId;
  }
 // 유저 아이디 설정하기
  public void setUserId(String userId) {
    this.userId = userId;
  }
 // 승리 횟수 가져오기
  public int getWins() {
    return wins;
  }
 // 승리 횟수 설정하기
  public void setWins(int wins) {
    this.wins = wins;
  }
 // 패배 횟수 가져오기
  public int getLosses() {
    return losses;
  }
 // 패배 횟수 설정하기
  public void setLosses(int losses) {
    this.losses = losses;
  }
 // 무승부 횟수 가져오기
  public int getDraws() {
    return draws;
  }
 // 무승부 횟수 설정하기
  public void setDraws(int draws) {
    this.draws = draws;
  }

  // JSP 연동을 위한 추가 Getter들
  public int getWinCount() { return this.wins; } //JSP 표현식용 승리 수 반환
  public int getLoseCount() { return this.losses; } //JSP 표현식용 패배 수 반환
  public int getDrawCount() { return this.draws; } //JSP 표현식용 무승부 수 반환
}