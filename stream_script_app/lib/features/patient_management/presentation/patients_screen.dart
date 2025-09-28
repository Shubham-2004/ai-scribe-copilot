import 'package:flutter/material.dart';
import 'package:stream_script/core/components/custom_appbar.dart';
import '../providers/patient_service.dart';
import 'package:stream_script/features/auth/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart'; // <-- Add this import

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  List<Map<String, dynamic>> _patients = [];
  bool _loading = true;
  bool _showAll = false; // Toggle for all/user patients
  String _cachedUserId = '';

  @override
  void initState() {
    super.initState();
    _loadCachedUserId();
  }

Future<void> _loadCachedUserId() async {
  String userId = AuthService.userData?['id'] ?? '';
  if (userId.isEmpty) {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
  }
  print('Loaded userId: $userId'); // Debug print
  if (mounted) {
    setState(() {
      _cachedUserId = userId;
    });
    _loadPatients();
  }
}

  Future<void> _loadPatients() async {
    if (!mounted) return;
    setState(() => _loading = true);
    if (_showAll) {
      final patients = await PatientService().fetchAllPatients();
      if (mounted) {
        setState(() {
          _patients = patients;
          _loading = false;
        });
      }
    } else {
      final userId = _cachedUserId;
      if (userId.isEmpty) {
        if (mounted) {
          setState(() {
            _patients = [];
            _loading = false;
          });
        }
        return;
      }
      final patients = await PatientService().fetchPatients(userId);
      if (mounted) {
        setState(() {
          _patients = patients;
          _loading = false;
        });
      }
    }
  }

  Future<void> _showAddPatientDialog() async {
    final nameController = TextEditingController();
    final dobController = TextEditingController();
    final extraController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Patient'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: dobController,
                decoration: const InputDecoration(labelText: 'DOB (YYYY-MM-DD)'),
              ),
              TextField(
                controller: extraController,
                decoration: const InputDecoration(labelText: 'Extra'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final userId = _cachedUserId;
              if (userId.isEmpty || nameController.text.isEmpty) {
                Fluttertoast.showToast(
                    msg: "Patient name cannot be empty.",
                    backgroundColor: Colors.orange);
                return;
              }

              // Store the result of the addPatient call
              final newPatient = await PatientService().addPatient(
                userId: userId,
                name: nameController.text,
                dob: dobController.text,
                extra: extraController.text,
              );

              // Check if the patient was created and the widget is still mounted
              if (newPatient != null && context.mounted) {
                Navigator.pop(context); // Close the dialog first
                
                // Show success toast
                Fluttertoast.showToast(
                  msg: "Patient '${newPatient['name']}' created!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                _loadPatients(); // Refresh the list
              } else {
                // Show error toast if it fails
                Fluttertoast.showToast(
                  msg: "Failed to create patient. Please try again.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
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
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAll = false;
                    });
                    _loadPatients();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_showAll ? const Color(0xFF4A7C7E) : Colors.grey.shade300,
                    foregroundColor: !_showAll ? Colors.white : Colors.black87,
                    elevation: !_showAll ? 4 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('My Patients', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAll = true;
                    });
                    _loadPatients();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showAll ? const Color(0xFF4A7C7E) : Colors.grey.shade300,
                    foregroundColor: _showAll ? Colors.white : Colors.black87,
                    elevation: _showAll ? 4 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('All Patients', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _patients.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('No patients found.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _patients.length,
                      itemBuilder: (context, index) {
                        final patient = _patients[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: const Color(0xFF4A7C7E).withOpacity(0.15),
                                  child: Icon(Icons.person, color: const Color(0xFF4A7C7E), size: 30),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        patient['name'] ?? 'No Name',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF335D5F),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.cake_outlined, size: 18, color: Colors.teal.shade200),
                                          const SizedBox(width: 6),
                                          Text(
                                            patient['dob'] ?? '-',
                                            style: TextStyle(color: Colors.grey.shade700),
                                          ),
                                        ],
                                      ),
                                      if ((patient['extra'] ?? '').isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(Icons.info_outline, size: 18, color: Colors.orange.shade300),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                patient['extra'] ?? '',
                                                style: TextStyle(color: Colors.grey.shade600),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Tooltip(
                                  message: 'Delete',
                                  child: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          title: Row(
                                            children: const [
                                              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                                              SizedBox(width: 8),
                                              Text('Delete Patient'),
                                            ],
                                          ),
                                          content: Text(
                                            "Are you sure you want to delete '${patient['name']}'?",
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        final success = await PatientService().deletePatient(patient['id'].toString());
                                        if (success && context.mounted) {
                                          Fluttertoast.showToast(
                                            msg: "Patient deleted!",
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                          );
                                          _loadPatients();
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: "Failed to delete patient.",
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _showAddPatientDialog,
      icon: const Icon(Icons.add),
      label: const Text('Add New Patient', style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: const Color(0xFF4A7C7E),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
}