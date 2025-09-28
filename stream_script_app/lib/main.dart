import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'features/onboarding/presentation/splash_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/bottomNav/presentation/bottomNavbar.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StreamScript',
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SessionGate(),
    );
  }
}

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  bool? _loggedIn;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Simulate async session check (replace with your logic if needed)
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _loggedIn = AuthService().isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loggedIn == null) {
      // Show splash while checking session
      return const SplashScreen();
    }
    return _loggedIn! ? const BottomNavbar() : const SplashScreen();
  }
}