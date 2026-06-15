<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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


<section id="codeID" class="form-bg">
    <div class="header">
        <h1>
            <a href="/">
                <img src="/assets/images/main-logo.png" alt="메인로고">
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
        </div>


        <div class="form-box">
            <div class="input-box">
                <div class="input-label">
                    <label for="code">인증코드</label>
                </div>
                <div class="input-wrap">
                    <input id="code" type="text" placeholder="인증코드">
                </div>
            </div>
        </div>
        <div class="form-box">
            <input type="submit" value="확인" id="checkCode" class="btn btn-light">
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
         * URL 파라미터의 이메일 정보를 세션에 백업하고 주소창에서 즉시 제거합니다.
         */
        const urlParams = new URLSearchParams(window.location.search);
        const emailFromUrl = urlParams.get('email');

        // 최초 진입 시 URL에 이메일이 있다면 세션에 저장하고 주소를 세탁합니다.
        if (emailFromUrl) {
            sessionStorage.setItem('findIdEmail', emailFromUrl);

            // [핵심] 주소창에서 ?email=... 부분을 제거하여 /user/code-id만 남깁니다.
            if (window.history.replaceState) {
                window.history.replaceState({}, null, window.location.pathname);
            }
        }

        // 실제 로직에서 사용할 이메일 (URL에 없으면 세션에서 복구 -> 새로고침 대응)
        const email = emailFromUrl || sessionStorage.getItem('findIdEmail');

        // 이메일 정보가 아예 없는 경우 (비정상 접근) 예외 처리
        if (!email) {
            swal("경고", "잘못된 접근이거나 인증 정보가 만료되었습니다.", "error")
                .then(() => {
                    window.location.href = ctx + "/user/find-id"; // 아이디 찾기 첫 페이지로 이동
                });
            return;
        }

        /**
         * [2. '확인' 버튼 클릭 이벤트 (인증 코드 검증)]
         */
        $("#checkCode").click(function () {
            const inputCode = $('#code').val().trim(); // 인증 코드 입력 필드 ID

            if (!inputCode) {
                swal("경고", "인증 코드를 입력해주세요.", "warning");
                return;
            }

            // AJAX 요청: 세션에 저장해둔 이메일과 입력한 코드를 전송
            $.ajax({
                url: ctx + "/user/api/verify-id-code",
                type: "POST",
                contentType: "application/json",
                // Spring Security 사용 시 CSRF 헤더 포함
                headers: { 'X-CSRF-TOKEN': '${_csrf.token}' },
                data: JSON.stringify({
                    email: decodeURIComponent(email),
                    code: inputCode
                }),
                success: function(res) {
                    if (res && res.resultCode === "SUCCESS") {
                        swal("인증 성공", "인증이 완료되었습니다. 아이디를 확인합니다.", "success")
                            .then(function() {
                                // [3. 인증 성공 시 이동]
                                // 성공 후 세션 데이터 정리 (선택 사항)
                                sessionStorage.removeItem('findIdEmail');

                                // 아이디 확인 페이지로 이동 (결과 페이지 주소도 깔끔하게 관리 가능)
                                window.location = ctx + "/user/check-id?email=" + encodeURIComponent(email);
                            });
                    } else {
                        // 인증 코드가 일치하지 않거나 만료된 경우
                        const msg = (res && res.message) ? res.message : "인증 코드가 일치하지 않거나 만료되었습니다.";
                        swal("인증 실패", msg, "error");
                    }
                },
                error: function(xhr) {
                    let msg = "서버 통신 중 알 수 없는 오류가 발생했습니다.";
                    if (xhr.responseJSON && xhr.responseJSON.message) {
                        msg = xhr.responseJSON.message;
                    }
                    swal("통신 오류", msg, "error");
                }
            });
        });
    });
</script>
</body>
</html>