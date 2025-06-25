import 'package:flutter/material.dart';
import 'package:hrms_app/data/dummy_data.dart';

// Usage in EmployeeListScreen:
List<Map<String, dynamic>> employees = dummyEmployees;
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Signup Screen')),
    );
  }
}