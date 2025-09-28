import 'dart:convert';
import 'package:http/http.dart' as http;

class PatientService {
  static const String baseUrl = 'https://streamscript.onrender.com';

  Future<List<Map<String, dynamic>>> fetchPatients(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patients?userId=$userId'),
    );
    final result = jsonDecode(response.body);
    if (response.statusCode == 200 && result['patients'] != null) {
      return List<Map<String, dynamic>>.from(result['patients']);
    }
    return [];
  }

  // Fetch all patients (no userId filter)
  Future<List<Map<String, dynamic>>> fetchAllPatients() async {
    final response = await http.get(
      Uri.parse('$baseUrl/patients'),
    );
    final result = jsonDecode(response.body);
    if (response.statusCode == 200 && result['patients'] != null) {
      return List<Map<String, dynamic>>.from(result['patients']);
    }
    return [];
  }

  Future<Map<String, dynamic>?> addPatient({
    required String userId,
    required String name,
    String? dob,
    String? extra,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add-patient-ext'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'name': name,
        'dob': dob,
        'extra': extra,
      }),
    );
    final result = jsonDecode(response.body);
    if (response.statusCode == 200 && result['patient'] != null) {
      return result['patient'];
    }
    return null;
  }
}