import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:shotandshoot/screens/board_screen.dart';
import 'package:shotandshoot/screens/company_screen.dart';
import 'package:shotandshoot/screens/login_screen.dart';
import 'package:shotandshoot/screens/main_screen.dart';
import 'package:shotandshoot/screens/mypage_screen.dart';
import 'package:shotandshoot/screens/post_write.dart';
import 'package:shotandshoot/screens/scan_screen.dart';
import 'package:shotandshoot/provider/app_state_provider.dart';
import 'package:shotandshoot/screens/signin_screen.dart';

void main() async {
  // 웹 환경에서 카카오 로그인을 정상적으로 완료하려면 runApp() 호출 전 아래 메서드 호출 필요
  WidgetsFlutterBinding.ensureInitialized();

  // kakao login

  // runApp() 호출 전 Flutter SDK 초기화
  await dotenv.load();
  KakaoSdk.init(
    // 키 설정 (공유x)
    nativeAppKey: dotenv.get('NATIVE_APP_KEY'),
    javaScriptAppKey: dotenv.get('JAVASCRIPT_APP_KEY'),
  );

  await NaverMapSdk.instance.initialize(clientId: dotenv.get('CLIENT_KEY'));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Shot and Shoot',
        theme: ThemeData(scaffoldBackgroundColor: Colors.white),
        home: AppPage(),
      ),
    );
  }
}

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  final List _widgetOptions = [
    MainScreen(),
    BoardScreen(),
    ScanScreen(),
    CompanyScreen(),
    MypageScreen(),
    LoginScreen(),
    SigninScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: _widgetOptions[appState.selectedIndex],
          bottomNavigationBar: ConvexAppBar(
            items: [
              TabItem(icon: Icons.home, title: '홈'),
              TabItem(icon: Icons.assignment, title: '게시판'),
              TabItem(icon: Icons.camera_alt, title: '폐기물 스캔'),
              TabItem(icon: Icons.transfer_within_a_station, title: '대행업체'),
              TabItem(icon: Icons.person, title: '마이'),
            ],
            onTap: appState.onItemTapped,
            initialActiveIndex:
                appState.selectedIndex < 5 ? appState.selectedIndex : 0,
            style: TabStyle.fixedCircle,
            curveSize: 95,
            top: -40,
            backgroundColor: Colors.white,
            activeColor: Color(0xff748d6f),
            color: Color(0xff748d6f),
            height: 60,
          ),
        );
      },
    );
  }
}
