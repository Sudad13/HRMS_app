import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();
  bool _loading = true;

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser!;
    final data = await supabase
        .from('employees')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _departmentController.text = data['department'] ?? '';
      _positionController.text = data['position'] ?? '';
    }
    setState(() => _loading = false);
  }

  Future<void> _updateProfile() async {
    final user = supabase.auth.currentUser!;
    await supabase.from('employees').update({
      'name': _nameController.text,
      'department': _departmentController.text,
      'position': _positionController.text,
    }).eq('id', user.id);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _departmentController, decoration: const InputDecoration(labelText: 'Department')),
            TextField(controller: _positionController, decoration: const InputDecoration(labelText: 'Position')),
            const SizedBox(height: 20),
            FilledButton(onPressed: _updateProfile, child: const Text('Save Changes')),
          ],
        ),
      ),
    );
  }
}
