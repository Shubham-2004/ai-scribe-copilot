import 'package:flutter/material.dart';
import 'package:stream_script/core/components/custom_appbar.dart';

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Patients',
      ),
      body: const Center(
        child: Text('Patients Screen'),
      ),
    );
  }
}