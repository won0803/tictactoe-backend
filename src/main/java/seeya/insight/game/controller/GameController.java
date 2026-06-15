package seeya.insight.game.controller;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import seeya.insight.game.domain.GameRoom;
import seeya.insight.game.service.GameService;
import seeya.insight.game.domain.UserRank;

import java.util.List;
import java.util.Map;

@Controller
public class GameController {

  private final GameService gameService;

  // 생성자 주입: GameService를 가져와서 비즈니스 로직을 처리할 준비를 합니다.
  public GameController(GameService gameService) {
    this.gameService = gameService;
  }

  /**
   * [화면 이동] 게임 대기실/방 화면(JSP 또는 HTML)으로 이동시킵니다.
   * 브라우저 주소창에 /game_room을 입력했을 때 호출됩니다.
   */
  @GetMapping("/game_room")
  public String gameRoom() {
    return "game_room"; // game_room.jsp 또는 game_room.html을 보여줌
  }

  /**
   * [상태 조회] 특정 방의 최신 데이터(보드판 상태, 턴 정보 등)를 가져옵니다.
   * 클라이언트가 주기적으로 호출하여 화면을 갱신(폴링)할 때 사용됩니다.
   */
  @GetMapping("/game/status")
  @ResponseBody
  public ResponseEntity<?> getRoomStatus(
      @RequestParam("roomId") String roomId,
      @RequestParam(value = "userId", required = false) String userId
  ) {
    // 1. DB 또는 메모리에서 해당 방 정보를 찾음
    GameRoom room = gameService.findRoomById(roomId);

    // 방이 삭제되었거나 존재하지 않을 경우 프론트엔드 에러 방지를 위해 문자열 반환
    if (room == null) {
      return ResponseEntity.ok().body("NOT_FOUND");
    }

    // 2. 로그인한 유저 정보가 있다면, 해당 유저의 최신 승패 전적을 방 정보에 담아줌
    if (userId != null && !userId.trim().isEmpty()) {
      UserRank stats = gameService.getUserRank(userId);
      if (stats != null) {
        room.setUserWin(stats.getWins());
        room.setUserLose(stats.getLosses());
        room.setUserDraw(stats.getDraws());
      }
    }
    return ResponseEntity.ok(room);
  }

  /**
   * [방 생성] 새로운 게임방을 만듭니다.
   * @param requestBody { "roomTitle": "방제목", "managerId": "방장ID" }
   */
  @PostMapping("/game/createRoom")
  @ResponseBody
  public ResponseEntity<GameRoom> createRoom(@RequestBody Map<String, String> requestBody) {
    String roomTitle = requestBody.get("roomTitle");
    String managerId = requestBody.get("managerId");
    return ResponseEntity.ok(gameService.createRoom(roomTitle, managerId));
  }

  /**
   * [방 목록] 대기실에서 볼 수 있는 모든 활성화된 방 리스트를 반환합니다.
   */
  @GetMapping("/game/rooms")
  @ResponseBody
  public ResponseEntity<List<GameRoom>> findAllRooms() {
    return ResponseEntity.ok(gameService.findAllRooms());
  }

  /**
   * [방 참가] 다른 유저가 만든 방에 입장합니다.
   * 본인이 만든 방에 스스로 참가하는 것을 막는 로직이 포함되어 있습니다.
   */
  @PostMapping("/game/joinRoom")
  @ResponseBody
  public ResponseEntity<?> joinRoom(@RequestBody Map<String, String> requestBody) {
    String roomId = requestBody.get("roomId");
    String userId = requestBody.get("userId");

    GameRoom room = gameService.findRoomById(roomId);
    if (room == null) {
      return ResponseEntity.status(HttpStatus.NOT_FOUND).body("존재하지 않는 방입니다.");
    }

    // ⭐️ [중요 체크] 방장의 아이디와 참가를 시도하는 아이디가 같으면 입장을 거부
    if (userId.equals(room.getPlayerO())) {
      return ResponseEntity.status(HttpStatus.BAD_REQUEST)
          .body("본인이 만든 방에는 '참가하기'로 들어갈 수 없습니다.");
    }

    try {
      // 정상적인 경우 방에 입장 처리 (상태를 '대기'에서 '게임중'으로 변경 등)
      GameRoom joinedRoom = gameService.joinRoom(roomId, userId);
      return ResponseEntity.ok(joinedRoom);
    } catch (Exception e) {
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("입장 중 오류가 발생했습니다.");
    }
  }

  /**
   * [게임 플레이] 유저가 보드판의 특정 칸(x, y)을 클릭했을 때 돌을 놓는 로직입니다.
   * @param requestBody { "roomId": "방ID", "userId": "유저ID", "x": 0, "y": 1 }
   */
  @PostMapping("/game/play")
  @ResponseBody
  public ResponseEntity<GameRoom> play(@RequestBody Map<String, Object> requestBody) {
    String roomId = (String) requestBody.get("roomId");
    String userId = (String) requestBody.get("userId");
    int x = Integer.parseInt(requestBody.get("x").toString());
    int y = Integer.parseInt(requestBody.get("y").toString());

    // 로직 처리는 Service에서 수행하고 결과가 담긴 방 정보를 반환
    return ResponseEntity.ok(gameService.play(roomId, userId, x, y));
  }

  /**
   * [랭킹 조회] 전체 유저의 전적(승률 순 등) 리스트를 가져옵니다.
   */
  @GetMapping("/game/rank/list")
  @ResponseBody
  public ResponseEntity<List<UserRank>> getRankList() {
    return ResponseEntity.ok(gameService.getRankList());
  }
}