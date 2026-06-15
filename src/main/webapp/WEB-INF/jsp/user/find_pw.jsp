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
    <title>PLAY TTT! 비밀번호 찾기</title>
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


<section id="findPW" class="form-bg">
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
            <div class="input-box">
                <div class="input-label ">
                    <label for="userId">아이디</label> </div>
                <div class="input-wrap">
                    <input type="text" placeholder="아이디" id="userId" maxlength="10">
                </div>
            </div>
            <div class="input-box">
                <div class="input-label">
                    <label for="emailFirst">이메일</label> </div>
                <div class="input-wrap">
                    <input type="text" placeholder="이메일" id="emailFirst">
                </div>
                <div class="email-box flex-box gap-15 item-center">
                    <span class="email-obj">@</span>
                    <select name="email-last" class="email-last input-wrap" id="emailLast"> <option value="">이메일 선택</option>
                        <option value="naver.com">naver.com</option>
                        <option value="gmail.com">gmail.com</option>
                        <option value="hanmail.net">hanmail.net</option>
                    </select>
                </div>
            </div>
        </div>
        <div class="form-box">
            <input type="submit" value="인증코드 전송" id="sendCode" class="btn btn-light"> </div>
    </div>
</section>

<script src="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
<script src="https://unpkg.com/sweetalert/dist/sweetalert.min.js"></script>
<script src="/assets/js/common.js"></script>

<script>
    $(function () {
        const ctx = '${pageContext.request.contextPath}';

        // '인증코드 전송' 버튼 클릭 이벤트
        $("#sendCode").click(function () {
            const inputUserId = $('#userId').val().trim();
            const emailFirst = $('#emailFirst').val().trim();
            const emailLast = $('#emailLast').val().trim();

            if (!inputUserId || !emailFirst || !emailLast) {
                swal("경고", "아이디와 이메일 주소를 모두 입력해주세요.", "warning");
                return;
            }

            // 최종 이메일 주소 조합
            const finalEmail = emailFirst + '@' + emailLast;

            $.ajax({
                url: ctx + "/user/api/find-pw-code",
                type: "POST",
                contentType: "application/json",
                data: JSON.stringify({
                    userId: inputUserId,
                    email: finalEmail
                }),
                success: function(res) {
                    if (res && res.resultCode === "SUCCESS") {
                        const code = res.authCode || "코드 오류";

                        // 성공 팝업 출력 (인증 코드 포함)
                        swal("인증코드 발송 완료",
                            "인증 코드는 " + code + "입니다.\n코드를 확인하고 입력해주세요. (5분 유효)", {
                                icon: "success",
                                button: "확인",
                                closeOnClickOutside: false
                            }).then(function () {
                            // 인증 성공 시 code-pw 페이지로 이동 (아이디와 이메일 전달)
                            window.location = ctx + "/user/code-pw?userId=" + encodeURIComponent(inputUserId) +
                                "&email=" + encodeURIComponent(finalEmail);
                        });
                    } else {
                        // 실패 시 (사용자를 찾을 수 없을 때 등)
                        const msg = (res && res.message) ? res.message : "입력 정보가 일치하는 이용자를 찾을 수 없습니다.";
                        swal("검증 실패", msg, "error");
                    }
                },
                error: function(xhr) {
                    // 서버 통신 오류 처리
                    swal("통신 오류", "서버와 통신 중 문제가 발생했습니다.", "error");
                }
            });
        });
    });
</script>
</body>
</html>