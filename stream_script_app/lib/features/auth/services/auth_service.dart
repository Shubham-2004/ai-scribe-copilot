import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Session storage
  static String? accessToken;
  static Map<String, dynamic>? userData;

  Future<Map<String, dynamic>> signup(String email, String password) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user != null) {
      accessToken = response.session?.accessToken;
      userData = response.user!.toJson();
      return {
        'access_token': accessToken,
        'user': userData,
      };
    }
    return {
      'error': response.session == null ? 'Signup failed' : null,
    };
  }

  Future<Map<String, dynamic>> signin(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user != null) {
      accessToken = response.session?.accessToken;
      userData = response.user!.toJson();
      userData?['loginTimestamp'] = DateTime.now().toIso8601String();
      return {
        'access_token': accessToken,
        'user': userData,
      };
    }
    return {
      'error': 'Signin failed',
    };
  }

  // Clear session
  void signout() {
    accessToken = null;
    userData = null;
    _supabase.auth.signOut();
  }

  bool get isLoggedIn => accessToken != null;
}