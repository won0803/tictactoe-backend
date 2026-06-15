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
    <title>PLAY TTT! 비밀번호 인증</title>
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


<section id="codePW" class="form-bg">
    <div class="header">
        <h1>
            <a href="/"> <img src="/assets/images/main-logo.png" alt="메인로고">
            </a>
        </h1>
    </div>
    <div class="inner form-wrap">
        <div class="title-graphic">
            <img src="/assets/images/obj-left.png" alt="장식" class="obj-left">
            <img src="/assets/images/obj-right.png" alt="장식" class="obj-right">
        </div>

        <div class="form-box">
            <p class="text-info" style="margin-bottom: 20px;">
                인증 코드가 이메일로 발송되었습니다.<br>
                **코드 6자리를 입력해주세요. (5분 유효)**
            </p>
            <div class="input-box">
                <div class="input-label">
                    <label for="authCode">인증코드</label> </div>
                <div class="input-wrap">
                    <input id="authCode" type="text" placeholder="인증 코드" maxlength="6">
                </div>
            </div>
        </div>
        <div class="form-box">
            <input type="submit" value="확인" id="verifyCodePW" class="btn btn-primary">
        </div>
    </div>
</section>

<script src="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
<script src="https://unpkg.com/sweetalert/dist/sweetalert.min.js"></script>
<script src="/assets/js/common.js"></script>

<script>
    $(function () {
        const ctx = '${pageContext.request.contextPath}';

        /**
         * [1. 보안 및 주소창 세탁 로직]
         * 개인정보가 포함된 URL 파라미터를 세션에 백업하고 즉시 숨깁니다.
         */
        const urlParams = new URLSearchParams(window.location.search);

        // URL에서 값을 먼저 추출합니다.
        const paramUserId = urlParams.get('userId');
        const paramEmail = urlParams.get('email');

        // URL에 데이터가 있는 '최초 진입' 시점에만 세션에 백업하고 주소를 정리합니다.
        if (paramUserId && paramEmail) {
            sessionStorage.setItem('resetUserId', paramUserId);
            sessionStorage.setItem('resetEmail', paramEmail);

            // [주소 세탁] 파라미터를 제거하여 /user/code-pw만 남깁니다.
            if (window.history.replaceState) {
                window.history.replaceState({}, null, window.location.pathname);
            }
        }

        /**
         * [2. 데이터 로드]
         * 주소창이 이미 세탁된 상태(새로고침 등)라면 세션에서 값을 가져옵니다.
         */
        const userId = sessionStorage.getItem('resetUserId');
        const email = sessionStorage.getItem('resetEmail');

        // 데이터가 아예 없는 비정상적 접근 처리
        if (!userId || !email) {
            swal("오류", "인증 정보가 만료되었거나 잘못된 접근입니다.", "error")
                .then(() => { window.location.href = ctx + "/user/find-pw"; });
            return;
        }

        /**
         * [3. 인증 코드 확인 버튼 이벤트]
         */
        $("#verifyCodePW").click(function () {
            const inputCode = $('#authCode').val().trim();

            if (!inputCode) {
                swal("경고", "인증 코드를 입력해주세요.", "warning");
                return;
            }

            // AJAX 요청: 이제 세션에서 보관 중인 userId와 email을 사용합니다.
            $.ajax({
                url: ctx + "/user/api/verify-pw-code",
                type: "POST",
                contentType: "application/json",
                data: JSON.stringify({
                    userId: userId,
                    email: email,
                    code: inputCode
                }),
                success: function(res) {
                    if (res && res.resultCode === "SUCCESS") {
                        swal("인증 성공", "비밀번호 변경 페이지로 이동합니다.", "success")
                            .then(function () {
                                // 성공 시 다음 단계 이동
                                window.location = ctx + "/user/change-pw";
                            });
                    } else {
                        swal("인증 실패", res.message || "코드가 일치하지 않습니다.", "error");
                    }
                },
                error: function(xhr) {
                    swal("통신 오류", "서버 응답에 실패했습니다. (Error 400 등)", "error");
                }
            });
        });
    });
</script>
</body>
</html>