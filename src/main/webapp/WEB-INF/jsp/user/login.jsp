
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">

    <!-- jQuery -->
    <script src="${pageContext.request.contextPath}/assets/js/jquery-3.6.0.min.js"></script>

    <title>PLAY TTT! 로그인</title>
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

<section id="login" class="form-bg">
    <div class="header">
        <h1>
            <a href="${pageContext.request.contextPath}/">
                <img src="${pageContext.request.contextPath}/assets/images/main-logo.png" alt="메인로고">
            </a>
        </h1>
    </div>

    <div class="inner form-wrap">
        <div class="title-graphic">
            <img src="${pageContext.request.contextPath}/assets/images/obj-left.png" alt="장식" class="obj-left">
            <img src="${pageContext.request.contextPath}/assets/images/obj-right.png" alt="장식" class="obj-right">
        </div>

        <!-- ✅ 로그인 폼 시작 -->
        <form id="loginForm" action="${pageContext.request.contextPath}/user/login" method="post" class="form-box">
            <!-- 서버에서 에러가 있을 때 표시 (redirect:/user/login?error 로 들어오면) -->
            <div class="error-message" id="serverError" style="display:none;">
                <p>아이디 또는 비밀번호가 올바르지 않습니다.</p>
            </div>

            <div class="input-wrap flex-box gap-15 item-center">
                <!-- 오류 있을 시, .input-wrap에 .error-box 클래스 추가.  -->
                <img src="${pageContext.request.contextPath}/assets/images/icon-id.svg" alt="아이디" class="icon">
                <input type="text" name="username" id="username" placeholder="아이디" required maxlength="20" autocomplete="username">
            </div>

            <div class="input-wrap flex-box gap-15 item-center">
                <img src="${pageContext.request.contextPath}/assets/images/icon-pw.svg" alt="비밀번호" class="icon">
                <input type="password" name="password" id="password" placeholder="비밀번호" required maxlength="200" autocomplete="current-password">
            </div>

            <div class="form-box">
                <!-- ✅ 서버로 submit, onclick으로 페이지 이동하지 않음 -->
                <input type="submit" value="로그인" id="loginBtn" class="btn btn-primary">
                <div class="flex-box just-around look-box">
                    <a href="${pageContext.request.contextPath}/user/find-id">아이디 찾기</a>
                    <a href="${pageContext.request.contextPath}/user/find-pw">비밀번호 찾기</a>
                    <a href="${pageContext.request.contextPath}/user/join" class="bold">회원가입</a>
                </div>
            </div>
        </form>
        <!-- ✅ 로그인 폼 끝 -->
    </div>
</section>

<!-- 공통::js -->
<script src="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
<script src="https://unpkg.com/sweetalert/dist/sweetalert.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>

<script>
    /**
     * [1. 로그인 폼 기초 유효성 검사]
     * 페이지 로드 즉시 실행되며, 기본적인 입력 확인 및 중복 제출을 방지합니다.
     */
    (function() {
        const $form = $('#loginForm');
        const $username = $('#username');
        const $password = $('#password');
        const $serverError = $('#serverError');
        const params = new URLSearchParams(window.location.search);

        // [핵심] 로그인 페이지에 진입할 때 이전의 권한 흔적을 완전히 지웁니다.
        sessionStorage.clear();

        // 서버로부터 ?error 파라미터가 넘어온 경우 에러 메시지 노출
        if (params.has('error')) {
            $serverError.show();
        }

        let submitting = false; // 중복 제출 방지 플래그
        $form.on('submit', function(e) {
            if (submitting) {
                e.preventDefault();
                return false;
            }

            const id = ($username.val() || '').trim();
            const pw = $password.val() || '';

            // 미입력 방어 로직
            if (!id) {
                e.preventDefault();
                alert('아이디를 입력하세요.');
                $username.focus();
                return false;
            }
            if (!pw) {
                e.preventDefault();
                alert('비밀번호를 입력하세요.');
                $password.focus();
                return false;
            }

            submitting = true; // 서버로 전송 시 중복 클릭 방지
        });
    })();

    /**
     * [2. AJAX 로그인 처리]
     * 화면 새로고침 없이 서버와 통신하여 로그인을 시도합니다.
     */
    $(function () {
        const ctx = '${pageContext.request.contextPath}';

        $("#loginBtn").click(function (e) {
            e.preventDefault(); // 기본 form submit 동작 중단 (AJAX로 직접 전송하기 위함)

            const userId = $('#username').val().trim();
            const password = $('#password').val().trim();

            if (!userId || !password) {
                swal("경고", "아이디와 비밀번호를 모두 입력해주세요.", "warning");
                return;
            }

            // 서버 API로 로그인 정보 전송
            $.ajax({
                url: ctx + "/user/api/login",
                type: "POST",
                contentType: "application/json",
                data: JSON.stringify({
                    userId: userId,
                    password: password
                }),
                success: function(res) {
                    if (res && res.resultCode === "SUCCESS") {
                        // 로그인 성공 시
                        swal("로그인 성공!", res.message, "success", {
                            button: "게임 시작",
                            closeOnClickOutside: false
                        }).then(function () {
                            // 성공 후 메인 페이지로 이동 (replace를 사용하여 로그인 창 기록 삭제 권장)
                            window.location.replace(ctx + "/main");
                        });
                    } else {
                        // 로그인 실패 시 (비밀번호 불일치 등)
                        const msg = (res && res.message) ? res.message : "아이디 또는 비밀번호를 다시 확인해주세요.";
                        swal("로그인 실패", msg, "error");
                    }
                },
                error: function(xhr) {
                    // 서버 자체가 응답하지 않거나 에러 발생 시
                    swal("통신 오류", "서버와 통신 중 문제가 발생했습니다.", "error");
                }
            });
        });
    });
</script>
</body>
</html>
