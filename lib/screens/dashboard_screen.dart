import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_screen.dart';
import 'package:hrms_app/features/attendance/presentation/attendance_screen.dart';
import 'attendance_history_screen.dart';
import 'leave_approval_screen.dart';
import 'leave_request_screen.dart';
import 'profile_screen.dart';
import 'manage_employees_screen.dart';

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
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        role = 'unknown';
        _loading = false;
      });
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${user?.email ?? 'User'}!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 30),

            FilledButton.icon(
              icon: const Icon(Icons.access_time),
              label: const Text('Check In / Out'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.edit_calendar),
              label: const Text('Request Leave'),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LeaveRequestScreen()));
              },
            ),

            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('Attendance History'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()),
                );
              },
            ),
            const SizedBox(height: 12),

            FilledButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('My Profile'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),

            if (role == 'admin') ...[
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
              Text('Admin Panel', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),

              FilledButton.icon(
                icon: const Icon(Icons.manage_accounts),
                label: const Text('Manage Employees'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ManageEmployeesScreen()),
                  );
                },
              ),

              FilledButton.icon(
                icon: const Icon(Icons.request_page),
                label: const Text('Approve Leave Requests'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LeaveApprovalScreen()));
                },
              ),

            ],
          ],
        ),
      ),
    );
  }
}
