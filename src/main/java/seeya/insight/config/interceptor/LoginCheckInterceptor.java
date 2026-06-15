package seeya.insight.config.interceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.web.servlet.HandlerInterceptor;

public class LoginCheckInterceptor implements HandlerInterceptor {

  @Override
  public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {

    HttpSession session = request.getSession(false);

    // ⭐️ 수정된 핵심 로직: 세션 키 이름을 "loggedInUser"로 사용합니다. ⭐️
    if (session != null && session.getAttribute("loggedInUser") != null) {

      String requestURI = request.getRequestURI();

      // 로그인, 회원가입 등 인증 관련 경로 리스트
      if (requestURI.startsWith("/user/login") ||
          requestURI.startsWith("/user/sign-up") ||
          requestURI.startsWith("/user/find-id") ||
          requestURI.startsWith("/user/find-pw") ||
          requestURI.startsWith("/user/join") ||
          requestURI.startsWith("/user/code-id") ||
          requestURI.startsWith("/user/code-pw") ||
          requestURI.startsWith("/user/change-pw") ||
          requestURI.startsWith("/user/auth-code")) {

        System.out.println("[Interceptor] 로그인 사용자 접근 차단: " + requestURI + " -> /main으로 리다이렉트");

        // 로그인 상태이므로 메인 페이지로 강제 리다이렉트
        response.sendRedirect("/main");

        // 요청 처리를 중단합니다. (컨트롤러로 넘어가지 않음)
        return false;
      }
    }

    // 로그인 상태가 아니거나, 차단할 페이지가 아니면 정상 진행
    return true;
  }
}