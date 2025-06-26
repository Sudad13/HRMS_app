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

  Future<List<dynamic>> _fetchMyLeaveRequests() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final result = await supabase
        .from('leave_requests')
        .select()
        .eq('employee_id', userId)
        .order('created_at', ascending: false);
    return result;
  }


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
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _departmentController,
                decoration: const InputDecoration(labelText: 'Department'),
              ),
              TextField(
                controller: _positionController,
                decoration: const InputDecoration(labelText: 'Position'),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _updateProfile,
                child: const Text('Save Changes'),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const Text('My Leave Requests', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              FutureBuilder(
                future: _fetchMyLeaveRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final requests = snapshot.data ?? [];
                  if (requests.isEmpty) {
                    return const Text('No leave requests yet.');
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final req = requests[index];
                      return ListTile(
                        title: Text('${req['start_date']} ➝ ${req['end_date']}'),
                        subtitle: Text(req['reason'] ?? ''),
                        trailing: Text(
                          req['status'],
                          style: TextStyle(
                            color: req['status'] == 'Approved'
                                ? Colors.green
                                : req['status'] == 'Rejected'
                                ? Colors.red
                                : Colors.orange,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

}
