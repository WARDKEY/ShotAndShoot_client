import 'package:flutter/material.dart';
import 'package:shotandshoot/main.dart';

class SigninLoginScreen extends StatefulWidget {
  const SigninLoginScreen({super.key});

  @override
  State<SigninLoginScreen> createState() => _SigninLoginScreenState();
}

class _SigninLoginScreenState extends State<SigninLoginScreen> {
  void navigateMainPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MyApp(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Color(0xff748d6f),
            size: 60,
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '회원가입 완료',
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xff748d6f),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            "정상적으로 가입이 완료되었습니다.",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            '로그인 후 이용하세요.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              // 로그인 시 처리
              navigateMainPage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff748d6f),
              elevation: 0,
              minimumSize: Size(200, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              '로그인하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
