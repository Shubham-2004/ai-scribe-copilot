import 'package:flutter/material.dart';
import 'package:stream_script/core/components/custom_appbar.dart';
import '../providers/patient_service.dart';
import 'package:stream_script/features/auth/services/auth_service.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  List<Map<String, dynamic>> _patients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final userId = AuthService.userData?['id'] ?? '';
    final patients = await PatientService().fetchPatients(userId);
    setState(() {
      _patients = patients;
      _loading = false;
    });
  }

  Future<void> _showAddPatientDialog() async {
    final nameController = TextEditingController();
    final dobController = TextEditingController();
    final extraController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Patient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: dobController,
              decoration: const InputDecoration(labelText: 'DOB'),
            ),
            TextField(
              controller: extraController,
              decoration: const InputDecoration(labelText: 'Extra'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final userId = AuthService.userData?['id'] ?? '';
              await PatientService().addPatient(
                userId: userId,
                name: nameController.text,
                dob: dobController.text,
                extra: extraController.text,
              );
              Navigator.pop(context);
              _loadPatients();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Patients'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _patients.isEmpty
              ? const Center(child: Text('No patients found.'))
              : ListView.builder(
                  itemCount: _patients.length,
                  itemBuilder: (context, index) {
                    final patient = _patients[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(patient['name'] ?? 'No Name'),
                        subtitle: Text('DOB: ${patient['dob'] ?? '-'}'),
                        trailing: Text(patient['extra'] ?? ''),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPatientDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add New Patient'),
        backgroundColor: const Color(0xFF4A7C7E),
      ),
    );
  }
}