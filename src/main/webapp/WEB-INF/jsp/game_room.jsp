<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css"/>
    <link rel="stylesheet" href="/assets/css/style.css">
    <script src="/assets/js/jquery-3.6.0.min.js"></script>
    <title>PLAY TTT!</title>
    <style>
        .first-order, .second-order { display: none; }
        .turn { display: none; }
        .player-box.turn-active .turn { display: block; }
        /* 가이드 버튼과 팝업이 게임판 위에 오도록 설정 */
        .guide-wrap { z-index: 1000; }
        .popup-contents.fixed { z-index: 2000; }
        /* 배경 장식이 게임판 뒤로 가도록 설정 */
        .title-graphic { z-index: 0; pointer-events: none; }
    </style>
</head>
<body>

<div class="popup-contents guide-contents fixed popup-down">
    <div class="popup-inner guide-inner bounce-out">
        <input type="button" value="×" id="close-btn" class="close-btn transition-fade">
        <div class="guide-slide">
            <button class="guide-nav guide-prev">
                <img src="/assets/images/icon-prev.svg" alt="이전">
            </button>
            <div class="guide-slide-inner">
                <div class="guide-inner1">
                    <div class="guide-inner-img flex-box item-center just-center">
                        <img src="/assets/images/frame/guide-1.png" alt="가이드1" class="center">
                    </div>
                    <p>플레이! 틱택토는 실시간 통신으로 진행 됩니다.</p>
                </div>
                <div class="guide-inner2">
                    <div class="guide-inner-img flex-box item-center just-center">
                        <img src="/assets/images/frame/guide-2.png" alt="가이드2" class="center">
                    </div>
                    <p>로그인에 성공하면 게임에 참여 하거나 직접 방을 만들 수 있습니다.</p>
                </div>
                <div class="guide-inner3">
                    <div class="guide-inner-img flex-box item-center just-center">
                        <img src="/assets/images/frame/guide-3.png" alt="가이드3" class="center">
                    </div>
                    <p>O가 선공, X는 후공입니다. 번갈아가며 칸을 채워주세요.</p>
                </div>
                <div class="guide-inner4">
                    <div class="guide-inner-img flex-box item-center just-center">
                        <img src="/assets/images/frame/guide-4.png" alt="가이드4" class="center">
                    </div>
                    <p>먼저 가로, 세로, 대각선 3칸을 채우는 플레이어가 우승합니다.</p>
                </div>
                <div class="guide-inner5">
                    <div class="guide-inner-img flex-box item-center just-center">
                        <img src="/assets/images/frame/guide-5.png" alt="가이드5" class="center">
                    </div>
                    <p>승률을 올려 랭킹에 도전해보세요!</p>
                </div>
            </div>
            <button class="guide-nav guide-next">
                <img src="/assets/images/icon-next.svg" alt="다음">
            </button>
        </div>
    </div>
</div>

<div class="guide-wrap">
    <button type="button" class="guide-btn" id="guideBtn">?</button>
</div>

<section id="game" class="section">
    <div class="header">
        <h1>
            <a href="javascript:void(0)" onclick="goToMain()">
                <img src="/assets/images/main-logo.png" alt="메인로고">
            </a>
        </h1>
    </div>

    <div class="inner">
        <div class="title-graphic">
            <img src="/assets/images/obj-left.png" alt="장식" class="obj-left">
            <img src="/assets/images/obj-right.png" alt="장식" class="obj-right">
        </div>

        <div class="player-box-wrap">
            <div class="player-box player-first flex-box column item-center this-user">
                <div class="marker">O</div>
                <div class="user-icon">
                    <div class="user-icon-img">
                        <img src="${not empty sessionScope.userIcon ? '/upload/profile/'.concat(sessionScope.userIcon) : '/assets/images/profile_icon.png'}"
                             alt="프로필 사진" id="myProfileImg">
                    </div>
                    <div class="me-marker">ME</div>
                </div>
                <div class="user-name">
                    ${not empty sessionScope.userNicnm ? sessionScope.userNicnm : (not empty param.userId ? param.userId : '게스트')} (나)
                </div>
                <div class="turn">YOUR TURN</div>
            </div>

            <div id="opponentBox" class="player-box player-second waiting-box flex-box column item-center">
                <div class="marker">X</div>
                <div class="user-icon">
                    <div class="user-icon-img">
                        <img id="opponentImg" src="/assets/images/profile_icon.png" alt="프로필 사진">
                    </div>
                    <div class="me-marker" style="display:none;">ME</div>
                </div>
                <div id="opponentName" class="user-name">상대방 찾기</div>
                <div class="user-waiting">WAITING PLAYER...</div>
                <div class="turn">YOUR TURN</div>
            </div>
        </div>

        <div class="game-stage">
            <% for(int i=0; i<3; i++) { %>
            <div class="game-row">
                <% for(int j=0; j<3; j++) { %>
                <div class="game-box <%= (i+j)%2==0 ? "box-light" : "box-dark" %>">
                    <img src="/assets/images/obj-circle-hevy.svg" alt="O" class="first-order">
                    <img src="/assets/images/obj-cross-hevy.svg" alt="X" class="second-order">
                </div>
                <% } %>
            </div>
            <% } %>
        </div>
    </div>

    <div class="game-btn">
        <input type="button" value="나가기" class="btn btn-thin" id="roomExit" onclick="roomOut()">
    </div>
</section>

<script src="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
<script src="https://unpkg.com/sweetalert/dist/sweetalert.min.js"></script>
<script src="/assets/js/common.js"></script>

<script>
    /**
     * [보안 1단계] 페이지 진입 시 권한 및 파라미터 체크
     */
    const urlParams = new URLSearchParams(window.location.search);

    // URL 파라미터가 있으면 우선 사용하고, 없으면 세션 저장소에서 꺼내옴 (새로고침 대비)
    const paramRoomId = urlParams.get('roomId');
    const roomId = paramRoomId || sessionStorage.getItem('currentRoomId');
    const userId = urlParams.get('userId') || sessionStorage.getItem('currentUserId');
    const myRole = urlParams.get('role') || sessionStorage.getItem('currentRole');

    // [핵심 보안] 주소창에 직접 파라미터(roomId)를 입력해 들어온 경우 검사
    if (paramRoomId) {
        const isAllowed = sessionStorage.getItem('isAllowed');

        // 메인 페이지의 'JOIN' 버튼을 누르지 않고(isAllowed 없음) 주소만 복사해온 경우
        if (isAllowed !== 'true') {
            alert("비정상적인 접근입니다. 메인 화면을 통해 입장해주세요.");
            sessionStorage.clear();           // 보안을 위해 모든 세션 데이터 삭제
            window.location.replace("/main"); // 기록을 남기지 않고 메인으로 강제 이동
            window.stop();                    // 스크립트 실행 즉시 중단
            document.body.innerHTML = "";     // 화면 내용을 모두 지움
        } else {
            // 정상적인 접근일 경우, 새로고침 시에도 튕기지 않도록 정보를 세션에 저장
            sessionStorage.setItem('currentRoomId', roomId);
            sessionStorage.setItem('currentUserId', userId);
            sessionStorage.setItem('currentRole', myRole);

            // [주소 세탁] 보안 및 깔끔한 주소창을 위해 URL에서 파라미터(?roomId=...) 제거
            if (window.history.replaceState) {
                window.history.replaceState({}, null, window.location.pathname);
            }
        }
    }

    // 최종 검사: 필요한 정보가 하나라도 없으면(비정상 상태) 메인으로 추방
    if (!roomId || !userId) {
        alert("방 정보가 없거나 세션이 만료되었습니다.");
        window.location.replace("/main");
    }

    /**
     * [변수] 2. 전역 변수 설정
     */
    let pollingId = null; // 서버와 실시간으로 데이터를 주고받기 위한 타이머 ID

    /**
     * [함수] 3. 이미지 경로 보정 (DB 경로 불일치 해결)
     */
    function fixPath(path) {
        if (!path || path === "null" || path === "") {
            return '/assets/images/profile_icon.png'; // 기본 아이콘
        }
        if (path.startsWith('/upload/') && !path.includes('/profile/')) {
            return path.replace('/upload/', '/upload/profile/'); // 경로 자동 수정
        }
        return path;
    }

    /**
     * [실행] 4. 페이지 로드 완료 시 초기화 (jQuery)
     */
    $(function () {
        // --- 가이드/도움말 팝업 제어 ---
        $('#guideBtn').on('click', function() {
            $('.guide-contents').fadeIn().addClass('popup-active');
            if($('.guide-slide-inner').hasClass('slick-initialized')) {
                $('.guide-slide-inner').slick('setPosition');
            }
        });
        $('#close-btn').on('click', function() {
            $('.guide-contents').fadeOut().removeClass('popup-active');
        });

        // --- 플레이어 본인(나) 정보 렌더링 ---
        const myNick = "${sessionScope.userNicnm}";
        const myIcon = "${sessionScope.userIcon}";
        let displayName = (myNick && myNick !== "null") ? myNick : (userId || "게스트");

        $('.player-first .user-name').text(displayName + " (나)");
        $('.player-first .marker').text(myRole); // 내 마커 표시 (O 또는 X)

        if (myIcon && myIcon !== "null") {
            $('.player-first .user-icon-img img').attr('src', '/upload/profile/' + myIcon);
        }

        /**
         * [이벤트] 게임판 클릭 시 수 두기
         */
        $('.game-box').on('click', function () {
            // 상대방이 없거나, 이미 돌이 있거나, 내 차례가 아니면 클릭 무시
            if ($('.player-second').hasClass('waiting-box')) return;
            if ($(this).find('img:visible').length > 0) return;
            if (!$('.player-first').hasClass('turn-active')) {
                swal("잠시만요!", "상대방의 차례입니다.", "warning");
                return;
            }
            // 클릭한 칸의 좌표 계산 후 서버로 전송
            const index = $('.game-box').index(this);
            sendMove(Math.floor(index / 3), index % 3);
        });

        startPolling(); // 1.5초마다 서버와 통신 시작
    });

    /**
     * [통신] 5. 데이터 통신 (수 두기 및 상태 조회)
     */
    function sendMove(x, y) {
        fetch('/game/play', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ roomId, userId, x, y })
        })
            .then(res => {
                if(!res.ok) return res.text().then(msg => { throw new Error(msg) });
                return res.json();
            })
            .then(room => updateUI(room)) // 수 두기 성공 시 화면 갱신
            .catch(err => swal("알림", err.message, "error"));
    }

    // 주기적으로 서버의 게임 상태를 가져오는 폴링(Polling) 함수
    function startPolling() {
        pollingId = setInterval(() => {
            if (!roomId) return;
            fetch('/game/status?roomId=' + roomId + '&userId=' + encodeURIComponent(userId))
                .then(res => res.json())
                .then(room => updateUI(room))
                .catch(err => console.log("데이터 갱신 중..."));
        }, 1500); // 1.5초 간격
    }

    /**
     * [UI] 6. 실시간 화면 업데이트
     */
    function updateUI(room) {
        if (!room) return;

        // 플레이어 닉네임 및 프로필 이미지 경로 설정
        const pO = room.playerO;
        const pX = room.playerX;
        const pONick = room.playerONick || pO;
        const pXNick = room.playerXNick || pX;
        const pOPath = fixPath(room.playerOIconPath);
        const pXPath = fixPath(room.playerXIconPath);

        const status = room.status;
        const currentTurn = room.currentTurn;

        // 역할(O/X)에 따라 내 정보와 상대방 정보 화면 배치
        if (myRole === 'O') {
            $('.player-first .user-name').text(pONick + " (나)");
            if (pOPath) $('.player-first .user-icon-img img').attr('src', pOPath);
            updateOpponentUI(pXNick, pXPath);
        } else {
            $('.player-first .user-name').text(pXNick + " (나)");
            if (pXPath) $('.player-first .user-icon-img img').attr('src', pXPath);
            updateOpponentUI(pONick, pOPath);
        }

        // 현재 누구 차례인지 표시 (테두리 활성화)
        if (status === '02' || status === 'PLAYING') {
            const isMyTurn = (currentTurn && userId && currentTurn.trim() === userId.trim());
            if (isMyTurn) {
                $('.player-first').addClass('turn-active');
                $('.player-second').removeClass('turn-active');
            } else {
                $('.player-second').addClass('turn-active');
                $('.player-first').removeClass('turn-active');
            }
        }

        renderBoard(room.board); // 게임판 돌 그리기

        // 게임 종료 처리 (승리/패배/무승부 팝업)
        if (status === '03' || status === 'FINISHED') {
            clearInterval(pollingId); // 통신 중단
            const winnerId = room.winnerId;
            let resultTitle = (winnerId === null || winnerId === "" || winnerId === "DRAW") ? "무승부입니다." : (winnerId === userId ? "이겼습니다!" : "패배했습니다.");

            // 현재 전적 계산 및 팝업 내용 구성
            let win = (myRole === 'O') ? (room.userWin || 0) : (room.userXWin || 0);
            let lose = (myRole === 'O') ? (room.userLose || 0) : (room.userXLose || 0);
            let draw = (myRole === 'O') ? (room.userDraw || 0) : (room.userXDraw || 0);

            const recordContent = document.createElement("div");
            recordContent.innerHTML = `<div style="font-size: 1.1rem; color: #666; margin-bottom: 15px;">멋진 승부였어요.</div>
            <div style="background: #f8f9fa; padding: 25px; border-radius: 12px; border: 1px solid #eee; margin: 15px 0;">
            <div style="font-size: 0.9rem; color: #888; margin-bottom: 8px;">현재 당신의 전적</div>
            <div style="font-size: 2.2rem; font-weight: 800; color: #333;">\${win}승 \${lose}패 \${draw}무</div></div>`;

            if (!window.isGameOverPopupShown) {
                window.isGameOverPopupShown = true;
                swal({
                    title: resultTitle,
                    content: recordContent,
                    buttons: { confirm: { text: "퇴장하기", value: true, className: "btn-exit" } },
                    closeOnClickOutside: false
                }).then(() => {
                    location.href = "/main?userId=" + encodeURIComponent(userId);
                });
            }
        }
    }

    // 상대방 정보를 화면에 그리는 함수 (대기 중 상태 처리 포함)
    function updateOpponentUI(nick, path) {
        const $oppoBox = $('#opponentBox');
        const $oppoNameTag = $('#opponentName');
        const $oppoImgTag = $('#opponentImg');

        if (nick && nick !== "null" && nick !== "") {
            $oppoBox.removeClass('waiting-box');
            $oppoBox.find('.user-waiting').hide();
            $oppoNameTag.html(nick);
            $oppoImgTag.attr('src', path);
            $oppoBox.find('.marker').text(myRole === 'O' ? 'X' : 'O');
        } else {
            $oppoBox.addClass('waiting-box'); // 상대방이 없을 때 대기 모드 활성화
            $oppoNameTag.html("상대방 찾기");
            $oppoBox.find('.user-waiting').show();
            $oppoImgTag.attr('src', '/assets/images/profile_icon.png');
        }
    }

    // 서버의 2차원 배열 데이터를 기반으로 HTML 게임판에 이미지 표시
    function renderBoard(board) {
        if (!board) return;
        $('.game-box').each(function(index) {
            const row = Math.floor(index / 3);
            const col = index % 3;
            let val = (board[row] && board[row][col]) ? board[row][col] : "";
            const cleanVal = String(val).replace(/\0/g, '').trim();

            const oImg = $(this).find('.first-order');
            const xImg = $(this).find('.second-order');

            oImg.hide();
            xImg.hide();

            if (cleanVal === 'O') oImg.show();
            else if (cleanVal === 'X') xImg.show();
        });
    }

    // 나가기 버튼 클릭 시 확인 팝업
    function roomOut() {
        swal({
            title: "정말 나갈까요?",
            text: "메인 화면으로 이동합니다.",
            icon: "warning",
            buttons: true,
            dangerMode: true
        }).then((willExit) => {
            if (willExit) location.href = "/main?userId=" + encodeURIComponent(userId);
        });
    }

    // 메인으로 단순 이동
    function goToMain() {
        location.href = userId ? "/main?userId=" + encodeURIComponent(userId) : "/main";
    }
</script>
</body>
</html>