import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  State<EmployeeAttendanceScreen> createState() => _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  final supabase = Supabase.instance.client;

  List<dynamic> _employees = [];
  String? _selectedEmployeeId;
  List<dynamic> _attendance = [];

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    print("Loading employees...");
    try {
      final result = await supabase.from('employees').select('id, name').order('name');
      print("Result: $result");

      setState(() {
        _employees = result;
        _loading = false;
      });
    } catch (e) {
      print("Failed to load employees: $e");
      setState(() => _loading = false);
    }
  }


  Future<void> _loadAttendance() async {
    if (_selectedEmployeeId == null) return;

    final startDate = DateTime(_selectedYear, _selectedMonth, 1);
    final endDate = DateTime(_selectedYear, _selectedMonth + 1, 0);

    final result = await supabase
        .from('attendance')
        .select()
        .eq('employee_id', _selectedEmployeeId!)
        .gte('date', startDate.toIso8601String())
        .lte('date', endDate.toIso8601String())
        .order('date');

    setState(() {
      _attendance = result;
    });
  }

  Widget _buildAttendanceList() {
    if (_attendance.isEmpty) {
      return const Text('No attendance records for this month.');
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _attendance.length,
      itemBuilder: (context, index) {
        final record = _attendance[index];
        return ListTile(
          title: Text(record['date'].toString().split('T').first),
          subtitle: Text(
              'Check-In: ${_formatTime(record['check_in'])} | Check-Out: ${_formatTime(record['check_out'])}'),
          trailing: Text(
            record['status'] ?? 'Unknown',
            style: TextStyle(
              color: _getStatusColor(record['status']),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Late':
        return Colors.orange;
      case 'Absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(String? time) {
    if (time == null) return '--:--';
    final dt = DateTime.parse(time);
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Attendance')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Dropdown
            DropdownButtonFormField<String>(
              value: _selectedEmployeeId,
              hint: const Text('Select Employee'),
              items: _employees.map<DropdownMenuItem<String>>((emp) {
                return DropdownMenuItem(
                  value: emp['id'], // a String
                  child: Text(emp['name']),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedEmployeeId = val;
                });
                _loadAttendance();
              },
            ),

            const SizedBox(height: 12),

            // Month/Year Picker
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedMonth,
                    items: List.generate(12, (i) {
                      return DropdownMenuItem(
                        value: i + 1,
                        child: Text('Month ${i + 1}'),
                      );
                    }),
                    onChanged: (val) {
                      setState(() => _selectedMonth = val!);
                      _loadAttendance();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear,
                    items: [2024, 2025, 2026].map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text('$year'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedYear = val!);
                      _loadAttendance();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text('Attendance Records', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(child: _buildAttendanceList()),
          ],
        ),
      ),
    );
  }
}
