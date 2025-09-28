import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
	const SignUpScreen({super.key});

	@override
	State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
	final TextEditingController _emailController = TextEditingController();
	final TextEditingController _passwordController = TextEditingController();
	bool _loading = false;
	String? _error;

	Future<void> _signup() async {
		setState(() { _loading = true; _error = null; });
		final auth = AuthService();
		final res = await auth.signup(_emailController.text, _passwordController.text);
		setState(() { _loading = false; });
		if (res['error'] != null) {
			setState(() { _error = res['error'].toString(); });
		} else {
			// TODO: Navigate to home or show success
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: SafeArea(
				child: Center(
					child: SingleChildScrollView(
						padding: const EdgeInsets.symmetric(horizontal: 32),
						child: Column(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								const SizedBox(height: 24),
								Image.asset('assets/brain_mic.png', width: 80, height: 80),
								const SizedBox(height: 24),
								const Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
								const SizedBox(height: 24),
								TextField(
									controller: _emailController,
									decoration: InputDecoration(
										hintText: 'Email',
										border: OutlineInputBorder(),
									),
								),
								const SizedBox(height: 16),
								TextField(
									controller: _passwordController,
									obscureText: true,
									decoration: InputDecoration(
										hintText: 'Password',
										border: OutlineInputBorder(),
									),
								),
								const SizedBox(height: 24),
								SizedBox(
									width: double.infinity,
									child: ElevatedButton(
										style: ElevatedButton.styleFrom(
											backgroundColor: const Color(0xFF4A7C7E),
											padding: const EdgeInsets.symmetric(vertical: 16),
										),
										onPressed: _loading ? null : _signup,
										child: _loading
												? const CircularProgressIndicator(color: Colors.white)
												: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
									),
								),
								if (_error != null) ...[
									const SizedBox(height: 12),
									Text(_error!, style: const TextStyle(color: Colors.red)),
								],
							],
						),
					),
				),
			),
		);
	}
}
