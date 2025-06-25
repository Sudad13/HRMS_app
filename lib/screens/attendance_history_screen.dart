import 'package:flutter/material.dart';
import 'package:hrms_app/features/attendance/data/attendance_repository.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AttendanceRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: FutureBuilder(
        future: repo.getMonthlyAttendance(DateTime.now().year, DateTime.now().month),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? [];

          if (data.isEmpty) return const Center(child: Text('No attendance records'));

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final record = data[index];
              return ListTile(
                title: Text(record['date'].split('T').first),
                subtitle: Text('In: ${_format(record['check_in'])} - Out: ${_format(record['check_out'])}'),
                trailing: Text(record['status']),
              );
            },
          );
        },
      ),
    );
  }

  String _format(String? iso) {
    if (iso == null) return '--:--';
    final dt = DateTime.parse(iso);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
