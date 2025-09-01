import 'package:flutter/material.dart';

/// Home screen state management provider
/// Handles navigation between different pages in the bottom navigation
class HomeProvider extends ChangeNotifier {
  int _currentIndex = 0;
  late PageController _pageController;

  HomeProvider() {
    _pageController = PageController(initialPage: _currentIndex);
  }

  // Getters
  int get currentIndex => _currentIndex;
  PageController get pageController => _pageController;

  /// Set current index and notify listeners
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  /// Navigate to specific page
  void navigateToPage(int index) {
    _currentIndex = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
