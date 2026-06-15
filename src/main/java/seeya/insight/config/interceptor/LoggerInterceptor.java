package seeya.insight.config.interceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.log4j.Log4j2;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

@Log4j2
public class LoggerInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {


        return HandlerInterceptor.super.preHandle(request, response, handler);
    }

    /*
        - 컨트롤러를 경유(접근) 한 후, 즉 화면(View)으로 결과를 전달하기 전에 실행되는 메서드
        - preHandle()과는 반대로 요청(Request)의 끝을 알리는 로그가 콘솔에 출력되도록 처리
     */
    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
        if (log.isDebugEnabled()) {
            log.debug("======================================    END(postHandle)    ======================================");
        }
        HandlerInterceptor.super.postHandle(request, response, handler, modelAndView);
    }

    /*
        - Controller에서 요청이 다 마무리되고, View로 Rendering이 다 끝나면 처리
     */
    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        if (log.isDebugEnabled()) {
            log.debug("======================================     END(afterCompletion)     ======================================\n");
        }
        HandlerInterceptor.super.afterCompletion(request, response, handler, ex);
    }
}
