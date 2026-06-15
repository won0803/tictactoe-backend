package seeya.insight.user.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import jakarta.servlet.http.HttpSession;

import seeya.insight.user.domain.User;
import seeya.insight.user.service.UserService;
import seeya.insight.game.service.GameService;
import seeya.insight.game.domain.UserRank;

/**
 * 서비스의 메인 진입점과 로그인 상태에 따른 페이지 이동을 관리하는 컨트롤러입니다.
 */
@Controller
public class HomeController {

  private final UserService userService;
  private final GameService gameService;

  // 생성자 주입을 통해 비즈니스 로직(User)과 게임 로직(Game) 서비스를 연결합니다.
  public HomeController(UserService userService, GameService gameService) {
    this.userService = userService;
    this.gameService = gameService;
  }

  /**
   * [루트 경로] 서비스 접속 시 가장 먼저 호출되는 인덱스 페이지입니다.
   */
  @RequestMapping("/")
  public String homeCheck(HttpSession session) {
    return "index";
  }

  /**
   * [로그인 체크] 사용자의 세션을 확인하여 로그인 상태면 메인으로, 아니면 로그인 창으로 보냅니다.
   */
  @GetMapping("/check-login-and-go")
  public String checkLoginAndGo(HttpSession session) {
    String userId = (String) session.getAttribute("loggedInUser");

    if (userId != null) {
      return "redirect:/main"; // 로그인 상태: 메인 화면으로 리다이렉트
    } else {
      return "redirect:/user/login"; // 비로그인 상태: 로그인 페이지로 리다이렉트
    }
  }

  /**
   * [메인 대시보드] 유저의 프로필 정보와 실시간 게임 전적을 모아 보여주는 핵심 페이지입니다.
   */
  @GetMapping("/main")
  public String main(HttpSession session, Model model) {
    // 1. 세션에서 현재 로그인한 사용자 ID를 가져옵니다.
    String userId = (String) session.getAttribute("loggedInUser");
    String contextPath = session.getServletContext().getContextPath();

    // 로그인 정보가 없으면 보호를 위해 로그인 페이지로 튕겨냅니다.
    if (userId == null) {
      return "redirect:/user/login";
    }

    try {
      // 2. DB에서 사용자 기본 프로필(ID, 닉네임, 아이콘 파일명 등)을 조회합니다.
      User userProfile = userService.findUserProfile(userId);

      if (userProfile != null) {
        // 3. [핵심 로직] GameService의 메모리(Map)에 저장된 최신 전적을 가져옵니다.
        // DB 전적보다 메모리 전적이 더 빈번하게 갱신되므로 이 값을 우선 사용합니다.
        UserRank realTimeRank = gameService.getUserRank(userId);

        if (realTimeRank != null) {
          // [방법 A] 기존 User 객체 내부 필드에 값을 할당하여 호환성을 유지합니다.
          userProfile.setWinCount(realTimeRank.getWins());
          userProfile.setLoseCount(realTimeRank.getLosses());
          userProfile.setDrawCount(realTimeRank.getDraws());

          // [방법 B] JSP에서 ${myWin} 형태로 즉시 접근할 수 있도록 Model에 개별 등록합니다. (가장 확실한 전달)
          model.addAttribute("myWin", realTimeRank.getWins());
          model.addAttribute("myLose", realTimeRank.getLosses());
          model.addAttribute("myDraw", realTimeRank.getDraws());

          System.out.println("[Main화면 전적로드] 유저: " + userId + " | " +
              realTimeRank.getWins() + "승 " + realTimeRank.getLosses() + "패 " + realTimeRank.getDraws() + "무");
        } else {
          // 게임 기록이 전혀 없는 신규 유저 등을 위해 기본값 0을 세팅합니다.
          model.addAttribute("myWin", 0);
          model.addAttribute("myLose", 0);
          model.addAttribute("myDraw", 0);
        }

        // 4. 프로필 이미지 경로 결정 (업로드된 아이콘이 있으면 해당 경로, 없으면 기본 이미지)
        String userIconPath;
        if (userProfile.getUserIcon() != null && !userProfile.getUserIcon().isEmpty()) {
          userIconPath = contextPath + "/upload/profile/" + userProfile.getUserIcon();
        } else {
          userIconPath = contextPath + "/assets/images/profile_icon.png";
        }

        // 5. 최종적으로 JSP(뷰)에서 사용할 데이터들을 Model에 담습니다.
        model.addAttribute("userId", userId);
        model.addAttribute("userNickname", userProfile.getNickname());
        model.addAttribute("userIconPath", userIconPath);
        model.addAttribute("userProfile", userProfile); // 객체 통째로 전달
      }
    } catch (Exception e) {
      // 예외 발생 시 서버 중단을 막고 로그를 남깁니다.
      System.err.println("메인 페이지 데이터 로딩 중 오류 발생: " + e.getMessage());
    }

    return "main"; // main.jsp를 호출하여 화면을 그립니다.
  }
}