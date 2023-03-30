import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  static const _url =
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyAl7_8zQ6D6RRPFx3_g5CXZUalB41tySHc';

  Future<void> signup(String email, String password) async {
    final response = await http.post(Uri.parse(_url),
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }));
  }
}