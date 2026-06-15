<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>  <!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css"/>
    <link rel="stylesheet" href="/assets/css/style.css">
    <script src="/assets/js/jquery-3.6.0.min.js"></script>
    <title>PLAY TTT! 아이디 확인</title>
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

<section id="checkId" class="form-bg">
    <div class="header">
        <h1>
            <a href="${pageContext.request.contextPath}/">
                <img src="/assets/images/main-logo.png" alt="메인로고">
            </a>
        </h1>
    </div>
    <div class="inner form-wrap">
        <div class="title-graphic">
            <img src="/assets/images/obj-left.png" alt="장식" class="obj-left">
            <img src="/assets/images/obj-right.png" alt="장식" class="obj-right">
        </div>

        <div class="form-box result-box">
            <c:choose>
                <c:when test="${not empty foundUserId}">
                    <p class="result-message">
                        <span class="import">${userNickname}</span>님의 아이디는<br>
                        "<span class="import">${foundUserId}</span>"입니다.
                    </p>
                </c:when>
                <c:otherwise>
                    <p class="result-message error-message">
                        아이디를 찾을 수 없거나,<br>
                        인증 시간이 만료되었습니다.<br>
                        다시 시도해 주세요.
                    </p>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="form-box">
            <%-- 인라인 onclick을 제거하고 id만 남겼습니다. --%>
            <input type="button" value="로그인 페이지로" id="goLogin" class="btn btn-primary">
        </div>
    </div>
</section>

<script src="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
<script src="https://unpkg.com/sweetalert/dist/sweetalert.min.js"></script>
<script src="/assets/js/common.js"></script>

<script>
    $(function() {
        const ctx = '${pageContext.request.contextPath}';

        /**
         * [1. 보안 및 주소창 세탁 로직]
         * 진입 시 URL 파라미터에 노출된 이메일을 즉시 제거합니다.
         */
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('email')) {
            // 브라우저 주소창에서 파라미터 제거 (localhost:8115/user/check-id만 남김)
            if (window.history.replaceState) {
                window.history.replaceState({}, null, window.location.pathname);
            }
        }

        /**
         * [2. 로그인 버튼 클릭 이벤트]
         * 모든 찾기 프로세스가 끝났으므로 관련 세션을 정리하고 이동합니다.
         */
        $("#goLogin").click(function() {
            // 그동안 사용했던 모든 찾기 관련 세션 데이터 정리
            sessionStorage.removeItem('findIdEmail');
            sessionStorage.removeItem('resultEmail');

            // 로그인 페이지로 이동
            location.href = ctx + '/user/login';
        });
    });
</script>
</body>
</html>