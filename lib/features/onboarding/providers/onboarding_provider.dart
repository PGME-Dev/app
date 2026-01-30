import 'package:flutter/material.dart';

class OnboardingProvider with ChangeNotifier {
  int _currentPage = 0;
  bool _hasSeenOnboarding = false;

  int get currentPage => _currentPage;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage < 3) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  void completeOnboarding() {
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  void reset() {
    _currentPage = 0;
    notifyListeners();
  }
}
