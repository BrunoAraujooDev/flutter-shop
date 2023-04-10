import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/store.dart';
import 'package:shop/exception/auth_expection.dart';
import 'package:shop/utils/config_env.dart';

class Auth with ChangeNotifier {
  String? _email;
  String? _token;
  String? _uid;
  DateTime? _expireDate;
  Timer? _logoutTimer;

  bool get isAuth {
    final isValid = _expireDate?.isAfter(DateTime.now()) ?? false;

    return _token != null && isValid;
  }

  String? get token {
    return isAuth ? _token : null;
  }

  String? get email {
    return isAuth ? _email : null;
  }

  String? get uid {
    return isAuth ? _uid : null;
  }

  Future<void> _authenticate(
      String email, String password, String urlFragment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlFragment?key=${ConfigEnv.key}';

    final response = await http.post(Uri.parse(url),
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }));

    final body = jsonDecode(response.body);

    if (body['error'] != null) {
      throw AuthException(body['error']['message']);
    } else {
      _token = body['idToken'];
      _email = body['email'];
      _uid = body['localId'];
      _expireDate = DateTime.now().add(
        Duration(
          seconds: int.parse(body['expiresIn']),
        ),
      );

      Store.saveMap('userData', {
        'token': _token,
        'email': _email,
        'userId': _uid,
        'expireDate': _expireDate!.toIso8601String(),
      });
      _autoLogout();
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> tryAutoLogin() async {
    if (isAuth) return;

    final userData = await Store.getMap('userData');

    if (userData.isEmpty) return;

    final expireDate = DateTime.parse(userData['expireDate']);

    if (expireDate.isBefore(DateTime.now())) return;

    _token = userData['token'];
    _email = userData['email'];
    _uid = userData['userId'];
    _expireDate = expireDate;

    _autoLogout();
    notifyListeners();
  }

  void logout() {
    _email = null;
    _token = null;
    _uid = null;
    _expireDate = null;

    _clearLogoutTimer();
    Store.remove('userData').then((_) => notifyListeners());
  }

  void _clearLogoutTimer() {
    _logoutTimer?.cancel();
    _logoutTimer = null;
  }

  void _autoLogout() {
    _clearLogoutTimer();

    final timeToExpire = _expireDate?.difference(DateTime.now()).inSeconds;
    _logoutTimer = Timer(
      Duration(seconds: timeToExpire ?? 0),
      logout,
    );
  }
}
