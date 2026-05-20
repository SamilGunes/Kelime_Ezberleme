import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = '';
  String _email = '';
  bool _isLoading = false;
  String? _error;

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get email => _email;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _username = prefs.getString('username') ?? '';
    _email = prefs.getString('email') ?? '';
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // TODO: gerçek API çağrısı buraya gelecek
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.length >= 6) {
      _isLoggedIn = true;
      _email = email;
      _username = email.split('@').first;
      await _saveToPrefs();
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _error = 'E-posta veya şifre hatalı.';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // TODO: gerçek API çağrısı buraya gelecek
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.length >= 6 && username.isNotEmpty) {
      _isLoggedIn = true;
      _email = email;
      _username = username;
      await _saveToPrefs();
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _error = 'Tüm alanları doğru doldurun.';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // --- YENİ EKLENEN ŞİFRE SIFIRLAMA METODU ---
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // TODO: Gerçek API veya Firebase sendPasswordResetEmail çağrısı buraya gelecek
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && email.contains('@')) {
      _isLoading = false;
      notifyListeners();
      return true; // E-posta başarıyla gönderildi simülasyonu
    }

    _error = 'Sisteme kayıtlı geçerli bir e-posta adresi bulunamadı.';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _username = '';
    _email = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', _isLoggedIn);
    await prefs.setString('username', _username);
    await prefs.setString('email', _email);
  }
}