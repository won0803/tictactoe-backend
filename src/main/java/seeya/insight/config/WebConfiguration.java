package seeya.insight.config;

import seeya.insight.config.interceptor.LoginCheckInterceptor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.view.json.MappingJackson2JsonView;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.util.List;

@Configuration
public class WebConfiguration implements WebMvcConfigurer {

  @Bean
  public BCryptPasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
  }

  /**
   * 리소스 핸들러 설정
   * 경로 문제를 해결하기 위해 요청 주소와 폴더 경로를 일치시켰습니다.
   */
  @Override
  public void addResourceHandlers(ResourceHandlerRegistry registry) {
    // 1. 메인 에셋 (CSS, JS, 기본 이미지)
    // webapp/assets/ 폴더를 /assets/** 주소와 연결
    registry.addResourceHandler("/assets/**")
        .addResourceLocations("/assets/");

    // 2. 프로필 이미지 404 해결
    // 에러 로그의 요청 주소인 /upload/profile/** 을
    // 실제 폴더인 webapp/upload/profile/ 과 정확히 연결합니다.
    registry.addResourceHandler("/upload/profile/**")
        .addResourceLocations("/upload/profile/");
  }

  @Override
  public void addInterceptors(InterceptorRegistry registry) {
    registry.addInterceptor(new LoginCheckInterceptor())
        .addPathPatterns("/**")
        .excludePathPatterns(
            "/main",
            "/",
            "/game/**",
            "/ws/**",
            "/assets/**",
            "/upload/**",   // 하위 profile 폴더까지 모두 포함하여 허용
            "/favicon.ico",
            "/error"
        );
  }

  @Override
  public void addArgumentResolvers(List<HandlerMethodArgumentResolver> argumentResolvers) {
  }

  @Bean(name="jsonView")
  public MappingJackson2JsonView jsonView() {
    return new MappingJackson2JsonView();
  }
}