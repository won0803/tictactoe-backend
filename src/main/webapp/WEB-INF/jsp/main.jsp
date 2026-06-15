<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">

<script src="https://unpkg.com/sweetalert/dist/sweetalert.min.js"></script>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <script src="${pageContext.request.contextPath}/assets/js/jquery-3.6.0.min.js"></script>

    <title>PLAY TTT!</title>

</head>

<body>
<!-- 공통::팝업 -->
<div class="popup-contents guide-contents fixed popup-down">
    <div class="popup-inner guide-inner bounce-out">
        <input type="button" value="×" id="close-btn" class="close-btn transition-fade">
        <div class="guide-slide">
            <button class="guide-nav guide-prev">
                <img src="${pageContext.request.contextPath}/assets/images/icon-prev.svg" alt="이전">
            </button>
            <div class="guide-slide-inner">
                <div class="guide-inner1">
                    <div class="guide-inner-img flex-box item-center just-center">
                        <img src="${pageContext.request.contextPath}/assets/images/frame/guide-1.png" alt="가이드1" class="center">
                    </div>
                    <p>플레이! 틱택토는 실시간 통신으로 진행 됩니다.</p>
                </div>
                <div class="guide-inner2">
                    <div class="guide-inner-img flex-box item-center just-center">
                        <img src="${pageContext.request.contextPath}/assets/images/frame/guide-2.png" alt="가이드2" class="center">
                    </div>
                    <p>로그인에 성공하면 게임에 참여 하거나 직접 방을 만들 수 있습니다.</p>
                </div>
                <div class="guide-inner3">
                    <div class="guide-inner-img flex-box item-center just-center">
                        <img src="${pageContext.request.contextPath}/assets/images/frame/guide-3.png" alt="가이드3" class="center">
                    </div>
                    <p>O가 선공, X는 후공입니다. 번갈아가며 칸을 채워주세요.</p>
                </div>
                <div class="guide-inner4">
                    <div class="guide-inner-img flex-box item-center just-center">
                        <img src="${pageContext.request.contextPath}/assets/images/frame/guide-4.png" alt="가이드4" class="center">
                    </div>
                    <p>먼저 가로, 세로, 대각선 3칸을 채우는 플레이어가 우승합니다.</p>
                </div>
                <div class="guide-inner5">
                    <div class="guide-inner-img flex-box item-center just-center">
                        <img src="${pageContext.request.contextPath}/assets/images/frame/guide-5.png" alt="가이드5" class="center">
                    </div>
                    <p>승률을 올려 랭킹에 도전해보세요!</p>
                </div>
            </div>
            <button class="guide-nav guide-next">
                <img src="${pageContext.request.contextPath}/assets/images/icon-next.svg" alt="다음">
            </button>
        </div>
    </div>
</div>
<!-- 공통::가이드버튼 -->
<div class="guide-wrap">
    <button type="button" class="guide-btn" id="guideBtn">?</button>
</div>

<div class="popup-contents creatRoom-contents common-popup popup-down">
    <div class="popup-inner center">
        <input type="button" value="×" class="close-btn transition-fade">
        <p>새로운 방의 이름을 정해주세요.</p>
        <div class="form-box">
            <div class="input-box">
                <div class="input-wrap">
                    <input type="text" placeholder="문자종류 상관없이 최대 20자리." id="roomName" maxlength="20" class="center">
                </div>
            </div>
        </div>
        <input type="button" value="CREATE!" id="newRoomSubmit" class="btn btn-primary"
              >
    </div>
</div>

<div class="popup-contents rename-contents common-popup">
    <div class="popup-inner center">
        <input type="button" value="×" class="close-btn transition-fade">
        <p>변경 할 닉네임을 적어주세요.</p>
        <div class="form-box">
            <div class="input-box">
                <div class="input-wrap">
                    <input type="text" placeholder="문자종류 상관없이 최대 10자리." id="addNickname" maxlength="10" class="center">
                </div>
            </div>
        </div>
        <form id="changePasswordForm">
            <input type="button" value="완료" id="nicknameChangeSubmit"
                   class="btn btn-primary" onclick="changeNicknameSubmit()">
        </form>
    </div>
</div>


<div class="popup-contents setting-contents common-popup popup-down">
    <div class="popup-inner center setting-btn-list">
        <input type="button" value="×" class="close-btn transition-fade">
        <input type="button" value="비밀번호 변경하기" id="callPWchange" class="btn btn-light">

        <input type="button" value="전적 리셋하기" id="resetScore-btn" class="btn btn-light" onclick="executeScoreReset()">

        <input type="button" value="로그아웃" id="logoutBtn" class="btn btn-light">

        <input type="button" value="회원탈퇴" id="remveUser-btn" class="btn btn-thin" onclick="userUnregisterFinal()">
    </div>
</div>

<div class="popup-contents pw-change-contents common-popup">
    <div class="popup-inner center">
        <input type="button" value="×" class="close-btn transition-fade">

        <form id="pwChangeSubmitForm">
            <div class="form-box">
                <div class="input-box">
                    <div class="input-label">
                        <label for="addPW">비밀번호</label>
                    </div>
                    <div class="input-wrap flex-box item-center just-between">
                        <input type="password" placeholder="문자종류 상관없이 최대 10자리." id="addPW" maxlength="10">
                        <img src="${pageContext.request.contextPath}/assets/images/icon-pw.svg" alt="비밀번호" class="icon">
                    </div>

                    <div class="input-label">
                        <label for="addPWcheck">비밀번호 확인</label>
                    </div>
                    <div class="input-wrap flex-box item-center just-between">
                        <input type="password" placeholder="비밀번호 확인" id="addPWcheck" maxlength="10">
                        <img src="${pageContext.request.contextPath}/assets/images/icon-pw.svg" alt="비밀번호 확인" class="icon">
                    </div>
                </div>
            </div>
            <input type="submit" value="완료" id="realPwChangeSubmit" class="btn btn-primary">
        </form>

    </div>
</div>


<section id="main" class="section">
    <div class="header">
        <h1>
            <a href="${pageContext.request.contextPath}/">
                <img src="${pageContext.request.contextPath}/assets/images/main-logo.png" alt="메인로고">
            </a>
        </h1>
    </div>
</section>
    <div class="inner">
        <div class="title-graphic">
            <img src="${pageContext.request.contextPath}/assets/images/obj-left.png" alt="장식" class="obj-left">
            <img src="${pageContext.request.contextPath}/assets/images/obj-right.png" alt="장식" class="obj-right">
        </div>
        <div class="user-area area-box">
            <div class="user-wrap flex-box gap-40 item-center">
                <div class="user-icon">
                    <div class="user-icon-img">
                        <img id="profileImage"
                             src="${userIconPath}" alt="프로필 이미지">
                    </div>

                    <label for="editIcon" class="edit-file-btn edit-icon">
                        <img src="${pageContext.request.contextPath}/assets/images/icon-input.svg" alt="편집">
                        <input type="file" accept="image/*" id="editIcon" name="editIcon" onchange="uploadProfileImage(this)">
                    </label>
                </div>
                <div class="user-infor">
                    <div class="user-name-box">
                        <span class="user-name">${userNickname}</span>
                        <button type="button" class="edit-btn" id="editName" onclick="openNicknameChangeModal()">
                            <img src="${pageContext.request.contextPath}/assets/images/icon-input.svg" alt="편집">
                        </button>
                    </div>

                    <div class="ranker-score user-record-badge">
                        ${myWin}승 ${myLose}패 ${myDraw}무
                    </div>

                </div>
            <button type="button" class="setting-btn" id="settingCall">
                <img src="${pageContext.request.contextPath}/assets/images/icon-setting.svg" alt="설정">
            </button>
        </div>
    </div>
    <div class="flex-box row just-between">
        <div class="game-list-wrap area-box">
            <div class="game-list-controls flex-box just-between">
                <div class="flex-box gap-15 item-center">
                    <h2>GAME LIST</h2>
                    <button type="button" id="reloadBtn">
                        <img src="${pageContext.request.contextPath}/assets/images/icon-refresh.svg" alt="방 정보 불러오기">
                    </button>
                </div>
                <input type="button" value="CREATE ROOM" id="creatRoomBtn"
                       class="frame-light-btn creatRoom-btn">
            </div>
            <ul class="game-list">
                <li>
                    <div class="flex-box just-between">
                        <div class="room-infor flex-box column just-between">
                            <div>
                                <div class="room-name-wrap">
                                    <div class="room-name">ROOM-NAME</div>
                                    <span class="room-states state-wait">대기중</span>
                                </div>
                                <div class="room-manager">MANAGER-NAME</div>
                            </div>
                            <button type="button" class="joingame-btn"
                                    onclick="location.href='game_room.html'">JOIN GAME</button>
                        </div>
                        <div class="room-stage">
                            <div class="room-stage-box box-dark">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-light">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-dark">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-light">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-dark">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-light">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-dark">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-light">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-dark">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                        </div>
                    </div>
                </li>
                <li>
                    <div class="flex-box just-between">
                        <div class="room-infor flex-box column just-between">
                            <div>
                                <div class="room-name-wrap">
                                    <div class="room-name">ROOM-NAME</div>
                                    <span class="room-states state-active">진행중</span>
                                </div>
                                <div class="room-manager">MANAGER-NAME</div>
                            </div>
                            <button type="button" class="joingame-btn disabled-btn">JOIN GAME</button>
                        </div>
                        <div class="room-stage">
                            <div class="room-stage-box box-dark">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-light">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-dark">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-light">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-dark">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-light">
                                <img src="${pageContext.request.contextPath}/assets/images//obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-dark">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-light">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-dark">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                        </div>
                    </div>
                </li>
                <li>
                    <div class="flex-box just-between">
                        <div class="room-infor flex-box column just-between">
                            <div>
                                <div class="room-name-wrap">
                                    <div class="room-name">ROOM-NAME</div>
                                    <span class="room-states state-end">게임종료</span>
                                </div>
                                <div class="room-manager">MANAGER-NAME</div>
                            </div>
                            <button type="button" class="joingame-btn disabled-btn">JOIN GAME</button>
                        </div>
                        <div class="room-stage">
                            <div class="room-stage-box box-dark">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-light">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-dark">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-light">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-dark">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-light">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-dark">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-light">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                            <div class="room-stage-box box-dark">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-circle-hevy.svg" class="hide" alt="O">
                                <img src="${pageContext.request.contextPath}/assets/images/obj-cross-hevy.svg" class="hide" alt="X">
                            </div>
                        </div>
                    </div>
                </li>
            </ul>
            <div class="pagination">
                <ul class="flex-box gap-15 just-center item-center">
                </ul>
            </div>
        </div>
        <div class="ranking-wrap area-box">
            <h2>RANKING</h2>
            <ol class="ranking-list">
                <li class="first-rank" style="display:none;">
                    <div class="user-icon">
                        <div class="user-icon-img">
                            <img src="${pageContext.request.contextPath}/assets/images/profile_icon.png" id="firstRankImg" alt="프로필 사진">
                        </div>
                        <div class="first-num rank-num">1</div>
                    </div>
                    <div class="ranker-info">
                        <div class="ranker-name">USER-NAME</div>
                        <div class="ranker-score">0승 0패 0무</div>
                    </div>
                </li>
                <li class="flex-box gap-20 item-center rank-item" style="display:none;">
                    <div class="second-num rank-num">2</div>
                    <div class="ranker-info">
                        <div class="ranker-name">USER-NAME</div>
                        <div class="ranker-score">0승 0패 0무</div>
                    </div>
                </li>
                <li class="flex-box gap-20 item-center rank-item" style="display:none;">
                    <div class="third-num rank-num">3</div>
                    <div class="ranker-info">
                        <div class="ranker-name">USER-NAME</div>
                        <div class="ranker-score">0승 0패 0무</div>
                    </div>
                </li>
                <li class="flex-box gap-20 item-center rank-item" style="display:none;">
                    <div class="forth-num rank-num">4</div>
                    <div class="ranker-info">
                        <div class="ranker-name">USER-NAME</div>
                        <div class="ranker-score">0승 0패 0무</div>
                    </div>
                </li>
                <li class="flex-box gap-20 item-center rank-item" style="display:none;">
                    <div class="fifth-num rank-num">5</div>
                    <div class="ranker-info">
                        <div class="ranker-name">USER-NAME</div>
                        <div class="ranker-score">0승 0패 0무</div>
                    </div>
                </li>
            </ol>
        </div>
    </div>
    </div>
</section>

<script>
    /**
     * [1. 초기 설정 및 URL 파라미터 처리]
     * 페이지 로드 시 사용자 ID를 세션에 저장하고 주소창을 깔끔하게 정리합니다.
     */
    const ctx = '${pageContext.request.contextPath}';
    const urlParams = new URLSearchParams(window.location.search);
    const userId = urlParams.get('userId') || sessionStorage.getItem('currentUserId');

    if (urlParams.get('userId')) {
        // URL에 userId가 있으면 세션에 저장 (로그인 유지 효과)
        sessionStorage.setItem('currentUserId', userId);
        if (window.history.replaceState) {
            // 주소창에서 userId 파라미터를 숨겨서 보안성 향상
            window.history.replaceState({}, null, window.location.pathname);
        }
    }

    /**
     * [2. 실시간 데이터 동기화 기능]
     * 서버에서 최신 랭킹 리스트를 가져와 화면의 랭킹 영역과 내 전적 배지를 갱신합니다.
     */
    function fetchRankingsAndProfile() {
        fetch('http://localhost:8115/game/rank/list')
            .then(response => response.json())
            .then(rankList => {
                const rankItems = document.querySelectorAll('.ranking-list > li');
                const currentLoginId = "${userId}";
                rankItems.forEach(item => item.style.display = 'none'); // 초기화

                rankList.forEach((rank, index) => {
                    if (index < rankItems.length) {
                        const item = rankItems[index];
                        const nameElement = item.querySelector('.ranker-name');
                        const scoreElement = item.querySelector('.ranker-score');

                        // 닉네임 또는 ID 표시
                        if (nameElement) nameElement.innerText = rank.nickname || rank.userId || "알 수 없음";
                        // 전적(승패무) 표시
                        if (scoreElement) {
                            scoreElement.innerText = (rank.wins || 0) + '승 ' + (rank.losses || 0) + '패 ' + (rank.draws || 0) + '무';
                        }
                        item.style.display = (index === 0) ? 'block' : 'flex';

                        // 1등인 경우 특별 프로필 이미지 처리
                        if (index === 0) {
                            const firstImg = document.getElementById('firstRankImg');
                            const myCurrentImg = document.getElementById('profileImage');
                            if (firstImg) {
                                const iconName = rank.userIcon || rank.usericon || rank.user_icon;
                                if (iconName && iconName !== 'null' && iconName !== '') {
                                    if (rank.userId === currentLoginId && myCurrentImg) {
                                        firstImg.src = myCurrentImg.src;
                                    } else {
                                        let finalSrc = iconName.startsWith('/') ? iconName : ctx + '/upload/profile/' + iconName;
                                        firstImg.src = finalSrc.replace('//', '/') + '?t=' + new Date().getTime();
                                    }
                                    firstImg.onerror = function() {
                                        this.src = ctx + '/assets/images/profile_icon.png';
                                        this.onerror = null;
                                    };
                                } else {
                                    firstImg.src = ctx + '/assets/images/profile_icon.png';
                                }
                            }
                        }
                    }

                    // 접속한 본인의 전적 배지 업데이트
                    if (rank.userId === currentLoginId) {
                        const profileBadge = document.querySelector('.user-record-badge');
                        if (profileBadge) {
                            profileBadge.innerText = (rank.wins || 0) + '승 ' + (rank.losses || 0) + '패 ' + (rank.draws || 0) + '무';
                        }
                    }
                });
            })
            .catch(error => console.error('전적 로딩 실패:', error));
    }

    /**
     * [3. 문서 로드 완료 시 실행 이벤트]
     * 페이지가 준비되면 초기 데이터를 로드하고, 방 생성 버튼 등에 이벤트를 연결합니다.
     */
    document.addEventListener('DOMContentLoaded', function() {
        fetchRankingsAndProfile();

        const newRoomSubmit = document.getElementById('newRoomSubmit');
        if (newRoomSubmit) {
            newRoomSubmit.addEventListener('click', function() {
                const roomName = document.getElementById('roomName').value.trim();
                const currentUserId = "${userId}";

                if (!roomName) {
                    swal("알림", "방 이름을 입력해주세요!", "warning");
                    return;
                }

                // 방 생성 API 호출
                fetch('http://localhost:8115/game/createRoom', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ "roomTitle": roomName, "managerId": currentUserId })
                })
                    .then(response => response.json())
                    .then(data => {
                        // [보안] 방 생성 성공 시에만 세션 스토리지에 '입장 허가 토큰' 부여
                        sessionStorage.removeItem('isAllowed');
                        sessionStorage.setItem('isAllowed', 'true');
                        // 생성된 방으로 자동 입장 (방장 역할 'O')
                        location.href = 'game_room?roomId=' + data.roomId + '&userId=' + encodeURIComponent(currentUserId) + '&role=O';
                    })
                    .catch(error => console.error('방 생성 실패:', error));
            });
        }
    });

    /**
     * [4. UI 제어 및 팝업 관련 (jQuery)]
     * 각종 팝업 열기/닫기, 비밀번호 변경, 로그아웃 기능을 담당합니다.
     */
    $(function () {
        $('#reloadBtn').click(function () {
            fetchRankingsAndProfile();
            location.reload();
        });

        // 팝업 애니메이션 처리 (방 생성, 이름 변경, 설정 등)
        $('#creatRoomBtn').click(function () { $('.creatRoom-contents').fadeIn(300).find('.popup-inner').removeClass('bounce-out').addClass('bounce'); });
        $('#editName').click(function () { $('.rename-contents').fadeIn(300).find('.popup-inner').removeClass('bounce-out').addClass('bounce'); });
        $('#settingCall').click(function () { $('.setting-contents').fadeIn(300).find('.popup-inner').removeClass('bounce-out').addClass('bounce'); });

        $('#callPWchange').click(function () {
            $('.setting-contents').fadeOut(300);
            $('.pw-change-contents').fadeIn(300).find('.popup-inner').removeClass('bounce-out').addClass('bounce');
        });

        $('.popup-close, .close-btn').click(function() {
            $(this).closest('.popup-wrapper, .popup-contents').fadeOut(300).find('.popup-inner').addClass('bounce-out');
        });

        // 비밀번호 변경 제출
        $("#pwChangeSubmitForm").submit(function(e) {
            e.preventDefault();
            const newPw = $("#addPW").val();
            const confirmNewPw = $("#addPWcheck").val();

            if (newPw !== confirmNewPw) { swal("오류", "일치하지 않습니다.", "warning"); return; }
            $.ajax({
                url: ctx + "/user/api/change-pw-logged-in",
                type: "POST",
                data: JSON.stringify({ newPassword: newPw }),
                contentType: "application/json",
                success: function(res) {
                    if (res && res.resultCode === "SUCCESS") {
                        swal("성공!", res.message, "success").then(() => { window.location.href = ctx + "/user/login"; });
                    }
                }
            });
        });

        // [핵심 보안 수정] 로그아웃 시 권한 파괴
        $("#logoutBtn").click(function (e) {
            e.preventDefault();
            swal({
                title: "로그아웃", text: "정말로 로그아웃 하시겠습니까?", icon: "warning",
                buttons: ["취소", "확인"], dangerMode: true,
            }).then((willLogout) => {
                if (willLogout) {
                    // 서버 로그아웃 전 클라이언트의 입장 권한 및 세션 정보 즉시 삭제 (주소 복사 방지 핵심)
                    sessionStorage.clear();

                    $.ajax({
                        url: ctx + "/user/api/logout",
                        type: "POST",
                        success: function(res) {
                            if (res && res.resultCode === "SUCCESS") {
                                swal("로그아웃 완료", "로그아웃 되었습니다.", "success").then(() => { window.location.href = ctx + "/"; });
                            }
                        }
                    });
                }
            });
        });
    });

    /**
     * [5. 기타 사용자 관리 기능]
     * 회원 탈퇴, 닉네임 변경, 프로필 이미지 업로드를 처리합니다.
     */
    function userUnregisterFinal() {
        swal({ title: "정말 탈퇴하시겠습니까?", icon: "warning", buttons: ["취소", "탈퇴"], dangerMode: true, })
            .then((willDelete) => {
                if (willDelete) {
                    sessionStorage.clear(); // 세션 삭제
                    $.ajax({ url: ctx + "/user/api/unregister", type: "POST", success: function(res) {
                            if (res && res.resultCode === "SUCCESS") { window.location.href = ctx + "/"; }
                        }});
                }
            });
    }

    function changeNicknameSubmit() {
        const newNickname = $("#addNickname").val().trim();

        // 1. 클라이언트 측 유효성 검사 (Pre-check)
        if (!newNickname) {
            swal("경고", "변경할 닉네임을 입력해주세요.", "warning");
            return;
        }

        $.ajax({
            url: ctx + "/user/api/change-nickname",
            type: "POST",
            contentType: "application/json",
            data: JSON.stringify({ newNickname: newNickname }),

            // 전송 전 로딩 표시 (선택사항)
            beforeSend: function() {
                // 버튼 비활성화 등으로 중복 클릭 방지
            },

            success: function(res) {
                // 서버 응답 분기 처리 (Controller의 ResultCode 대응)
                if (res.resultCode === "SUCCESS") {
                    swal("성공", res.message || "닉네임이 변경되었습니다.", "success")
                        .then(() => { window.location.reload(); });
                } else {
                    // 중복 닉네임 등 로직 에러 처리
                    swal("실패", res.message || "이미 사용 중인 닉네임입니다.", "error");
                }
            },
        });
    }

    function uploadProfileImage(input) {
        if (input.files && input.files[0]) {
            const formData = new FormData();
            formData.append('profileFile', input.files[0]);
            formData.append('userId', '${userId}');
            $.ajax({
                url: ctx + '/user/updateProfileImage',
                type: 'POST',
                data: formData,
                contentType: false, processData: false,
                success: function(response) {
                    if (response.success) {
                        document.getElementById('profileImage').src = ctx + '/upload/profile/' + response.newFileName;
                        swal("프로필 사진이 변경되었습니다.");
                    }
                }
            });
        }
    }

    /**
     * [6. 게임방(Room) 리스트 및 페이징 처리 로직]
     * 현재 생성된 게임방 목록을 가져오고 페이징 처리하여 화면에 그립니다.
     */
    let allRooms = [];
    let currentPage = 1;
    const itemsPerPage = 3; // 한 페이지당 3개씩 표시
    const pagesPerBlock = 5;

    $(document).ready(function() {
        fetchRooms();
    });

    // 서버에서 모든 방 목록 조회 및 상태별 정렬
    function fetchRooms() {
        $.ajax({
            url: ctx + '/game/rooms',
            method: 'GET',
            success: function(data) {
                const statusOrder = { '01': 1, '02': 2, '03': 3 }; // 대기중 우선 정렬
                allRooms = data.sort((a, b) => (statusOrder[a.status] || 99) - (statusOrder[b.status] || 99));
                renderRoomList(1);
            }
        });
    }

    // 특정 페이지의 방 목록을 HTML로 생성
    function renderRoomList(page) {
        currentPage = page;
        var $listContainer = $('.game-list').empty();
        var start = (page - 1) * itemsPerPage;
        var pagedRooms = allRooms.slice(start, start + itemsPerPage);

        if (pagedRooms.length === 0) {
            $listContainer.append('<li style="text-align:center; padding:20px;">생성된 방이 없습니다.</li>');
            return;
        }

        pagedRooms.forEach(function(room) {
            var isWaiting = (room.status === '01');
            var stateClass = isWaiting ? 'state-wait' : (room.status === '02' ? 'state-active' : 'state-end');
            var stateText = isWaiting ? '대기중' : (room.status === '02' ? '진행중' : '종료');

            var html = '<li><div class="flex-box just-between"><div class="room-infor flex-box column just-between">' +
                '<div><div class="room-name-wrap"><div class="room-name">' + (room.roomTitle || "무제") + '</div>' +
                '<span class="room-states ' + stateClass + '">' + stateText + '</span></div>' +
                '<div class="room-manager">' + (room.managerId || "알 수 없음") + '</div></div>' +
                '<button type="button" class="joingame-btn ' + (!isWaiting ? "disabled-btn" : "") + '" ' + (isWaiting ? "onclick=\"joinGame('" + room.roomId + "')\"" : "disabled") + '>JOIN GAME</button></div>' +
                '<div class="room-stage">' + renderBoardPreview(room.board) + '</div></div></li>';
            $listContainer.append(html);
        });
        renderPagination(allRooms.length);
    }

    // 방 리스트 우측에 실시간 게임판 미리보기 생성
    function renderBoardPreview(board) {
        let html = '';
        const safeBoard = board || [['','',''],['','',''],['','','']];
        for(let i=0; i<9; i++) {
            const r = Math.floor(i/3), c = i%3;
            const mark = safeBoard[r][c];
            html += '<div class="room-stage-box ' + (i % 2 === 0 ? 'box-dark' : 'box-light') + '">' +
                '<img src="'+ctx+'/assets/images/obj-circle-hevy.svg" class="'+((mark==='O'||mark==='o')?'':'hide')+'" alt="O">' +
                '<img src="'+ctx+'/assets/images/obj-cross-hevy.svg" class="'+((mark==='X'||mark==='x')?'':'hide')+'" alt="X"></div>';
        }
        return html;
    }

    // 하단 페이징 버튼 생성
    function renderPagination(totalItems) {
        var totalPages = Math.ceil(totalItems / itemsPerPage);
        var $pagingUl = $('.pagination ul').empty();
        if (totalPages === 0) return;
        var startPage = (Math.ceil(currentPage / pagesPerBlock) - 1) * pagesPerBlock + 1;
        var endPage = Math.min(startPage + pagesPerBlock - 1, totalPages);

        $pagingUl.append('<li class="prev ' + (startPage === 1 ? 'disabled' : '') + '"><a href="javascript:void(0)" onclick="' + (startPage !== 1 ? 'renderRoomList(' + (startPage - 1) + ')' : '') + '"><img src="'+ctx+'/assets/images/icon-paging-prev.svg"></a></li>');
        for (var i = startPage; i <= endPage; i++) {
            $pagingUl.append('<li class="' + (i === currentPage ? 'active' : '') + '"><a href="javascript:void(0)" onclick="renderRoomList(' + i + ')">' + i + '</a></li>');
        }
        $pagingUl.append('<li class="next ' + (endPage >= totalPages ? 'disabled' : '') + '"><a href="javascript:void(0)" onclick="' + (endPage < totalPages ? 'renderRoomList(' + (endPage + 1) + ')' : '') + '"><img src="'+ctx+'/assets/images/icon-paging-next.svg"></a></li>');
    }

    /**
     * [7. 게임방 입장 로직]
     * JOIN 버튼 클릭 시 권한을 체크하고 입장 권한을 부여한 뒤 이동합니다.
     */
    function joinGame(roomId) {
        $.ajax({
            url: ctx + '/game/joinRoom',
            method: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ roomId: roomId, userId: "${userId}" }),
            success: function() {
                // [보안] 입장 성공 시에만 세션 스토리지에 '입장 허가 토큰' 부여
                sessionStorage.removeItem('isAllowed');
                sessionStorage.setItem('isAllowed', 'true');
                // 게임방으로 이동 (참가자 역할 'X')
                location.href = ctx + '/game_room?roomId=' + roomId + '&userId=' + encodeURIComponent("${userId}") + '&role=X';
            },
            error: function(xhr) { swal("입장 제한", xhr.responseText || "방에 입장할 수 없습니다.", "warning"); fetchRooms(); }
        });
    }

    // 전적 초기화 기능
    function executeScoreReset() {
        swal({ title: "전적 리셋 확인", icon: "warning", buttons: ["취소", "확인"], dangerMode: true, })
            .then((willReset) => {
                if (willReset) {
                    $.post("/user/api/user/reset-rank", function(res) {
                        if (res === "success") { swal("성공", "리셋 되었습니다.", "success").then(() => location.reload()); }
                    });
                }
            });
    }
</script>

<!-- 공통::js -->
<script src="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
<script src="https://unpkg.com/sweetalert/dist/sweetalert.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>


</body>
</html>