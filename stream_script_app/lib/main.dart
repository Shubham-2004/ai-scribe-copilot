import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- Add this import
import 'features/onboarding/presentation/splash_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/bottomNav/presentation/bottomNavbar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://yojlumklmggiqycatsch.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlvamx1bWtsbWdnaXF5Y2F0c2NoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwNDU5MDksImV4cCI6MjA3NDYyMTkwOX0.H9lBr_nue_lN-CWC0Fk0-eHe8avNG8b-ZHDq2NREv2w',
  );
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