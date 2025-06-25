import 'package:flutter/material.dart';
import 'package:hrms_app/data/dummy_data.dart';
import 'package:hrms_app/features/attendance/presentation/attendance_screen.dart';

// Usage in EmployeeListScreen:
List<Map<String, dynamic>> employees = dummyEmployees;
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HRMS Dashboard')),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          _buildFeatureCard(
            context,
            icon: Icons.people,
            title: 'Employees',
            route: '/employees',
          ),
          _buildFeatureCard(
            context,
            icon: Icons.calendar_today,
            title: 'Attendance',
            route: '/attendance',
          ),
          _buildFeatureCard(
            context,
            icon: Icons.payment,
            title: 'Payroll',
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
  leading: const Icon(Icons.calendar_today),
  title: const Text('Attendance'),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AttendanceScreen()),
  ),
),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {
    required IconData icon,
    required String title,
    String? route,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap ?? () => Navigator.pushNamed(context, route!),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('This feature is under development'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}