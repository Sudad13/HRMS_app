import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceRepository {
  final _supabase = Supabase.instance.client;

  // Get today's attendance record for current user
  Future<Map<String, dynamic>?> getTodayAttendance() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final today = DateTime.now().toIso8601String().split('T').first;

    final response = await _supabase
        .from('attendance')
        .select()
        .eq('employee_id', userId)
        .eq('date', today)
        .maybeSingle();

    return response;
  }

  // Check in: Only insert if not already present
  Future<void> checkIn() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final today = DateTime.now().toIso8601String().split('T').first;

    final existing = await _supabase
        .from('attendance')
        .select()
        .eq('employee_id', userId)
        .eq('date', today)
        .maybeSingle();

    if (existing != null) {
      throw Exception('Already checked in today.');
    }

    await _supabase.from('attendance').insert({
      'employee_id': userId,
      'check_in': DateTime.now().toIso8601String(),
      'date': today,
    });
  }

  // Check out: Only update if record exists
  Future<void> checkOut() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final today = DateTime.now().toIso8601String().split('T').first;

    final existing = await _supabase
        .from('attendance')
        .select()
        .eq('employee_id', userId)
        .eq('date', today)
        .maybeSingle();

    if (existing == null) {
      throw Exception("You haven’t checked in today.");
    }

    if (existing['check_out'] != null) {
      throw Exception("You’ve already checked out.");
    }

    await _supabase
        .from('attendance')
        .update({'check_out': DateTime.now().toIso8601String()})
        .eq('id', existing['id']);
  }

  // Get all attendance records for a specific month
  Future<List<Map<String, dynamic>>> getMonthlyAttendance(int year, int month) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    final response = await _supabase
        .from('attendance')
        .select()
        .eq('employee_id', userId)
        .gte('date', firstDay.toIso8601String())
        .lte('date', lastDay.toIso8601String())
        .order('date');

    return List<Map<String, dynamic>>.from(response);
  }
}
