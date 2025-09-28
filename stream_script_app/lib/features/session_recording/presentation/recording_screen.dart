import 'package:flutter/material.dart';
import 'package:stream_script/core/components/custom_appbar.dart';

class RecordingScreen extends StatelessWidget {
  const RecordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Recording',
      ),
      body: const Center(
        child: Text('Recording Screen'),
      ),
    );
  }
}
  