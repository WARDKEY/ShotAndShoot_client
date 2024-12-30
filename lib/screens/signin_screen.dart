import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:shotandshoot/screens/login_screen.dart';
import 'package:shotandshoot/screens/signin_info_screen.dart';
import 'package:shotandshoot/service/api_service.dart';

import '../main.dart';
import '../provider/app_state_provider.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  int textAccount = 0;
  ApiService apiService = ApiService();

  void textCount() {}

  void navigateToSignInfoPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SigninInfoScreen(),
      ),
    );
  }

  void navigateToLoginPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  // 카카오 로그인
  Future<void> signInWithKakao() async {
    // 카카오 로그인 구현 예제

// 카카오톡 실행 가능 여부 확인
// 카카오톡 실행이 가능하면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk().then((value) {
          print('value from kakao $value');
          loadUser();
          navigateToSignInfoPage();
        });

        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount().then((value) {
            print('value from kakao $value');
            loadUser();
            navigateToSignInfoPage();
          });
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount().then((value) {
          print('value from kakao $value');
          loadUser();
          navigateToSignInfoPage();
        });
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }
  }

  Future<void> loadUser() async {

    try {
      User user = await UserApi.instance.me();
      print('사용자 정보 요청 성공'
          '\n회원번호: ${user.id}'
          '\n닉네임: ${user.kakaoAccount?.profile?.nickname}');

      apiService.postKakaoInfo(user.id, user.kakaoAccount?.profile!.nickname);
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
    }
  }

  // 카카오 로그아웃 (버튼 따로 없어서 만들어야 됨)
  Future<void> kakaoLogout() async {
    try {
      await UserApi.instance.logout();
      print('로그아웃 성공, SDK에서 토큰 삭제');
    } catch (error) {
      print('로그아웃 실패, SDK에서 토큰 삭제 $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("회원가입"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
                Provider.of<AppState>(context, listen: false).onItemTapped(0);
              },
              icon: Icon(Icons.home)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: () {
                signInWithKakao();
                print("카카오 로그인");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(250, 230, 77, 1),
                minimumSize: Size.fromHeight(80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    "images/kakao.png",
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(
                    width: 55,
                  ),
                  Text(
                    "카카오 로그인",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                print("네이버 로그인");
                kakaoLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(90, 196, 103, 1),
                minimumSize: Size.fromHeight(80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    "images/naver.png",
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(
                    width: 55,
                  ),
                  Text(
                    "네이버 로그인",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 45,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ))),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: '계정이 이미 있으신가요?  ',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '로그인',
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 15,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // 눌렀을 때 갈 곳 설정 = 회원가입 페이지
                                    navigateToLoginPage();
                                    print("로그인");
                                  },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
