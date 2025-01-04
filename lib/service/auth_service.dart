import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../provider/app_state_provider.dart';
import '../screens/signin_info_screen.dart';
import 'api_service.dart';

class AuthService {
  final BuildContext context;

  AuthService(this.context);

  void navigateToSignInfoPage({required String id}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SigninInfoScreen(id: id),
      ),
    );
  }

  void navigateToMainPage() {
    Navigator.pop(context);
    Provider.of<AppState>(context, listen: false).onItemTapped(0);
  }

  // 카카오 로그인
  Future<void> signInWithKakao() async {
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
        await kakaoLoadUser();
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');
        if (error is PlatformException && error.code == 'CANCELED') return;

        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
          await kakaoLoadUser();
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
        await kakaoLoadUser();
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }
  }

  Future<void> kakaoLoadUser() async {
    try {
      User user = await UserApi.instance.me();
      print(
          '사용자 정보 요청 성공: ${user.id}, ${user.kakaoAccount?.profile?.nickname}');

      bool isUserRegistered = await ApiService.postKakaoInfo(
        user.id.toString(),
        user.kakaoAccount?.profile?.nickname,
      );

      if (isUserRegistered) {
        navigateToMainPage();
      } else {
        navigateToSignInfoPage(id: user.id.toString());
      }
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
    }
  }

  // 구글 로그인
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        print(
            'Google 로그인 성공: ${googleUser.displayName}, ${googleUser.email}, ${googleUser.id}');

        bool isUserRegistered = await ApiService.postGoogleInfo(
          googleUser.id,
          googleUser.displayName,
        );

        if (isUserRegistered) {
          navigateToMainPage();
        } else {
          navigateToSignInfoPage(id: googleUser.id.toString());
        }
      }
    } catch (error) {
      print('Google 로그인 실패 $error');
    }
  }
}
