import 'package:flutter/material.dart';

class RecordingScreen extends StatelessWidget {
  const RecordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording'),
      ),
      body: const Center(
        child: Text('Recording Screen'),
      ),
    );
  }
}
  