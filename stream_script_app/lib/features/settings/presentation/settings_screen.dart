import 'package:flutter/material.dart';
import 'package:stream_script/core/components/custom_appbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
      ),
      body: const Center(
        child: Text('Settings Screen'),
      ),
    );
  }
}
  