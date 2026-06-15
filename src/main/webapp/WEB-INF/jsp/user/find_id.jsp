<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<meta charset="UTF-8">
<%-- CSRF 토큰을 사용하기 위해 Spring Security 태그 라이브러리를 사용한다고 가정 --%>
<%-- 그렇지 않다면, Spring MVC에서 토큰 값을 모델에 담아 전달해야 합니다. 현재는 기존 회원가입 로직을 따라 JSP 내에서 직접 ${ _csrf.token }을 사용합니다. --%>


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


<section id="findID" class="form-bg">
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
                <div class="input-label">
                    <label for="addEmailFirst">이메일</label>
                </div>
                <div class="input-wrap">
                    <input type="text" placeholder="이메일" id="addEmailFirst">
                    <%-- 최종 이메일 주소를 백엔드에 전송하기 위해 hidden input 추가 --%>
                    <input type="hidden" id="fullEmail" name="email">
                </div>
                <div class="email-box flex-box gap-15 item-center">
                    <span class="email-obj">@</span>
                    <select id="emailDomain" class="email-last input-wrap">
                        <option value="">이메일 선택</option>
                        <option value="naver.com">naver.com</option>
                        <option value="gmail.com">gmail.com</option>
                        <option value="hanmail.net">hanmail.net</option>
                        <%-- @naver.com 대신 naver.com으로 수정했습니다. JS에서 @를 추가합니다. --%>
                    </select>
                </div>
            </div>
        </div>
        <div class="form-box">
            <%-- onclick="sendCodeID()" 대신 jQuery 이벤트 리스너를 사용하기 위해 onclick 제거 --%>
            <input type="submit" value="인증코드 전송" id="sandCode" class="btn btn-light">
        </div>
    </div>
</section>

<script src="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
<script src="https://unpkg.com/sweetalert/dist/sweetalert.min.js"></script>
<script src="/assets/js/common.js"></script>

<script>
    $(function () {
        const ctx = '${pageContext.request.contextPath}';

        // 이메일 도메인 변경 시 @ 기호 처리
        $('#emailDomain').change(function() {
            const domain = $(this).val();
            if (domain && domain !== "") {
                $('.email-obj').show();
            } else {
                $('.email-obj').hide();
            }
        }).trigger('change'); // 초기 로드 시 실행

        // '인증코드 전송' 버튼 클릭 이벤트 처리
        $("#sandCode").click(function () {
            // 1. 이메일 조합
            const emailFirst = $('#addEmailFirst').val().trim(); // 이메일 앞부분 입력 필드 ID
            const emailDom   = $('#emailDomain').val();         // 이메일 도메인 선택 필드 ID

            if (!emailFirst || !emailDom) {
                swal("경고", "이메일 주소를 모두 입력 또는 선택해 주세요.", {
                    icon: "warning",
                    button: "확인"
                });
                return;
            }

            const finalEmail = emailFirst + '@' + emailDom;

            const params = {
                email: finalEmail
            };

            // 2. AJAX 요청
            $.ajax({
                url: ctx + "/user/api/find-id-code",
                type: "POST",
                contentType: "application/json",
                // CSRF 토큰 사용 (Spring Security를 사용할 경우 필요)
                headers: { 'X-CSRF-TOKEN': '${_csrf.token}' },
                data: JSON.stringify(params),
                success: function (res) {
                    if (res && res.resultCode === "SUCCESS") {
                        // ★ 응답에서 인증 코드를 가져와 메시지에 포함 ★
                        const code = res.authCode || "코드 오류";

                        swal("인증코드 발송 완료",
                            "인증 코드는 " + code + "입니다.\n코드를 확인하고 입력해주세요. (5분 유효)", { // ★ 코드를 표시 ★
                                icon: "success",
                                button: "확인",
                                closeOnClickOutside: false
                            }).then(function () {
                            window.location = ctx + "/user/code-id?email=" + encodeURIComponent(finalEmail);
                        });

                    } else {
                        const msg = (res && res.message) ? res.message : "인증코드 요청에 실패했습니다. 이메일을 확인해 주세요.";
                        swal("요청 실패", msg, {
                            icon: "error",
                            button: "확인",
                            closeOnClickOutside: false
                        });
                    }
                },
                error: function (xhr) {
                    // 서버 통신 오류 (4xx, 5xx) 처리
                    let msg = "서버 통신 중 알 수 없는 오류가 발생했습니다.";
                    if (xhr.responseJSON && xhr.responseJSON.message) {
                        msg = xhr.responseJSON.message;
                    }
                    swal("통신 오류", msg, { icon: "error", button: "확인", closeOnClickOutside: false });
                }
            });
        });
    });
</script>
</body>
</html>