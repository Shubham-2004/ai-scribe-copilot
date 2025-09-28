import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import '../../bottomNav/presentation/bottomNavbar.dart';

class SignInScreen extends StatefulWidget {
	final String? initialEmail;
	final String? initialPassword;
	const SignInScreen({super.key, this.initialEmail, this.initialPassword});

	@override
	State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
		late TextEditingController _emailController;
		late TextEditingController _passwordController;
		bool _loading = false;
		String? _error;

		@override
		void initState() {
			super.initState();
			_emailController = TextEditingController(text: widget.initialEmail ?? '');
			_passwordController = TextEditingController(text: widget.initialPassword ?? '');
		}

		Future<void> _login() async {
			setState(() { _loading = true; _error = null; });
			final auth = AuthService();
			final res = await auth.signin(_emailController.text, _passwordController.text);
			setState(() { _loading = false; });
			if (res['error'] != null) {
				setState(() { _error = res['error'].toString(); });
			} else {
				// Navigate to BottomNavbar on success
				Navigator.of(context).pushReplacement(
					MaterialPageRoute(
						builder: (context) => const BottomNavbar(),
					),
				);
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
								Image.asset('assets/images/brain_mic.png', width: 80, height: 80),
								const SizedBox(height: 24),
								const Text('Welcome Back', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
								const SizedBox(height: 24),
								TextField(
									controller: _emailController,
									decoration: InputDecoration(
										hintText: 'Email/Username',
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
										onPressed: _loading ? null : _login,
										child: _loading
												? const CircularProgressIndicator(color: Colors.white)
												: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
									),
								),
								if (_error != null) ...[
									const SizedBox(height: 12),
									Text(_error!, style: const TextStyle(color: Colors.red)),
								],
																const SizedBox(height: 16),
																Row(
																	mainAxisAlignment: MainAxisAlignment.center,
																	children: [
																		const Text("Don't have an account? ", style: TextStyle(color: Colors.black54)),
																		TextButton(
																			onPressed: () {
																				Navigator.of(context).push(
																					MaterialPageRoute(
																						builder: (context) => const SignUpScreen(),
																					),
																				);
																			},
																			child: const Text('Sign Up', style: TextStyle(color: Color(0xFF4A7C7E), fontWeight: FontWeight.bold)),
																		),
																	],
																),
							],
						),
					),
				),
			),
		);
	}
}
