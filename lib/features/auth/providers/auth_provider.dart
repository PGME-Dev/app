import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _phoneNumber;
  String? _name;
  String? _pgCollege;
  String? _ugCollege;
  bool _isAuthenticated = false;

  String? get phoneNumber => _phoneNumber;
  String? get name => _name;
  String? get pgCollege => _pgCollege;
  String? get ugCollege => _ugCollege;
  bool get isAuthenticated => _isAuthenticated;

  void setPhoneNumber(String number) {
    _phoneNumber = number;
    notifyListeners();
  }

  void setUserData({
    required String name,
    required String pgCollege,
    required String ugCollege,
  }) {
    _name = name;
    _pgCollege = pgCollege;
    _ugCollege = ugCollege;
    notifyListeners();
  }

  Future<bool> sendOTP(String phoneNumber) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    setPhoneNumber(phoneNumber);
    return true;
  }

  Future<bool> verifyOTP(String otp) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    // In real app, verify OTP with backend
    return otp == '1234' || otp.length == 4; // Mock verification
  }

  Future<bool> submitUserData({
    required String name,
    required String pgCollege,
    required String ugCollege,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    setUserData(name: name, pgCollege: pgCollege, ugCollege: ugCollege);
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  void logout() {
    _phoneNumber = null;
    _name = null;
    _pgCollege = null;
    _ugCollege = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
