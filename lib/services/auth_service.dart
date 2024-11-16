import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthService {
  static const String baseUrl = 'https://60b1-175-158-56-88.ngrok-free.app/api';
  static const String userKey = 'user_data';
  static const String tokenKey = 'auth_token';

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final userId = data['data']['id'];

        // Save token
        await _saveToken(token);

        // Fetch user details
        final userResponse = await http.get(
          Uri.parse('$baseUrl/admin/users/$userId'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (userResponse.statusCode == 200) {
          final userData = json.decode(userResponse.body)['data'];
          final user = User.fromJson(userData);

          // Save user data
          await _saveUserData(user);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, json.encode(user.toJson()));
  }

  Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userKey);
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userKey);
    await prefs.remove(tokenKey);
  }
}
