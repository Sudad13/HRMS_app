import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_screen.dart';
import '../features/attendance/presentation/attendance_screen.dart';
import 'attendance_history_screen.dart';
import 'profile_screen.dart';
import 'leave_request_screen.dart';
import 'leave_approval_screen.dart';
import 'manage_employees_screen.dart';
import 'employee_attendance_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabase = Supabase.instance.client;
  String? role;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final data = await supabase
        .from('employees')
        .select('role')
        .eq('id', userId)
        .maybeSingle();

    setState(() {
      role = data?['role'] ?? 'employee';
      _loading = false;
    });
  }

  void _logout() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  Widget _buildTile(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Welcome, ${user?.email ?? 'User'}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            _buildTile('Check In / Out', Icons.access_time, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AttendanceScreen()));
            }),
            _buildTile('Attendance History', Icons.history, () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AttendanceHistoryScreen()));
            }),
            _buildTile('Request Leave', Icons.edit_calendar, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LeaveRequestScreen()));
            }),
            _buildTile('Profile', Icons.person, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()));
            }),
            if (role == 'admin') ...[
              const SizedBox(height: 20),
              const Divider(),
              const Text('Admin Tools',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTile('Approve Leave Requests', Icons.approval, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LeaveApprovalScreen()));
              }),
              _buildTile('Employee Attendance', Icons.list_alt, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeAttendanceScreen()),
                );
              }),

              _buildTile('Manage Employees', Icons.manage_accounts, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageEmployeesScreen()));
              }),
            ]
          ],
        ),
      ),
    );
  }
}
