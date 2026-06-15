<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%---------------------------------------%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- 라이브러리/스타일 -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <script src="${pageContext.request.contextPath}/assets/js/jquery-3.6.0.min.js"></script>
    <title>PLAY TTT! 회원가입</title>
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

<!-- 회원가입 완료 팝업 (성공 시 보여줌) -->
<div class="popup-contents signin-contents common-popup fixed" style="display:none;">
    <div class="popup-inner flex-just-center center">
        <p>회원가입이 완료 되었습니다.<br>
            로그인페이지로 돌아갑니다.</p>
        <input type="button" value="로그인 페이지로" id="signin-success-btn" class="btn btn-primary"
               onclick="location.href='${pageContext.request.contextPath}/user/login'">
    </div>
</div>

<section id="signin" class="form-bg">
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

        <!-- ✅ 회원가입 폼 시작 -->
<%--       <form id="joinForm" action="${pageContext.request.contextPath}/user/join" method="post" novalidate>--%>
       <form id="joinForm"  method="post" novalidate>
            <div class="form-box">
                <!-- 아이디 -->
                <div class="input-box">
                    <div class="input-label most">
                        <label for="addID">아이디</label>
                    </div>
                    <div class="input-wrap">
                        <!-- UI는 10자 제한, 서버는 20자 제한(도메인 기준) → UI 기준 유지 -->
                        <input type="text" placeholder="문자종류 상관없이 최대 10자리." id="addID" name="userId" maxlength="10" required>
                    </div>
                    <div class="error-message">
                        <p id="idError" class="hidden"></p>
                    </div>
                </div>

                <!-- 비밀번호 / 비밀번호 확인 -->
                <div class="input-box">
                    <div class="input-label most">
                        <label for="addPW">비밀번호</label>
                    </div>
                    <div class="input-wrap flex-box item-center just-between">
                        <input type="password" placeholder="문자종류 상관없이 최대 10자리." id="addPW" name="password" maxlength="10" required>
                        <img src="${pageContext.request.contextPath}/assets/images/icon-pw.svg" alt="비밀번호" class="icon">
                    </div>

                    <div class="input-label most">
                        <label for="addPWcheck">비밀번호 확인</label>
                    </div>
                    <div class="input-wrap flex-box item-center just-between">
                        <!-- 확인 필드는 서버로 보내지 않음 -->
                        <input type="password" placeholder="비밀번호 확인" id="addPWcheck" maxlength="10" required>
                        <img src="${pageContext.request.contextPath}/assets/images/icon-pw.svg" alt="비밀번호 확인" class="icon">
                    </div>
                    <div class="error-message">
                        <p id="pwError" class="hidden"></p>
                    </div>
                </div>
            </div>

            <div class="form-box">
                <!-- 닉네임 -->
                <div class="input-box">
                    <div class="input-label most">
                        <label for="addNickname">닉네임</label>
                    </div>
                    <div class="input-wrap">
                        <input type="text" placeholder="문자종류 상관없이 최대 10자리." id="addNickname" name="nickname" maxlength="10" required>
                    </div>
                    <div class="error-message">
                        <p id="nickError" class="hidden"></p>
                    </div>
                </div>

                <!-- 이메일 -->

                <script>
                    $(function () {
                        $('#emailDomain, #addEmailFirst').on('change input', function(){
                            const first = $('#addEmailFirst').val().trim();
                            const dom   = $('#emailDomain').val();
                            $('#fullEmail').val(first && dom ? (first + '@' + dom) : '');
                        });
                    });
                </script>


                <div class="input-box">
                    <div class="input-label most">
                        <label for="addEmailFirst">이메일</label>
                    </div>
                    <div class="input-wrap">
                        <input type="text" placeholder="이메일" id="addEmailFirst" maxlength="30" required>
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                    </div>
                    <div class="email-box flex-box gap-15 item-center">
                        <span class="email-obj">@</span>
                        <select id="emailDomain" class="email-last input-wrap" required>
                            <option value="">이메일 선택</option>
                            <option value="naver.com">naver.com</option>
                            <option value="gmail.com">gmail.com</option>
                            <option value="hanmail.net">hanmail.net</option>

                        </select>
                    </div>
                    <!-- 서버로 전달할 전체 이메일 값 -->
                    <input type="hidden" name="email" id="fullEmail">
                    <div class="error-message">
                        <p id="emailError" class="hidden"></p>
                    </div>
                </div>
            </div>

            <div class="form-box">
                <input type="button" value="가입하기" id="signinBtn" class="btn btn-light">
            </div>
        </form>
        <!-- ✅ 회원가입 폼 끝 -->
    </div>
</section>

<script src="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
<script src="https://unpkg.com/sweetalert/dist/sweetalert.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>

<script>
    /**
     * [1. URL 파라미터 에러 처리]
     * 서버 측 리다이렉트 시 전달된 에러 메시지가 있다면 사용자에게 알림을 띄웁니다.
     */
    document.addEventListener('DOMContentLoaded', function(){
        const params = new URLSearchParams(window.location.search);
        const err = params.get('error');
        if (err) {
            // URL 인코딩된 에러 메시지를 디코딩하여 출력
            alert(decodeURIComponent(err));
        }
    });

    $(function() {
        /**
         * [2. 주요 DOM 요소 변수화]
         * 코드 가독성과 재사용성을 위해 입력창 및 에러 메시지 요소를 변수에 할당합니다.
         */
        const $form = $('#joinForm');
        const $userId = $('#addID');
        const $pw = $('#addPW');
        const $pw2 = $('#addPWcheck');
        const $nick = $('#addNickname');
        const $emailFirst = $('#addEmailFirst');
        const $emailDomain = $('#emailDomain');
        const $fullEmail = $('#fullEmail');

        const $idError = $('#idError');
        const $pwError = $('#pwError');
        const $nickError = $('#nickError');
        const $emailError = $('#emailError');

        /**
         * [3. 에러 표시 공통 함수]
         * @param $input : 입력창 요소
         * @param $errorEl : 에러 메시지를 표시할 요소
         * @param msg : 에러 메시지 내용 (없으면 에러 해제)
         */
        function setError($input, $errorEl, msg) {
            const $wrap = $input.closest('.input-box');
            // msg가 존재하면 error-box 클래스를 추가하고 메시지를 보여줌
            $wrap.toggleClass('error-box', !!msg);
            if (msg) {
                $errorEl.removeClass('hidden').text(msg);
            } else {
                $errorEl.addClass('hidden').text('');
            }
        }

        /**
         * [4. 가입하기 버튼 클릭 이벤트]
         * 클라이언트 사이드 검증 후 서버로 AJAX 요청을 보냅니다.
         */
        $("#signinBtn").click(function () {
            let ok = true; // 최종 전송 여부 확인 변수

            // 입력값 추출 및 공백 제거
            const userId     = $userId.val().trim();
            const pw         = $pw.val();
            const pw2        = $pw2.val();
            const nick       = $nick.val().trim();
            const emailFirst = $emailFirst.val().trim();
            const emailDom   = $emailDomain.val();

            // 이메일 조합 (아이디 + @ + 도메인) 및 hidden input 업데이트
            const finalEmail = (emailFirst && emailDom) ? (emailFirst + '@' + emailDom) : '';
            $fullEmail.val(finalEmail);

            // ===== [5. 유효성 검증 (Validation)] =====

            // 아이디 검사
            if (!userId) {
                setError($userId, $idError, '아이디를 입력하세요.');
                ok = false;
            } else if (userId.length > 10) {
                setError($userId, $idError, '아이디는 10자 이하여야 합니다.');
                ok = false;
            } else {
                setError($userId, $idError, '');
            }

            // 비밀번호 검사 (비어있음, 길이, 일치 여부)
            if (!pw) {
                setError($pw, $pwError, '비밀번호를 입력하세요.');
                ok = false;
            } else if (pw.length > 10) {
                setError($pw, $pwError, '비밀번호는 10자 이하여야 합니다.');
                ok = false;
            } else if (pw !== pw2) {
                setError($pw, $pwError, '비밀번호가 일치하지 않습니다.');
                ok = false;
            } else {
                setError($pw, $pwError, '');
            }

            // 닉네임 검사
            if (!nick) {
                setError($nick, $nickError, '닉네임을 입력하세요.');
                ok = false;
            } else if (nick.length > 10) {
                setError($nick, $nickError, '닉네임은 10자 이하여야 합니다.');
                ok = false;
            } else {
                setError($nick, $nickError, '');
            }

            // 이메일 검사
            if (!emailFirst || !emailDom) {
                setError($emailFirst, $emailError, '이메일과 도메인을 입력/선택하세요.');
                ok = false;
            } else {
                setError($emailFirst, $emailError, '');
            }

            // 검증 실패 시 중단
            if (!ok) return;

            // ===== [6. 서버 전송 (AJAX)] =====

            // 서버로 보낼 JSON 객체 구성
            const params = {
                userId   : userId,
                password : pw,
                nickname : nick,
                email    : finalEmail
            };

            const ctx = '${pageContext.request.contextPath}';
            // Spring Security 연동 시 필요한 CSRF 토큰 (필요한 경우 사용)
            const headers = { 'X-CSRF-TOKEN': '${_csrf.token}' };

            $.ajax({
                url: ctx + "/user/api/join",
                type: "POST",
                contentType: "application/json",
                headers: headers,
                data: JSON.stringify(params),
                success: function (res) {
                    // 서버 응답이 성공인 경우
                    if (res && res.resultCode === "SUCCESS") {
                        swal("회원가입에 성공했습니다.", {
                            icon: "success",
                            button: "로그인 페이지로",
                            closeOnClickOutside: false
                        }).then(function () {
                            // 확인 클릭 시 로그인 페이지로 이동
                            window.location = ctx + "/user/login";
                        });
                    } else {
                        // 서버 로직 상 가입 실패 (예: 아이디 중복 등)
                        const msg = (res && res.message) ? res.message : "회원가입에 실패했습니다.";
                        swal(msg, {
                            icon: "error",
                            button: "확인",
                            closeOnClickOutside: false
                        });
                    }
                },
                error: function (xhr) {
                    // 네트워크 오류 또는 서버 에러(500 등) 처리
                    let msg = "서버 통신 중 오류가 발생했습니다.";
                    try {
                        const parsed = xhr.responseJSON || JSON.parse(xhr.responseText);
                        if (parsed && parsed.message) msg = parsed.message;
                    } catch (e) {}
                    swal(msg, {
                        icon: "error",
                        button: "확인",
                        closeOnClickOutside: false
                    });
                }
            });
        });
    });
</script>
</body>