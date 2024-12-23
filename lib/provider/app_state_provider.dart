import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  // 탭 변경 메서드
  void onItemTapped(int index) {
    _selectedIndex = index;
    notifyListeners(); // 상태 변경 시 UI에 알림
  }
}