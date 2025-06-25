import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hrms_app/screens/employee_list_screen.dart';
import 'package:hrms_app/screens/dashboard_screen.dart';
import 'package:hrms_app/screens/auth_screen.dart';

import 'dart:io'; // Add this import for Directory/File

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Debugging: Print current directory and check .env file
//   debugPrint('Current directory: ${Directory.current.path}');
//
//   final envFile = File('${Directory.current.path}/.env');
//   debugPrint('.env exists: ${envFile.existsSync()}');
//
//   // Load environment variables with fallback
//   try {
//     await dotenv.load(fileName: ".env");
//     debugPrint('Environment variables loaded successfully');
//   } catch (e) {
//     debugPrint('Error loading .env: $e');
//     // Fallback to hardcoded values if .env fails
//     await _initializeSupabaseWithFallback();
//     return;
//   }
//
//   // Main Supabase initialization
//   await _initializeSupabase();
// }
//
// Future<void> _initializeSupabase() async {
//   try {
//     await Supabase.initialize(
//       url: dotenv.get('SUPABASE_URL'),
//       anonKey: dotenv.get('SUPABASE_KEY'),
//     );
//     runApp(const MyApp());
//   } catch (e) {
//     debugPrint('Supabase init error: $e');
//     _runErrorApp(e.toString());
//   }
// }
//
// Future<void> _initializeSupabaseWithFallback() async {
//   try {
//     await Supabase.initialize(
//       url: 'https://pjeolvtjssuqgesfejzh.supabase.co',
//       anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqZW9sdnRqc3N1cWdlc2ZlanpoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1Mjg2MDcsImV4cCI6MjA2NjEwNDYwN30.1Gn3raU_OHfwYNBWbr8pyMDVVnA1Ki4PS0wmqUsRJQk',
//     );
//     runApp(const MyApp());
//   } catch (e) {
//     debugPrint('Fallback init error: $e');
//     _runErrorApp(e.toString());
//   }
// }
//
// void _runErrorApp(String error) {
//   runApp(MaterialApp(
//     home: Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text('Initialization Error', style: TextStyle(fontSize: 20)),
//             const SizedBox(height: 20),
//             Text(error, textAlign: TextAlign.center),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => exit(0),
//               child: const Text('Exit App'),
//             ),
//           ],
//         ),
//       ),
//     ),
//   ));
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'HRMS App',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const DashboardScreen(),
//     );
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://pjeolvtjssuqgesfejzh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqZW9sdnRqc3N1cWdlc2ZlanpoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1Mjg2MDcsImV4cCI6MjA2NjEwNDYwN30.1Gn3raU_OHfwYNBWbr8pyMDVVnA1Ki4PS0wmqUsRJQk',
  );

  final session = Supabase.instance.client.auth.currentSession;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: 'HRMS App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: session != null ? const DashboardScreen() : const AuthScreen(),
    );
  }
}

