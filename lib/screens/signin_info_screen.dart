import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shotandshoot/utils/post_user_info.dart';

import '../provider/app_state_provider.dart';

class SigninInfoScreen extends StatefulWidget {
  const SigninInfoScreen({super.key});

  @override
  State<SigninInfoScreen> createState() => _SigninInfoScreenState();
}

class _SigninInfoScreenState extends State<SigninInfoScreen> {
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
      body: PostUserInfo(),
    );
  }
}
