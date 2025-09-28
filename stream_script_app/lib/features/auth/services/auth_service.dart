import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
	static const String baseUrl = 'https://streamscript.onrender.com/auth';

	Future<Map<String, dynamic>> signup(String email, String password) async {
		final response = await http.post(
			Uri.parse('$baseUrl/signup'),
			headers: {'Content-Type': 'application/json'},
			body: jsonEncode({'email': email, 'password': password}),
		);
		return jsonDecode(response.body);
	}

	Future<Map<String, dynamic>> signin(String email, String password) async {
		final response = await http.post(
			Uri.parse('$baseUrl/signin'),
			headers: {'Content-Type': 'application/json'},
			body: jsonEncode({'email': email, 'password': password}),
		);
		return jsonDecode(response.body);
	}
}
