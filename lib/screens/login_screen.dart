import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/app_state_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("로그인"),
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
    );
  }
}
