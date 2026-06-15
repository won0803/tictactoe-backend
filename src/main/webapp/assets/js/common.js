

var popup = $('.popup-contents');
var popdown = $('.popup-down');
var guidePopup = $('.guide-contents');
var guideInner = $('.guide-inner');
var popupInner = $('.popup-inner');
var guideBtn = $('#guideBtn');
var closeBtn = $('.close-btn ');
var guideSlide = $('.guide-slide-inner');

$(document).ready(function () {
    guideSlide.slick({
        slide: 'div',
        dots: true,
        arrows: false,
        slidesToShow: 1,
        setPosition: 0, //깨짐 방지
        infinite: false,
    });

    $('.guide-prev').click(function () {
        guideSlide.slick('slickPrev');
    });

    $('.guide-next').click(function (e) {
        e.preventDefault();
        guideSlide.slick('slickNext');
    });

    guideBtn.click(function () {
        guideInner.removeClass('bounce-out');
        guideInner.addClass('bounce');
        guidePopup.fadeIn(300);
        guideSlide.resize();
        guideSlide.slick('refresh'); // 팝업 열때 슬라이드 깨짐 방지
    });

    closeBtn.click(function () {
        popupInner.removeClass('bounce');
        popupInner.addClass('bounce-out');
        popup.delay(300).fadeOut(300);
    });

    // popup-down 클래스가 있는 경우, 공백 클릭 시 팝업 닫힘
    $(document).mouseup(function (e) {
        if (popdown.has(e.target).length === 0) {
            popdown.find(popupInner).removeClass('bounce');
            popdown.find(popupInner).addClass('bounce-out');
            popdown.delay(300).fadeOut(500);
        }
    });
});


// UI-ALERT-CODEERROR
function codeError() {
    swal("인증코드가 일치하지 않습니다.",
        {
            icon: "error",
            button: "확인",
        });
}

// UI-ALERT-FINDIDERROR
function findIDerror() {
    swal("해당 이메일을 사용하는 이용자를 찾을 수 없습니다.",
        {
            icon: "error",
            button: "확인",
        });
}

// UI-ALERT-PWCHANGEERROR
function pwError() {
    swal("비밀번호가 유효하지 않습니다.",
        {
            icon: "error",
            button: "확인",
        });
}

// UI-POPUP-PWCHANGESUCCESS
function pwChangeSuccess() {

    var changepwPopup = $('.changepw-contents');
    var changepwInner = changepwPopup.find('.popup-inner');

    changepwInner.removeClass('bounce-out');
    changepwInner.addClass('bounce');
    changepwPopup.fadeIn(300);


}

// UI-ALERT-FINDIDCODE
function findIDcode() {
    swal("인증코드는 000000 입니다.",
        {
            icon: "warning",
            iconColor: '#F241A3',
            button: "확인",
            closeOnClickOutside: false,
        }).then(function () {
            // 코드 입력 페이지 이동.
            window.location = "code_id.html";
        });
}

// UI-ALERT-FINDPWCODE
function findPWcode() {
    swal("인증코드는 000000 입니다.",
        {
            icon: "warning",
            iconColor: '#F241A3',
            button: "확인",
            closeOnClickOutside: false,
        }).then(function () {
            // 코드 입력 페이지 이동.
            window.location = "code_pw.html";
        });
}

// UI-ALERT-NAMECHANGEERROR
function nameChangeError() {
    swal("유효하지 않은 닉네임 입니다.",
        {
            icon: "warning",
            iconColor: '#F241A3',
            button: "확인",
        });
}

// UI-ALERT-NAMECHANGESUCCESS
function nameChangeSuccess() {
    swal("닉네임이 변경 되었습니다.",
        {
            icon: "success",
            button: "확인",
        }).then(function(){
            location.reload();
        });
}

// UI-ALERT-PWCHANGESUCCESS
function pwChangeSuccess() {
    swal("비밀번호 변경이 완료 되었습니다.\n변경 된 비밀번호로 로그인해주세요.",
        {
            icon: "success",
            button: "로그인 페이지로",
            closeOnClickOutside: false,

        }).then(function () {
            // 로그인 페이지 이동.
            window.location = "login.html";
        });
}

// UI-ALERT-FINDPWERROR
function findPWerror() {
    swal("아이디, 이메일 값이 유효하지 않습니다.",
        {
            icon: "error",
            button: "확인",

        });
}

// UI-ALERT-SCORERESET
// common.js
function scoreReset() {
    // 1. 아이디가 정확히 잡히는지 콘솔로 먼저 확인하세요.
    const currentUserId = new URLSearchParams(window.location.search).get('userId') || $('.user-name').text().replace('(나)', '').trim();
    console.log("리셋 요청 아이디 확인:", currentUserId);

    swal("정말로 리셋하시겠습니까?", {
        buttons: ["취소", "확인"],
    }).then((val) => {
        if (val) {
            $.ajax({
                // 2. UserController의 @RequestMapping("/user")를 고려한 경로
                url: '/user/reset-rank',
                type: 'POST',
                contentType: 'application/json',
                // 3. 데이터를 JSON 문자열로 정확히 변환하여 전송
                data: JSON.stringify({ "userId": currentUserId }),
                success: function(res) {
                    console.log("서버 응답:", res);
                    if(res === "success") {
                        swal("성공", "리셋 완료", "success").then(() => location.reload());
                    } else {
                        swal("실패", "서버 로직 오류", "error");
                    }
                },
                error: function(xhr) {
                    swal("에러", "주소나 서버 연결 확인", "error");
                }
            });
        }
    });
}

// UI-ALERT-LOGOUT
function logOut() {
    swal("로그아웃 되었습니다.\n첫 페이지로 이동합니다.",
        {
            icon: "success",
            button: "확인",
            closeOnClickOutside: false,

        }).then(function () {
            // 로그인 페이지 이동.
            window.location = "login.html";
        });
}


// UI-ALERT-UNREGISTER
function unregister() {
    swal({
        text: '정말로 탈퇴 하시나요?\n탈퇴를 원하시면 하단 입력창에\n“탈퇴합니다”를 입력해 주세요.',
        content: "input",
        closeOnClickOutside: false,
        buttons: {
            cancel: "취소",
            catch: {
                text: "확인",
            }
        },
    }).then((value) => {
        switch (value) {
            case "catch":
                swal("회원 탈퇴가 처리 되었습니다.\n첫 페이지로 이동합니다.",
                    {
                        icon: "success",
                        button: "확인",
                        closeOnClickOutside: false,

                    }).then(function () {
                        // 로그인 페이지 이동.
                        window.location = "index.html";
                    });
                break;
        }
    });
}


// UI-ALERT-CONNECTERROR
function connectError() {
    swal("게임 방 제목을 입력해주세요.",
        {
            icon: "error",
            button: "확인",

        });
}


// UI-ALERT-CONNECTERROR
function findPWerror() {
    swal("접속이 불가능 한 방입니다.",
        {
            icon: "error",
            button: "확인",

        });
}

// UI-ALERT-ROOMOUT
function roomOut() {
    swal("정말 게임 방을 나가시겠습니까?",
        {
            icon: "warning",
            buttons: {
                cancel: "취소",
                catch: {
                    text: "확인",
                }
            }

        }).then((value) => {
            switch (value) {
                case "catch": window.location = "main.html";
                break;
                default : 
                break;
            }
        });
}