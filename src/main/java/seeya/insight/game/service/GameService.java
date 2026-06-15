package seeya.insight.game.service;

import seeya.insight.game.domain.GameRoom;
import seeya.insight.game.domain.UserRank;
import seeya.insight.user.service.UserService;
import seeya.insight.user.domain.User;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * [GameService] 틱택토 게임의 핵심 로직을 처리하는 서비스
 * 게임방 생성, 참가, 수 놓기(Play), 승패 판정, 전적 관리를 담당합니다.
 */
@Service
public class GameService {

  // 1. 실시간 게임방 데이터를 담는 메모리 저장소
  // LinkedHashMap을 사용하여 방이 생성된 순서를 유지하며, Collections.synchronizedMap으로 멀티스레드 환경의 안정성을 확보합니다.
  private final Map<String, GameRoom> rooms = Collections.synchronizedMap(new LinkedHashMap<>());

  // 2. 유저 전적 데이터를 빠르게 관리하기 위한 메모리 캐시
  // 랭킹 조회 시 매번 DB를 조회하지 않고 메모리에서 즉시 처리하기 위해 ConcurrentHashMap을 사용합니다.
  private final Map<String, UserRank> userRanks = new ConcurrentHashMap<>();

  private final UserService userService;

  public GameService(UserService userService) {
    this.userService = userService;
  }

  /**
   * [초기화] 서버 구동 시 실행되는 메서드 (@PostConstruct)
   * DB에 저장되어 있던 기존 유저 전적과 아직 종료되지 않은(Active) 게임방을 메모리로 로드합니다.
   * 서버가 불시에 꺼졌을 때 게임 데이터를 복구하는 역할을 합니다.
   */
  @PostConstruct
  public void init() {
    try {
      // 1. 모든 유저 전적(랭킹) 로드
      List<UserRank> dbRanks = userService.findAllUserRanks();
      if (dbRanks != null) {
        for (UserRank rank : dbRanks) {
          userRanks.put(rank.getUserId(), rank);
        }
      }

      // 2. 종료되지 않은(Status가 종료인 03이 아닌) 게임방 로드
      List<GameRoom> dbRooms = userService.findAllActiveRooms();
      if (dbRooms != null) {
        for (GameRoom room : dbRooms) {
          if (room.getRoomId() != null) {
            // DB의 문자열 보드 데이터("00OXX0...")를 2차원 배열(char[3][3])로 복구
            room.setBoard(stringToBoard(room.getBoardData()));
            // 데이터가 비어있을 경우 기본 턴 설정
            if (room.getCurrentTurn() == null || room.getCurrentTurn().isEmpty()) {
              room.setCurrentTurn(room.getPlayerO());
            }
            // 종료 상태가 아닌 방만 메모리에 추가
            if (!"03".equals(room.getStatus())) {
              rooms.put(room.getRoomId(), room);
            }
          }
        }
      }
      System.out.println("[GameService] 초기화 성공: 방 " + rooms.size() + "개, 랭킹 " + userRanks.size() + "건.");
    } catch (Exception e) {
      System.err.println("[GameService] 초기화 중 오류: " + e.getMessage());
    }
  }

  /**
   * [1. 방 생성]
   * 새로운 게임방을 생성하고 생성자(Manager)를 플레이어O로 배정합니다.
   */
  public GameRoom createRoom(String roomTitle, String managerId) {
    // 유니크한 방 ID 생성 (현재 시간 활용)
    String roomId = String.valueOf((int)(System.currentTimeMillis() % 1000000000));

    GameRoom newRoom = new GameRoom();
    newRoom.setRoomId(roomId);
    newRoom.setRoomTitle(roomTitle);
    newRoom.setManagerId(managerId);
    newRoom.setPlayerO(managerId);     // 방 만든 사람이 O (선공)
    newRoom.setCurrentTurn(managerId); // 선공부터 턴 시작
    newRoom.setStatus("01");           // 01: 대기중
    newRoom.setBoardData("000000000"); // 빈 보드판
    newRoom.setBoard(new char[3][3]);
    newRoom.setFull(false);

    try {
      // 생성자의 닉네임과 아이콘 경로 설정
      User user = userService.findUserProfile(managerId);
      if (user != null) {
        newRoom.setPlayerONick(user.getNickname());
        if (user.getUserIcon() != null) {
          newRoom.setPlayerOIconPath("/upload/" + user.getUserIcon());
        }
      }
      // DB에 방 정보 영구 저장
      userService.insertGameRoom(newRoom);
    } catch (Exception e) {
      System.err.println("[GameService] 방 생성 DB 저장 실패: " + e.getMessage());
    }

    // 메모리 저장소에 방 추가
    rooms.put(roomId, newRoom);
    return newRoom;
  }

  /**
   * [2. 방 참가]
   * 대기 중인 방에 제2플레이어(PlayerX)가 들어옵니다.
   */
  public GameRoom joinRoom(String roomId, String userId) {
    GameRoom room = rooms.get(roomId);
    if (room == null) throw new IllegalArgumentException("존재하지 않는 방입니다.");
    if (!"01".equals(room.getStatus())) throw new IllegalStateException("참가 가능한 상태가 아닙니다.");

    room.setPlayerX(userId);       // 참가자가 X (후공)
    room.setOpponentId(userId);
    room.setStatus("02");          // 02: 게임 진행중
    room.setFull(true);
    room.setCurrentTurn(room.getPlayerO()); // 시작은 항상 O(방장)부터

    try {
      // 참가자의 프로필 정보 로드
      User user = userService.findUserProfile(userId);
      if (user != null) {
        room.setPlayerXNick(user.getNickname());
        if (user.getUserIcon() != null) {
          room.setPlayerXIconPath("/upload/" + user.getUserIcon());
        }
      }
      // DB 상태 업데이트
      userService.updateGameRoom(room);
    } catch (Exception e) {
      System.err.println("[GameService] 참가 업데이트 실패: " + e.getMessage());
    }

    return room;
  }

  /**
   * [3. 게임 진행 (Play)]
   * 플레이어가 특정 좌표(x, y)에 돌을 놓는 핵심 로직입니다.
   */
  public GameRoom play(String roomId, String userId, int x, int y) {
    GameRoom room = rooms.get(roomId);
    if (room == null || !"02".equals(room.getStatus())) {
      throw new IllegalArgumentException("진행 중인 게임이 아닙니다.");
    }

    // 턴 체크: 현재 턴인 유저가 맞는지 확인
    if (!room.getCurrentTurn().trim().equals(userId.trim())) {
      throw new IllegalArgumentException("상대방의 차례입니다.");
    }

    // 빈 칸인지 확인
    if (room.getBoard()[x][y] != 0) {
      throw new IllegalArgumentException("이미 돌이 놓여 있습니다.");
    }

    // 돌 놓기 (O인지 X인지 판별하여 마킹)
    char mark = room.getPlayerO().equals(userId) ? 'O' : 'X';
    room.getBoard()[x][y] = mark;
    // DB 저장을 위해 2차원 배열을 문자열로 변환
    room.setBoardData(boardToString(room.getBoard()));

    // 승리/무승부 판정
    if (checkWin(room.getBoard(), mark)) {
      room.setStatus("03"); // 종료
      room.setWinnerId(userId);
      updateRank(room);     // 전적 반영
    } else if (checkDraw(room.getBoard())) {
      room.setStatus("03"); // 종료
      room.setWinnerId(null); // 무승부
      updateRank(room);
    } else {
      // 게임이 안 끝났으면 턴 교체
      String nextTurnId = userId.equals(room.getPlayerO()) ? room.getPlayerX() : room.getPlayerO();
      room.setCurrentTurn(nextTurnId);
    }

    try {
      // 현재 보드판 상태와 턴 정보를 DB에 즉시 동기화
      userService.updateGameRoom(room);
    } catch (Exception e) {
      System.err.println("[GameService] 진행 상태 업데이트 실패: " + e.getMessage());
    }

    return room;
  }

  /**
   * [4. 전적 업데이트]
   * 게임 종료 시 유저들의 승/무/패를 메모리와 DB에 동시에 반영합니다.
   */
  public void updateRank(GameRoom room) {
    String winnerId = room.getWinnerId();
    String pO = room.getPlayerO();
    String pX = room.getPlayerX();

    // 전적 데이터가 메모리에 없으면 생성
    userRanks.putIfAbsent(pO, new UserRank(pO));
    userRanks.putIfAbsent(pX, new UserRank(pX));

    UserRank rO = userRanks.get(pO);
    UserRank rX = userRanks.get(pX);

    if (winnerId != null) {
      if (winnerId.equals(pO)) { // O 승리
        rO.setWins(rO.getWins() + 1);
        rX.setLosses(rX.getLosses() + 1);
      } else { // X 승리
        rX.setWins(rX.getWins() + 1);
        rO.setLosses(rO.getLosses() + 1);
      }
    } else { // 무승부
      rO.setDraws(rO.getDraws() + 1);
      rX.setDraws(rX.getDraws() + 1);
    }

    try {
      // DB에 Upsert (Insert or Update)
      userService.upsertUserRank(rO);
      userService.upsertUserRank(rX);
    } catch (Exception e) {
      System.err.println("[GameService] 전적 DB 업데이트 실패: " + e.getMessage());
    }

    // 클라이언트 표시를 위해 방 객체에 최신 전적 세팅
    room.setUserWin(rO.getWins());
    room.setUserLose(rO.getLosses());
    room.setUserDraw(rO.getDraws());
    room.setUserXWin(rX.getWins());
    room.setUserXLose(rX.getLosses());
    room.setUserXDraw(rX.getDraws());
  }

  /**
   * [5. 조회 유틸리티]
   */

  // 방 목록 조회 (최신순을 위해 역순 정렬)
  public List<GameRoom> findAllRooms() {
    List<GameRoom> list = new ArrayList<>(rooms.values());
    Collections.reverse(list);
    return list;
  }

  public GameRoom findRoomById(String roomId) {
    return rooms.get(roomId);
  }

  // 특정 유저의 전적 및 닉네임 조회
  public UserRank getUserRank(String userId) {
    UserRank rank = userRanks.getOrDefault(userId, new UserRank(userId));
    try {
      User user = userService.findUserProfile(userId);
      if (user != null) rank.setNickname(user.getNickname());
    } catch (Exception ignored) {}
    return rank;
  }

  // 전체 랭킹 리스트 (승리 횟수 기준 내림차순 정렬)
  public List<UserRank> getRankList() {
    return userRanks.values().stream()
        .map(rank -> {
          try {
            User user = userService.findUserProfile(rank.getUserId());
            if (user != null) {
              rank.setNickname(user.getNickname());
              rank.setUserIcon(user.getUserIcon());
            }
          } catch (Exception ignored) {}
          return rank;
        })
        .sorted((r1, r2) -> Integer.compare(r2.getWins(), r1.getWins()))
        .collect(Collectors.toList());
  }

  // 메모리에서 유저 데이터 제거 (필요 시 호출)
  public void removeUserFromMemory(String userId) {
    userRanks.remove(userId);
  }

  // 특정 유저 전적 초기화
  public void resetUserRank(String userId) {
    UserRank rank = userRanks.get(userId);
    if (rank != null) {
      rank.setWins(0);
      rank.setLosses(0);
      rank.setDraws(0);
    }
  }

  /**
   * [6. 내부 유틸리티]
   */

  // 2차원 보드 배열을 DB 저장용 문자열로 변환 (예: 3x3 배열 -> "0OX00X...")
  private String boardToString(char[][] board) {
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        sb.append(board[i][j] == 0 ? '0' : board[i][j]);
      }
    }
    return sb.toString();
  }

  // DB의 문자열 데이터를 2차원 보드 배열로 복구
  private char[][] stringToBoard(String boardData) {
    char[][] board = new char[3][3];
    if (boardData == null || boardData.length() < 9) return board;
    int idx = 0;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        char c = boardData.charAt(idx++);
        board[i][j] = (c == '0') ? 0 : c;
      }
    }
    return board;
  }

  // 승리 조건 체크 (가로, 세로, 대각선)
  private boolean checkWin(char[][] board, char mark) {
    for (int i = 0; i < 3; i++) {
      // 가로/세로 체크
      if (board[i][0] == mark && board[i][1] == mark && board[i][2] == mark) return true;
      if (board[0][i] == mark && board[1][i] == mark && board[2][i] == mark) return true;
    }
    // 대각선 체크
    return (board[0][0] == mark && board[1][1] == mark && board[2][2] == mark) ||
        (board[0][2] == mark && board[1][1] == mark && board[2][0] == mark);
  }

  // 무승부 체크 (빈 칸이 하나도 없으면 무승부)
  private boolean checkDraw(char[][] board) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == 0) return false;
      }
    }
    return true;
  }
}