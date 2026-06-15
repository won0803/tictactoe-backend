package seeya.insight.user.controller;

import org.springframework.web.multipart.MultipartFile;
import seeya.insight.user.domain.User;
import seeya.insight.user.service.UserService;
import seeya.insight.game.service.GameService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.dao.DuplicateKeyException;
import jakarta.servlet.http.HttpServletRequest;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * [UserController]
 * 사용자 관련 모든 기능(계정 생성, 인증, 정보 수정, 전적 관리)을 처리하는 컨트롤러입니다.
 */
@Controller
@RequestMapping("/user")
public class UserController {

  private final UserService userService;
  private final GameService gameService; // 실시간 메모리 전적 반영을 위한 주입

  public UserController(UserService userService, GameService gameService) {
    this.userService = userService;
    this.gameService = gameService;
  }

  // ==========================================================
  // 1. 회원가입 영역 (Join / Sign-up)
  // ==========================================================

  /** 회원가입 페이지 뷰 반환 */
  @GetMapping("/join")
  public String userJoinView(HttpServletRequest request) {
    return "user/join";
  }

  /** AJAX 방식의 회원가입 처리 API */
  @PostMapping("/api/join")
  @ResponseBody
  public Map<String, Object> userJoinApi(@RequestBody Map<String, Object> params) {
    return doJoinAndBuildResponse(params);
  }

  /** 일반 Form 방식 또는 JSON 방식의 회원가입 처리 API */
  @PostMapping("/join")
  @ResponseBody
  public Map<String, Object> userJoinJson(@RequestBody Map<String, Object> params) {
    return doJoinAndBuildResponse(params);
  }

  /** 기존 시스템 호환용 회원가입 처리 API */
  @PostMapping("/api/sign-up")
  @ResponseBody
  public int userJoinForm(@RequestBody Map<String, Object> body) {
    return userService.userJoinForm(body);
  }

  /** [공통 로직] 회원가입 실무 처리 및 중복 예외 핸들링 */
  private Map<String, Object> doJoinAndBuildResponse(Map<String, Object> params) {
    String resultCode = "SUCCESS";
    String message = "OK";
    try {
      String userId = asString(params, "userId");
      String password = asString(params, "password");
      String nickname = asString(params, "nickname");
      String email = asString(params, "email");
      userService.join(userId, password, nickname, email);
    } catch (IllegalArgumentException | IllegalStateException e) {
      resultCode = "FAIL";
      message = e.getMessage(); // 유효성 검사 실패 메시지
    } catch (DuplicateKeyException e) {
      resultCode = "FAIL";
      message = extractDuplicateMessage(e); // DB 유니크 제약 조건 위반 처리
    } catch (Exception e) {
      resultCode = "FAIL";
      message = "알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요.";
    }
    Map<String, Object> resp = new LinkedHashMap<>();
    resp.put("resultCode", resultCode);
    resp.put("message", message);
    return resp;
  }

  // ==========================================================
  // 2. 로그인 및 로그아웃 영역 (Login / Logout)
  // ==========================================================

  /** 로그인 페이지 뷰 반환 */
  @GetMapping("/login")
  public String userLoginView() {
    return "user/login";
  }

  /** 로그인 처리 API 및 세션 생성 */
  @PostMapping("/api/login")
  @ResponseBody
  public Map<String, Object> login(@RequestBody Map<String, Object> body, HttpSession session) {
    Map<String, Object> response = new HashMap<>();
    String userId = (String) body.get("userId");
    String password = (String) body.get("password");
    try {
      User loggedInUser = userService.login(userId, password);

      // 로그인 성공 시 세션에 핵심 정보를 기록 (메인화면 및 헤더에서 사용)
      session.setAttribute("loggedInUser", loggedInUser.getUserId());
      session.setAttribute("userNickname", loggedInUser.getNickname());
      session.setAttribute("userWin", loggedInUser.getWinCount());
      session.setAttribute("userLose", loggedInUser.getLoseCount());
      session.setAttribute("userDraw", loggedInUser.getDrawCount());

      response.put("resultCode", "SUCCESS");
      response.put("message", loggedInUser.getNickname() + "님 환영합니다!");
    } catch (IllegalArgumentException e) {
      response.put("resultCode", "FAIL");
      response.put("message", e.getMessage());
    } catch (Exception e) {
      response.put("resultCode", "ERROR");
      response.put("message", "서버 오류가 발생했습니다.");
    }
    return response;
  }

  /** 로그아웃 처리 (리다이렉트 방식) */
  @PostMapping("/logout")
  public String userLogout(HttpServletRequest request, @RequestParam Map<String, Object> params) {
    return userService.userLogout(request, params);
  }

  /** 로그아웃 처리 (AJAX 방식, 세션 무효화) */
  @PostMapping("/api/logout")
  @ResponseBody
  public Map<String, Object> logout(HttpSession session) {
    Map<String, Object> response = new HashMap<>();
    try {
      if (session != null) session.invalidate(); // 세션 즉시 삭제
      response.put("resultCode", "SUCCESS");
      response.put("message", "로그아웃 되었습니다.");
    } catch (Exception e) {
      response.put("resultCode", "ERROR");
      response.put("message", "로그아웃 중 오류가 발생했습니다.");
    }
    return response;
  }

  // ==========================================================
  // 3. 아이디 및 비밀번호 찾기 영역 (ID/PW Find)
  // ==========================================================

  /** 아이디 찾기 페이지 (이메일 입력) */
  @GetMapping("/find-id")
  public String userFindId(HttpServletRequest request, Map<String, Object> params) {
    return userService.userFindId(request, params);
  }

  /** 아이디 찾기 - 인증코드 입력 페이지 */
  @GetMapping("/code-id")
  public String userCodeIdView(
      @RequestParam(value = "email", required = false) String email,
      HttpServletRequest request) {

    // @RequestParam(required = false)를 설정하면 주소창 세탁 후
    // 새로고침을 해도 'Required parameter not present' 에러가 발생하지 않습니다.
    return "user/code_id";
  }

  /** 이메일로 아이디 찾기 인증코드 발송 API */
  @PostMapping("/api/find-id-code")
  @ResponseBody
  public Map<String, Object> findIdCode(@RequestBody Map<String, Object> body) {
    Map<String, Object> response = new HashMap<>();
    try {
      String generatedCode = userService.requestFindIdCode((String) body.get("email"));
      response.put("resultCode", "SUCCESS");
      response.put("message", "인증 코드가 발송되었습니다.");
      response.put("authCode", generatedCode);
    } catch (Exception e) {
      response.put("resultCode", "FAIL");
      response.put("message", e.getMessage());
    }
    return response;
  }

  /** 아이디 찾기 인증코드 검증 API */
  @PostMapping("/api/verify-id-code")
  @ResponseBody
  public Map<String, Object> verifyIdCodeApi(@RequestBody Map<String, Object> params) {
    String resultCode = "SUCCESS";
    String message = "OK";
    try {
      userService.verifyFindIdCode(asString(params, "email"), asString(params, "code"));
    } catch (Exception e) {
      resultCode = "FAIL";
      message = e.getMessage();
    }
    Map<String, Object> resp = new LinkedHashMap<>();
    resp.put("resultCode", resultCode);
    resp.put("message", message);
    return resp;
  }

  /** 인증 성공 후 최종 아이디 확인 페이지 */
  @GetMapping("/check-id")
  public String userCheckIdView(
      @RequestParam(value = "email", required = false) String email,
      Map<String, Object> model) {

    // 주소창 세탁 후 새로고침 시 email 파라미터가 없으므로
    // 비정상 접근 시 에러 페이지로 보내거나 빈 페이지를 리턴합니다.
    if (email == null || email.isEmpty()) {
      // 이미 주소창이 세탁된 후라면 JSP의 sessionStorage에서 데이터를 처리하므로
      // 여기서는 단순히 뷰 이름만 리턴해도 무방합니다.
      return "user/check_id";
    }

    // 서비스에서 이메일을 기반으로 아이디 정보를 조회하여 model에 담습니다.
    return userService.findUserIdAfterVerification(email, model);
  }

  /** 비밀번호 찾기 초기 페이지 */
  @GetMapping("/find-pw")
  public String userFindPwView() { return "user/find_pw"; }

  /** 비밀번호 찾기 인증코드 입력 페이지 */
  @GetMapping("/code-pw")
  public String userCodePwView(
      @RequestParam(value = "email", required = false) String email,
      @RequestParam(value = "userId", required = false) String userId) {

    // 주소창 세탁 후 새로고침 시 파라미터가 없어도 에러가 발생하지 않고 페이지를 보여줍니다.
    return "user/code_pw";
  }

  /** 비밀번호 변경 페이지 (인증 성공 후 진입) */
  @GetMapping("/change-pw")
  public String userChangePwView() { return "user/change_pw"; }

  /** 비밀번호 찾기 인증코드 발송 API */
  @PostMapping("/api/find-pw-code")
  @ResponseBody
  public Map<String, Object> findPwCode(@RequestBody Map<String, Object> body) {
    Map<String, Object> response = new HashMap<>();
    try {
      String code = userService.requestFindPwCode((String) body.get("userId"), (String) body.get("email"));
      response.put("resultCode", "SUCCESS");
      response.put("message", "인증 코드가 발송되었습니다.");
      response.put("authCode", code);
    } catch (Exception e) {
      response.put("resultCode", "FAIL");
      response.put("message", e.getMessage());
    }
    return response;
  }

  /** 비밀번호 찾기 인증코드 검증 API */
  @PostMapping("/api/verify-pw-code")
  @ResponseBody
  public Map<String, Object> verifyPwCode(@RequestBody Map<String, Object> body) {
    Map<String, Object> response = new HashMap<>();
    try {
      String result = userService.verifyFindPwCode((String) body.get("userId"), (String) body.get("email"), (String) body.get("code"));
      if ("SUCCESS".equals(result)) {
        response.put("resultCode", "SUCCESS");
        response.put("message", "인증이 완료되었습니다.");
      } else {
        response.put("resultCode", "FAIL");
        response.put("message", "비정상적인 접근입니다.");
      }
    } catch (Exception e) {
      response.put("resultCode", "FAIL");
      response.put("message", e.getMessage());
    }
    return response;
  }

  /** 비밀번호 찾기 절차를 통한 변경 처리 API */
  @PostMapping("/api/change-pw")
  @ResponseBody
  public Map<String, Object> changePw(@RequestBody Map<String, Object> body) {
    Map<String, Object> response = new HashMap<>();
    try {
      userService.changePassword((String) body.get("newPassword"));
      response.put("resultCode", "SUCCESS");
      response.put("message", "비밀번호가 성공적으로 변경되었습니다.");
    } catch (IllegalStateException e) {
      response.put("resultCode", "EXPIRED"); // 인증 세션 만료 등
      response.put("message", e.getMessage());
    } catch (Exception e) {
      response.put("resultCode", "FAIL");
      response.put("message", "비밀번호 변경 중 오류가 발생했습니다.");
    }
    return response;
  }

  /** 로그인된 상태(설정 메뉴)에서 비밀번호 변경 처리 API */
  @PostMapping("/api/change-pw-logged-in")
  @ResponseBody
  public Map<String, Object> changePwLoggedIn(@RequestBody Map<String, Object> body, HttpSession session) {
    Map<String, Object> response = new HashMap<>();
    String userId = (String) session.getAttribute("loggedInUser");
    if (userId == null) {
      response.put("resultCode", "FAIL");
      response.put("message", "로그인 상태가 아닙니다.");
      return response;
    }
    try {
      userService.changePassword(userId, (String) body.get("newPassword"));
      response.put("resultCode", "SUCCESS");
      response.put("message", "비밀번호가 변경되었습니다. 다시 로그인해 주세요.");
      session.invalidate(); // 보안을 위해 로그아웃 처리
    } catch (Exception e) {
      System.err.println("비밀번호 변경 오류: " + e.getMessage());
      response.put("resultCode", "ERROR");
      response.put("message", "서버 오류가 발생했습니다.");
    }
    return response;
  }

  // ==========================================================
  // 4. 프로필 정보 수정 영역 (Profile Update)
  // ==========================================================

  /** 닉네임 변경 API */
  @PostMapping("/api/change-nickname")
  @ResponseBody
  public Map<String, Object> changeNickname(@RequestBody Map<String, String> requestBody, HttpSession session) {
    Map<String, Object> response = new HashMap<>();
    String userId = (String) session.getAttribute("loggedInUser");
    String newNickname = requestBody.get("newNickname");
    if (userId == null) {
      response.put("resultCode", "FAIL");
      response.put("message", "로그인 상태가 아닙니다.");
      return response;
    }
    try {
      userService.changeNickname(userId, newNickname);
      session.setAttribute("userNickname", newNickname); // 세션 닉네임 즉시 업데이트
      response.put("resultCode", "SUCCESS");
      response.put("message", "닉네임이 성공적으로 변경되었습니다.");
    } catch (Exception e) {
      response.put("resultCode", "FAIL");
      response.put("message", e.getMessage());
    }
    return response;
  }

  /** 프로필 이미지 업로드 처리 API */
  @PostMapping("/updateProfileImage")
  @ResponseBody
  public Map<String, Object> updateProfileImage(@RequestParam("userId") String userId, @RequestParam("profileFile") MultipartFile profileFile) {
    Map<String, Object> response = new HashMap<>();
    if (profileFile.isEmpty()) {
      response.put("success", false);
      response.put("message", "파일이 선택되지 않았습니다.");
      return response;
    }
    try {
      String newFileName = userService.updateProfileImage(userId, profileFile);
      response.put("success", true);
      response.put("newFileName", newFileName);
      response.put("message", "프로필 사진이 성공적으로 변경되었습니다.");
    } catch (Exception e) {
      response.put("success", false);
      response.put("message", "파일 처리 중 오류: " + e.getMessage());
    }
    return response;
  }

  /** 전적 리셋 API (DB + 실시간 메모리 + 세션 모두 초기화) */
  @PostMapping("/api/user/reset-rank")
  @ResponseBody
  public String resetRank(HttpSession session) {
    String userId = (String) session.getAttribute("loggedInUser");
    if (userId == null || userId.isEmpty()) return "fail";
    try {
      userService.resetUserRank(userId); // 1. DB 초기화
      gameService.resetUserRank(userId); // 2. GameService 실시간 랭킹 메모리 초기화

      // 3. 세션 정보 초기화 (화면 상단 즉시 반영용)
      session.setAttribute("userWin", 0);
      session.setAttribute("userLose", 0);
      session.setAttribute("userDraw", 0);
      return "success";
    } catch (Exception e) {
      return "fail";
    }
  }

  // ==========================================================
  // 5. 회원 관리 및 탈퇴 영역 (Unregister / Records)
  // ==========================================================

  /** 회원 탈퇴 처리 API */
  @PostMapping("/api/unregister")
  @ResponseBody
  public Map<String, Object> unregisterUser(HttpSession session) {
    Map<String, Object> response = new HashMap<>();
    String userId = (String) session.getAttribute("loggedInUser");
    if (userId == null) {
      response.put("resultCode", "FAIL");
      response.put("message", "로그인 상태가 아닙니다.");
      return response;
    }
    try {
      userService.unregisterUser(userId); // DB 삭제
      gameService.removeUserFromMemory(userId); // 메모리 랭킹에서 즉시 삭제
      session.invalidate(); // 세션 종료
      response.put("resultCode", "SUCCESS");
      response.put("message", "회원 탈퇴가 완료되었습니다.");
    } catch (Exception e) {
      response.put("resultCode", "ERROR");
      response.put("message", "회원 탈퇴 처리 중 서버 오류가 발생했습니다.");
    }
    return response;
  }

  /** 회원 삭제 (DELETE 요청 호환용) */
  @DeleteMapping
  @ResponseBody
  public int userDelete(HttpServletRequest request, @RequestParam Map<String, Object> params) {
    return userService.userDelete(request, params);
  }

  /** 사용자 기록 조회 화면 */
  @GetMapping("/record")
  public String userRecord(HttpServletRequest request, @RequestParam Map<String, Object> params) {
    return userService.userRecord(request, params);
  }

  /** 사용자 기록 업데이트 처리 API */
  @PostMapping("/api/record")
  @ResponseBody
  public int userRecordUpdate(HttpServletRequest request, @RequestBody Map<String, Object> body) {
    return userService.userRecordUpdate(request, body);
  }

  /** 사용자 상세 정보 조회 (JSON/View) */
  @GetMapping("/api/info")
  public String userInfo(HttpServletRequest request, @RequestParam Map<String, Object> params, HttpSession session) {
    return userService.userInfo(request, params, session);
  }

  /** 사용자 상세 정보 업데이트 */
  @PostMapping("/api/info")
  @ResponseBody
  public int userInfoUpdate(HttpServletRequest request, @RequestBody Map<String, Object> body) {
    return userService.userInfoUpdate(request, body);
  }

  // ==========================================================
  // 6. 유틸리티 메서드 (Helper Methods)
  // ==========================================================

  /** Map에서 안전하게 문자열을 추출하는 헬퍼 메서드 */
  private String asString(Map<String, Object> params, String key) {
    Object v = params.get(key);
    return (v == null) ? "" : v.toString();
  }

  /** DB 중복 에러 메시지를 사용자용 메시지로 변환 */
  private String extractDuplicateMessage(Exception e) {
    String s = e.getMessage();
    if (s != null) {
      if (s.contains("USER_ID")) return "아이디 중복";
      if (s.contains("USER_EML")) return "이메일 중복";
      if (s.contains("USER_NICNM")) return "닉네임 중복";
    }
    return "중복 데이터가 있습니다";
  }
}