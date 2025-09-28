import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:stream_script/core/components/custom_appbar.dart';
import 'package:stream_script/features/auth/services/auth_service.dart';
import 'package:stream_script/features/patient_management/providers/patient_service.dart';


class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final PatientService _patientService = PatientService();
  List<Map<String, dynamic>> _patients = [];
  bool _loading = true;
  bool _showAll = false;
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
    
    // Artificial delay to better see the shimmer effect
    await Future.delayed(const Duration(milliseconds: 800));

    final patients = _showAll
        ? await _patientService.fetchAllPatients()
        : _cachedUserId.isNotEmpty
            ? await _patientService.fetchPatients(_cachedUserId)
            : <Map<String, dynamic>>[];
            
    if (mounted) {
      setState(() {
        _patients = patients;
        _loading = false;
      });
    }
  }

  Future<void> _showAddPatientDialog() async {
    final nameController = TextEditingController();
    final dobController = TextEditingController();
    final extraController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF4A7C7E)),
            SizedBox(width: 10),
            Text('Add New Patient'),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Name cannot be empty' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: extraController,
                  decoration: const InputDecoration(
                    labelText: 'Additional Notes',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A7C7E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await _patientService.addPatient(
                  userId: _cachedUserId,
                  name: nameController.text,
                  dob: dobController.text,
                  extra: extraController.text,
                );
                Navigator.pop(context);
                _loadPatients();
              }
            },
            child: const Text('Add Patient', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Patients'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F6F3), Color(0xFFFDFDFD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadPatients,
          color: const Color(0xFF4A7C7E),
          child: Column(
            children: [
              _buildPatientToggle(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPatientDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Patient', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4A7C7E),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildPatientToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildToggleButton('My Patients', !_showAll),
            ),
            Expanded(
              child: _buildToggleButton('All Patients', _showAll),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAll = text == 'All Patients';
          _loadPatients();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A7C7E) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildBody() {
    if (_loading) {
      return _buildShimmerLoading();
    }
    if (_patients.isEmpty) {
      return _buildEmptyState();
    }
    return _buildPatientList();
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) => const Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.white),
            title: SizedBox(height: 16, child: ColoredBox(color: Colors.white)),
            subtitle: SizedBox(height: 12, child: ColoredBox(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Patients Found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pull down to refresh or add a new patient.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientList() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80), // Avoid FAB overlap
        itemCount: _patients.length,
        itemBuilder: (context, index) {
          final patient = _patients[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF4A7C7E),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      patient['name'] ?? 'No Name',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('DOB: ${patient['dob']?.isEmpty ?? true ? 'N/A' : patient['dob']}'),
                    trailing: Text(patient['extra'] ?? '', style: const TextStyle(color: Colors.grey)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}