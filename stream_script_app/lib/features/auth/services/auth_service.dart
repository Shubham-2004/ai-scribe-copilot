import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://streamscript.onrender.com/auth';

  // Session storage
  static String? accessToken;
  static Map<String, dynamic>? userData;

  Future<Map<String, dynamic>> signup(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final result = jsonDecode(response.body);

    // Save session if signup returns token/user
    if (result['access_token'] != null) {
      accessToken = result['access_token'];
      userData = result['user'];
    }

    return result;
  }
  Future<Map<String, dynamic>> signin(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final result = jsonDecode(response.body);

    // Save session if signin returns token/user
    if (result['access_token'] != null) {
      accessToken = result['access_token'];
      userData = result['user'];
      // Store login timestamp
      userData?['loginTimestamp'] = DateTime.now().toIso8601String();
    }

    return result;
  }

  // Clear session
  void signout() {
    accessToken = null;
    userData = null;
  }

  // Check if user is logged in
  bool get isLoggedIn => accessToken != null;
}