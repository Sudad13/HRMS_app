import 'package:hrms_app/data/dummy_data.dart';

// Usage in EmployeeListScreen:
List<Map<String, dynamic>> employees = dummyEmployees;

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final List<Map<String, dynamic>> _attendance = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: Column(
        children: [
        ElevatedButton(
        onPressed: _markAttendance,
        child: const Text('Mark Today's Attendance'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _attendance.length,
            itemBuilder: (context, index) {
              final record = _attendance[index];
              return ListTile(
                title: Text(record['date']),
                subtitle: Text("Status: ${record['status']}"),
              );
            },
          ),
        ),
        ],
      ),
    );
  }

  void _markAttendance() {
    setState(() {
      _attendance.add({
        'date': DateTime.now().toString(),
        'status': 'Present'
      });
    });
  }
}