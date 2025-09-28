import 'package:supabase_flutter/supabase_flutter.dart';

class PatientService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetches a list of patients associated with a specific user ID.
  Future<List<Map<String, dynamic>>> fetchPatients(String userId) async {
    try {
      final response = await _supabase
          .from('patients')
          .select()
          .eq('user_id', userId);
      
      // Supabase's .select() returns a List<dynamic>, so we cast it.
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      print('Error fetching patients: ${e.message}');
      return [];
    } catch (e) {
      print('An unexpected error occurred: $e');
      return [];
    }
  }

  /// Fetches all patients from the database, regardless of the user.
  Future<List<Map<String, dynamic>>> fetchAllPatients() async {
    try {
      final response = await _supabase
          .from('patients')
          .select();
          
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      print('Error fetching all patients: ${e.message}');
      return [];
    } catch (e) {
      print('An unexpected error occurred: $e');
      return [];
    }
  }

  /// Adds a new patient to the database and returns the created record.
  Future<Map<String, dynamic>?> addPatient({
    required String userId,
    required String name,
    String? dob,
    String? extra,
  }) async {
    try {
      // .select().single() efficiently returns the new row in one call
      final response = await _supabase
          .from('patients')
          .insert({
            'user_id': userId,
            'name': name,
            'dob': dob,
            'extra': extra,
          })
          .select()
          .single();

      return response;
    } on PostgrestException catch (e) {
      print('Error adding patient: ${e.message}');
      return null;
    } catch (e) {
      print('An unexpected error occurred: $e');
      return null;
    }
  }

  /// Updates an existing patient's details using their unique ID.
  Future<Map<String, dynamic>?> updatePatient({
    required String patientId, // The primary key of the patient
    required String name,
    String? dob,
    String? extra,
  }) async {
    try {
      final response = await _supabase
          .from('patients')
          .update({
            'name': name,
            'dob': dob,
            'extra': extra,
          })
          .eq('id', patientId) // Filter by the patient's primary key
          .select()
          .single();

      return response;
    } on PostgrestException catch (e) {
      print('Error updating patient: ${e.message}');
      return null;
    } catch (e) {
      print('An unexpected error occurred: $e');
      return null;
    }
  }

  /// Deletes a patient from the database using their unique ID.
  /// Returns true on success and false on failure.
  Future<bool> deletePatient(String patientId) async {
    try {
      await _supabase
          .from('patients')
          .delete()
          .eq('id', patientId);
          
      return true; // Success
    } on PostgrestException catch (e) {
      print('Error deleting patient: ${e.message}');
      return false;
    } catch (e) {
      print('An unexpected error occurred: $e');
      return false;
    }
  }
}