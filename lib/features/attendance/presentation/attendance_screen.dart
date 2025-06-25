import 'package:flutter/material.dart';
import 'package:hrms_app/features/attendance/data/attendance_repository.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceRepository _repo = AttendanceRepository();
  Map<String, dynamic>? _todayAttendance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);
    try {
      _todayAttendance = await _repo.getTodayAttendance();
    } catch (e) {
      print('Error loading attendance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load attendance: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _handleCheckIn() async {
    try {
      await _repo.checkIn();
      await _loadAttendance();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checked in successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleCheckOut() async {
    try {
      await _repo.checkOut();
      await _loadAttendance();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checked out successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
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

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '--:--';
    final time = DateTime.parse(isoTime);
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Current Status Card
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today\'s Status', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      _todayAttendance?['status'] ?? 'Not Checked In',
                      style: TextStyle(
                        fontSize: 18,
                        color: _getStatusColor(_todayAttendance?['status']),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_todayAttendance?['check_in'] != null)
                      Text('Check In: ${_formatTime(_todayAttendance!['check_in'])}'),
                    if (_todayAttendance?['check_out'] != null)
                      Text('Check Out: ${_formatTime(_todayAttendance!['check_out'])}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Check In/Out Buttons
            if (_todayAttendance == null)
              FilledButton(
                onPressed: _handleCheckIn,
                child: const Text('Check In'),
              )
            else if (_todayAttendance?['check_out'] == null)
              FilledButton(
                onPressed: _handleCheckOut,
                child: const Text('Check Out'),
              )
            else
              const Text('Attendance completed for today.'),

            const SizedBox(height: 20),

            // Monthly Attendance Summary
            const Text('Monthly Summary', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder(
                future: _repo.getMonthlyAttendance(
                  DateTime.now().year,
                  DateTime.now().month,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final data = snapshot.data ?? [];

                  if (data.isEmpty) {
                    return const Center(child: Text('No attendance records found.'));
                  }

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final record = data[index];
                      return ListTile(
                        leading: Icon(Icons.calendar_today, size: 20),
                        title: Text(record['date'].split('T').first),
                        subtitle: Text(
                          'In: ${_formatTime(record['check_in'])} - Out: ${_formatTime(record['check_out'])}',
                        ),
                        trailing: Text(
                          record['status'] ?? '',
                          style: TextStyle(
                            color: _getStatusColor(record['status']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
