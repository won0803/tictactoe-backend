package seeya.insight.user.service;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;
import seeya.insight.game.domain.GameRoom;
import seeya.insight.game.domain.UserRank;
import seeya.insight.user.domain.User;
import seeya.insight.user.mapper.UserMapper;

import java.io.File;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.UUID;

@Service
public class UserService {

  private final UserMapper userMapper;
  private final BCryptPasswordEncoder passwordEncoder;

  /**
   * 생성자 주입: Spring Security의 BCryptPasswordEncoder를 주입받아
   * 비밀번호 암호화 및 대조에 사용합니다.
   */
  public UserService(UserMapper userMapper, BCryptPasswordEncoder passwordEncoder) {
    this.userMapper = userMapper;
    this.passwordEncoder = passwordEncoder;
  }

  // ==========================================================
  // 1. 회원가입 및 유효성 검사 (Join)
  // ==========================================================

  @Transactional
  public void join(String userId, String password, String nickname, String email) {
    // 필수 값 및 길이 검증
    if (isBlank(userId) || isBlank(password) || isBlank(nickname) || isBlank(email)) {
      throw new IllegalArgumentException("필수 값 누락");
    }
    if (userId.length() > 10) throw new IllegalArgumentException("아이디 길이 초과");
    if (password.length() > 10) throw new IllegalArgumentException("비밀번호 길이 초과");
    if (nickname.length() > 10) throw new IllegalArgumentException("닉네임 길이 초과");
    if (email.length() > 50) throw new IllegalArgumentException("이메일 길이 초과");

    // 중복 체크
    if (userMapper.existsByUsername(userId)) throw new IllegalStateException("아이디 중복");
    if (userMapper.existsByEmail(email)) throw new IllegalStateException("이메일 중복");
    if (userMapper.existsByNickname(nickname)) throw new IllegalStateException("닉네임 중복");

    // BCrypt 암호화 적용
    String hashed = passwordEncoder.encode(password);
    User u = new User();
    u.setUserId(userId);
    u.setPassword(hashed);
    u.setNickname(nickname);
    u.setEmail(email);

    if (userMapper.insert(u) != 1) throw new IllegalStateException("회원가입 실패");
  }

  /** 기존 Map 형태의 가입 폼 처리 메서드 */
  @Transactional
  public int userJoinForm(Map<String, Object> body) {
    String userId = (String) body.get("userId");
    String email = (String) body.get("email");
    String password = (String) body.get("password");
    String nickname = (String) body.get("nickname");

    if (isBlank(userId) || isBlank(email) || isBlank(password) || isBlank(nickname)) return 0;
    if (userId.length() > 20 || email.length() > 20 || nickname.length() > 20 || password.length() > 200) return 0;
    if (userMapper.existsByUsername(userId) || userMapper.existsByEmail(email) || userMapper.existsByNickname(nickname)) return 0;

    User u = new User();
    u.setUserId(userId);
    u.setPassword(passwordEncoder.encode(password)); // 암호화 저장
    u.setEmail(email);
    u.setNickname(nickname);
    return userMapper.insert(u);
  }

  // ==========================================================
  // 2. 로그인 및 세션 관리 (Auth)
  // ==========================================================

  /** 로그인 페이지 이동용 */
  public String userLoginView(HttpServletRequest request, Map<String, Object> params) {
    return "user/login";
  }

  /** 기존 컨트롤러 호출용 로그인 메서드 (BCrypt 대조 포함) */
  @Transactional(readOnly = true)
  public String userLogin(HttpServletRequest request, Map<String, Object> body) {
    String username = (String) body.get("username");
    String rawPassword = (String) body.get("password");
    if (isBlank(username) || isBlank(rawPassword)) return "redirect:/login?error";

    User u = userMapper.findByUsername(username);
    // passwordEncoder.matches(평문, 암호문)으로 비밀번호 검증
    if (u == null || !passwordEncoder.matches(rawPassword, u.getPassword())) return "redirect:/login?error";

    HttpSession session = request.getSession(true);
    session.setAttribute("userId", u.getUserId());
    session.setAttribute("nickname", u.getNickname());
    return "redirect:/";
  }

  /** 아이디 기반 로그인 처리 및 세션 저장 */
  public User login(String userId, String rawPassword) {
    User user = userMapper.findByUserId(userId);
    if (user == null || !passwordEncoder.matches(rawPassword, user.getPassword())) {
      throw new IllegalArgumentException("아이디 또는 비밀번호가 올바르지 않습니다.");
    }
    HttpSession session = getSession(true);
    session.setAttribute("loggedInUser", user.getUserId());
    session.setAttribute("userNickname", user.getNickname());
    session.setMaxInactiveInterval(60 * 30); // 30분 세션 유지
    return user;
  }

  /** 로그아웃 처리 */
  public String userLogout(HttpServletRequest request, Map<String, Object> params) {
    HttpSession session = request.getSession(false);
    if (session != null) session.invalidate();
    return "redirect:/";
  }

  // ==========================================================
  // 3. 아이디 및 비밀번호 찾기 (Find)
  // ==========================================================

  /** 아이디 찾기 화면 이동 */
  public String userFindId(HttpServletRequest request, Map<String, Object> params) {
    return "user/find_id";
  }

  /** 비밀번호 찾기 화면 이동 */
  public String userFindPw(HttpServletRequest request, Map<String, Object> params) {
    return "user/find_pw";
  }

  /** 이메일 인증코드 생성 및 세션 저장 (아이디 찾기용) */
  @Transactional(readOnly = true)
  public String requestFindIdCode(String email) {
    if (!userMapper.existsByEmail(email)) throw new IllegalStateException("해당 이메일 사용자를 찾을 수 없습니다.");
    String authCode = generateRandomCode();
    HttpSession session = getSession(true);
    session.setAttribute("findIdEmail_" + email.toLowerCase(), authCode);
    session.setMaxInactiveInterval(5 * 60); // 5분 유효
    System.out.println("★ FIND ID CODE: " + authCode);
    return authCode;
  }

  /** 입력된 인증코드 검증 */
  public void verifyFindIdCode(String email, String inputCode) {
    HttpSession session = getSession(false);
    if (session == null) throw new IllegalStateException("인증 시간이 만료되었습니다.");
    String storedCode = (String) session.getAttribute("findIdEmail_" + email.toLowerCase());
    if (storedCode == null || !storedCode.equals(inputCode)) throw new IllegalStateException("인증 코드가 일치하지 않습니다.");

    session.setAttribute("idCodeVerifiedEmail", email.toLowerCase());
    session.removeAttribute("findIdEmail_" + email.toLowerCase());
  }

  /** 인증 성공 후 아이디 확인 페이지 로직 */
  public String findUserIdAfterVerification(String paramEmail, Map<String, Object> model) {
    HttpSession session = getSession(false);
    if (session == null) return "redirect:/user/login";
    String verifiedEmail = (String) session.getAttribute("idCodeVerifiedEmail");
    if (isBlank(verifiedEmail) || !verifiedEmail.equalsIgnoreCase(paramEmail)) return "redirect:/user/find-id";

    User user = userMapper.findByEmail(verifiedEmail);
    session.removeAttribute("idCodeVerifiedEmail");
    model.put("foundUserId", user.getUserId());
    model.put("userNickname", user.getNickname());
    return "user/check_id";
  }

  /** 비밀번호 찾기용 인증코드 발송 */
  @Transactional(readOnly = true)
  public String requestFindPwCode(String userId, String email) {
    if (!userMapper.existsByUserIdAndEmail(userId, email)) throw new IllegalStateException("아이디와 이메일 정보가 일치하지 않습니다.");
    String authCode = generateRandomCode();
    HttpSession session = getSession(true);
    session.setAttribute("findPwCode_" + userId.toLowerCase() + "_" + email.toLowerCase(), authCode);
    return authCode;
  }

  /** 비밀번호 변경 권한 검증 */
  public String verifyFindPwCode(String userId, String email, String code) {
    HttpSession session = getSession(false);
    String sessionKey = "findPwCode_" + userId.toLowerCase() + "_" + email.toLowerCase();
    String storedCode = (session != null) ? (String) session.getAttribute(sessionKey) : null;
    if (isBlank(storedCode) || !storedCode.equals(code)) throw new IllegalArgumentException("인증 코드가 틀렸습니다.");

    session.removeAttribute(sessionKey);
    session.setAttribute("pwCodeVerifiedInfo", userId + ":" + email);
    session.setMaxInactiveInterval(60 * 5); // 5분 내 변경 필요
    return "SUCCESS";
  }

  /** 인증 세션을 통한 비밀번호 변경 (비밀번호 찾기 프로세스) */
  @Transactional
  public void changePassword(String newRawPassword) {
    HttpSession session = getSession(false);
    String verifiedInfo = (session != null) ? (String) session.getAttribute("pwCodeVerifiedInfo") : null;
    if (isBlank(verifiedInfo)) throw new IllegalStateException("비밀번호 변경 권한이 없습니다.");

    if (newRawPassword.length() < 1 || newRawPassword.length() > 10) throw new IllegalArgumentException("비밀번호 길이 제한 초과");

    String userId = verifiedInfo.split(":")[0];
    userMapper.updatePasswordByUserId(userId, passwordEncoder.encode(newRawPassword));
    session.removeAttribute("pwCodeVerifiedInfo");
  }

  /** 로그인 상태에서 비밀번호 직접 변경 */
  @Transactional
  public void changePassword(String userId, String newPassword) {
    if (newPassword == null || newPassword.length() < 1 || newPassword.length() > 10) throw new IllegalArgumentException("길이 부적합");
    userMapper.updatePasswordByUserId(userId, passwordEncoder.encode(newPassword));
  }

  // ==========================================================
  // 4. 정보 조회 및 마이페이지 (Profile)
  // ==========================================================

  /** 회원 정보 조회 페이지 데이터 준비 */
  @Transactional(readOnly = true)
  public String userInfo(HttpServletRequest request, Map<String, Object> params, HttpSession session) {
    String userId = (String) session.getAttribute("userId");
    if (isBlank(userId)) return "user/login";
    User u = userMapper.findByUserId(userId);
    if (u == null) return "user/not-found";
    request.setAttribute("user", u);
    return "user/info";
  }

  /** 마이페이지 정보 수정 (닉네임, 이메일, 비밀번호) */
  @Transactional
  public int userInfoUpdate(HttpServletRequest request, Map<String, Object> body) {
    HttpSession session = request.getSession();
    String userId = (String) session.getAttribute("userId");
    if (isBlank(userId)) return 0;
    User u = userMapper.findByUserId(userId);
    if (u == null) return 0;

    String nickname = (String) body.get("nickname");
    String email = (String) body.get("email");
    String password = (String) body.get("password");

    if (nickname != null) {
      if (nickname.length() > 20 || (!nickname.equals(u.getNickname()) && userMapper.existsByNickname(nickname))) return 0;
      u.setNickname(nickname);
    }
    if (email != null) {
      if (email.length() > 20 || (!email.equals(u.getEmail()) && userMapper.existsByEmail(email))) return 0;
      u.setEmail(email);
    }
    if (!isBlank(password)) u.setPassword(passwordEncoder.encode(password));
    return userMapper.update(u);
  }

  /** 프로필 이미지 업로드 및 서버 저장 */
  @Transactional
  public String updateProfileImage(String userId, MultipartFile file) throws Exception {
    String uploadDir = "C:\\Users\\lwc46\\Downloads\\01_TTT\\2024cms\\src\\main\\webapp\\upload\\profile";
    File dir = new File(uploadDir);
    if (!dir.exists()) dir.mkdirs();

    String originalFilename = file.getOriginalFilename();
    String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
    String newFileName = UUID.randomUUID().toString() + extension;

    File dest = new File(uploadDir, newFileName);
    file.transferTo(dest);

    User user = new User();
    user.setUserId(userId);
    user.setUserIcon(newFileName);
    if (userMapper.updateUserIcon(user) == 0) {
      dest.delete();
      throw new Exception("DB 반영 실패");
    }
    return newFileName;
  }

  /** 닉네임 변경 (중복 체크 포함) */
  @Transactional
  public void changeNickname(String userId, String newNickname) {
    if (isBlank(newNickname) || newNickname.length() > 10) throw new IllegalArgumentException("닉네임 형식 부적합");
    if (userMapper.existsNicknameExcludingUser(newNickname, userId)) throw new IllegalArgumentException("이미 사용 중인 닉네임");
    userMapper.updateNickname(userId, newNickname);
  }

  // ==========================================================
  // 5. 전적 및 계정 관리 (Record & Delete)
  // ==========================================================

  /** 전적 페이지 이동 */
  public String userRecord(HttpServletRequest request, Map<String, Object> params) {
    return "user/record";
  }

  /** 전적 업데이트 요청 처리 */
  public int userRecordUpdate(HttpServletRequest request, Map<String, Object> body) {
    return 1; // 추후 로직 구현 예정
  }

  /** 특정 사용자의 전적 조회 */
  public User getUserRecord(String userId) {
    return userMapper.findUserRecordByUserId(userId);
  }

  /** 회원 탈퇴 처리 (기본 API) */
  @Transactional
  public int userDelete(HttpServletRequest request, Map<String, Object> params) {
    String userId = (String) request.getSession().getAttribute("userId");
    return (userId == null) ? 0 : userMapper.delete(userId);
  }

  /** 회원 탈퇴 처리 (전적 데이터까지 포함) */
  @Transactional
  public void unregisterUser(String userId) {
    if (userId == null) throw new IllegalArgumentException("ID 유효하지 않음");
    userMapper.deleteUserRankByUserId(userId);
    if (userMapper.delete(userId) == 0) throw new IllegalStateException("사용자 삭제 실패");
  }

  /** 사용자 랭크 데이터 초기화 */
  @Transactional
  public void resetUserRank(String userId) {
    userMapper.resetUserRank(userId);
  }

  // ==========================================================
  // 6. 내부 유틸리티 및 매퍼 위임 메서드
  // ==========================================================

  /** GameService 연동용 유저 프로필 조회 */
  public User findUserProfile(String userId) { return userMapper.findUserProfile(userId); }

  /** 문자열 비어있는지 확인 */
  private boolean isBlank(String s) { return s == null || s.trim().isEmpty(); }

  /** 6자리 랜덤 인증 코드 생성 */
  private String generateRandomCode() { return String.valueOf(100000 + new Random().nextInt(900000)); }

  /** 세션 객체 획득 공통 메서드 */
  private HttpSession getSession(boolean create) {
    ServletRequestAttributes attr = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
    return (attr != null) ? attr.getRequest().getSession(create) : null;
  }

  // 매퍼 데이터 직접 위임
  public List<UserRank> findAllUserRanks() { return userMapper.findAllUserRanks(); }
  public void upsertUserRank(UserRank rank) { userMapper.upsertUserRank(rank); }
  public List<GameRoom> findAllActiveRooms() { return userMapper.findAllActiveRooms(); }
  public void insertGameRoom(GameRoom room) { userMapper.insertGameRoom(room); }
  public void updateGameRoom(GameRoom room) { userMapper.updateGameRoom(room); }
}