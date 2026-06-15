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
    <title>PLAY TTT! 비밀번호 변경</title>
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


<section id="changePW" class="form-bg">
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
                새로운 비밀번호를 입력해주세요.
            </p>
            <div class="input-box">
                <div class="input-label">
                    <label for="newPassword">새 비밀번호</label>
                </div>
                <div class="input-wrap">
                    <input id="newPassword" type="password" placeholder="새 비밀번호 (최대 10자리)" maxlength="10">
                </div>
            </div>
            <div class="input-box">
                <div class="input-label">
                    <label for="confirmPassword">비밀번호 확인</label>
                </div>
                <div class="input-wrap">
                    <input id="confirmPassword" type="password" placeholder="비밀번호 확인">
                </div>
            </div>
        </div>
        <div class="form-box">
            <input type="submit" value="변경하기" id="changePasswordBtn" class="btn btn-primary">
        </div>
    </div>
</section>

<script src="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
<script src="https://unpkg.com/sweetalert/dist/sweetalert.min.js"></script>
<script src="/assets/js/common.js"></script>

<script>
    $(function () {
        const ctx = '${pageContext.request.contextPath}';

        $("#changePasswordBtn").click(function () {
            const newPw = $('#newPassword').val().trim();
            const confirmPw = $('#confirmPassword').val().trim();

            // 1. 유효성 검사
            if (!newPw || !confirmPw) {
                swal("경고", "비밀번호를 모두 입력해주세요.", "warning");
                return;
            }
            if (newPw.length > 10) {
                swal("경고", "비밀번호는 최대 10자리까지만 허용됩니다.", "warning");
                return;
            }
            if (newPw !== confirmPw) {
                swal("경고", "새 비밀번호와 확인 비밀번호가 일치하지 않습니다.", "warning");
                return;
            }

            // 2. AJAX 요청 (비밀번호 변경 API 호출)
            $.ajax({
                url: ctx + "/user/api/change-pw", // 곧 구현할 API
                type: "POST",
                contentType: "application/json",
                // headers: { 'X-CSRF-TOKEN': '${_csrf.token}' },
                data: JSON.stringify({
                    newPassword: newPw
                }),
                success: function(res) {
                    if (res && res.resultCode === "SUCCESS") {
                        // 3. 변경 성공: 로그인 페이지로 이동
                        swal("변경 완료", "비밀번호가 성공적으로 변경되었습니다. 로그인 해주세요.", "success", {
                            button: "로그인 페이지로",
                            closeOnClickOutside: false
                        }).then(function () {
                            window.location = ctx + "/user/login";
                        });
                    } else {
                        // 4. 변경 실패: 인증 정보 만료 또는 서버 오류
                        const msg = (res && res.message) ? res.message : "비밀번호 변경에 실패했습니다. 다시 시도해주세요.";
                        swal("변경 실패", msg, "error").then(() => {
                            // 인증 정보 만료 시 find-pw로 돌려보냄
                            if (res.resultCode === "EXPIRED") {
                                window.location = ctx + "/user/find-pw";
                            }
                        });
                    }
                },
                error: function(xhr) {
                    swal("통신 오류", "서버와 통신 중 문제가 발생했습니다.", "error");
                }
            });
        });
    });
</script>
</body>
</html>