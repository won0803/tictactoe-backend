package seeya.insight.user.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import seeya.insight.game.domain.GameRoom;
import seeya.insight.game.domain.UserRank;
import seeya.insight.user.domain.User;
import java.util.List;

@Mapper
public interface UserMapper {

  /* ==========================================================
   * 1. 유저 계정 기본 관리 (CRUD)
   * ========================================================== */

  // [CREATE] 신규 유저 회원가입
  int insert(User user);

  // [READ] PK(아이디)로 유저 정보 조회
  User findByUserId(String userId);

  // [READ] 모든 유저 리스트 조회 (관리용)
  List<User> findAll();

  // [UPDATE] 유저 전체 정보 수정
  int update(User user);

  // [DELETE] 회원 탈퇴 (유저 테이블에서 삭제)
  int delete(@Param("id") String id);


  /* ==========================================================
   * 2. 로그인 및 계정 찾기 / 중복 검사
   * ========================================================== */

  // 아이디와 이메일이 일치하는 사용자가 있는지 확인 (비밀번호 찾기용)
  boolean existsByUserIdAndEmail(@Param("userId") String userId, @Param("email") String email);

  // 이메일 중복 확인
  boolean existsByEmail(@Param("value") String email);

  // 아이디(Username) 중복 확인
  boolean existsByUsername(@Param("value") String username);

  // 닉네임 중복 확인
  boolean existsByNickname(@Param("value") String nickname);

  // [중복 주의] findByUsername과 findByUserId는 내부 로직에 따라 하나로 통일 가능합니다.
  User findByUsername(@Param("username") String username);
  User findByEmail(String email);


  /* ==========================================================
   * 3. 비밀번호 및 보안
   * ========================================================== */

  // 비밀번호 변경 (아이디 기준)
  int updatePasswordByUserId(@Param("userId") String userId, @Param("newPassword") String newPassword);


  /* ==========================================================
   * 4. 프로필 및 닉네임 관리
   * ========================================================== */

  // 프로필 조회 (닉네임, 아이콘 포함)
  User findUserProfile(String userId);

  // 닉네임 업데이트
  int updateNickname(@Param("userId") String userId, @Param("newNickname") String newNickname);

  // 본인을 제외한 다른 사람이 해당 닉네임을 쓰고 있는지 확인 (닉네임 수정 시 필수)
  boolean existsNicknameExcludingUser(@Param("newNickname") String newNickname, @Param("userId") String userId);

  // 유저 아이콘(프로필 사진) 경로 업데이트
  int updateUserIcon(User user);


  /* ==========================================================
   * 5. 게임 및 랭킹 데이터 (실시간 연동)
   * ========================================================== */

  // 전체 사용자의 랭킹 정보를 리스트로 조회
  List<UserRank> findAllUserRanks();

  // 랭킹 정보 저장 또는 수정 (승패 기록 업데이트)
  void upsertUserRank(UserRank rank);

  // 특정 유저의 전적 리셋 (0승 0패 0무)
  void resetUserRank(String userId);

  // 회원 탈퇴 시 해당 유저의 랭킹 기록도 함께 삭제
  int deleteUserRankByUserId(@Param("userId") String userId);

  // 특정 유저의 전적 정보만 집중 조회
  User findUserRecordByUserId(String userId);


  /* ==========================================================
   * 6. 게임방(Room) 관련 DB 연동
   * ========================================================== */

  // 현재 활성화된(종료되지 않은) 모든 게임방 조회
  List<GameRoom> findAllActiveRooms();

  // 신규 게임방 정보 저장
  void insertGameRoom(GameRoom room);

  // 게임방 상태(진행중/종료), 턴, 보드 데이터 업데이트
  void updateGameRoom(GameRoom room);

}