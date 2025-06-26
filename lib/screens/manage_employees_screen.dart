import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageEmployeesScreen extends StatefulWidget {
  const ManageEmployeesScreen({super.key});

  @override
  State<ManageEmployeesScreen> createState() => _ManageEmployeesScreenState();
}

class _ManageEmployeesScreenState extends State<ManageEmployeesScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> _employees = [];
  List<dynamic> _filteredEmployees = [];
  bool _loading = true;
  String _searchQuery = '';

  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();
  String _selectedRole = 'employee';

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    final result = await supabase.from('employees').select().order('created_at');
    setState(() {
      _employees = result;
      _applyFilter();
      _loading = false;
    });
  }

  void _applyFilter() {
    _filteredEmployees = _employees.where((emp) {
      final name = emp['name']?.toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _updateRole(String uuid, String newRole) async {
    await supabase.from('employees').update({'role': newRole}).eq('id', uuid);
    _loadEmployees();
  }

  Future<void> _deleteEmployee(String uuid) async {
    await supabase.from('employees').delete().eq('id', uuid);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Employee deleted')));
    _loadEmployees();
  }

  void _showCreateEmployeeDialog() {
    _nameController.clear();
    _departmentController.clear();
    _positionController.clear();
    _selectedRole = 'employee';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Employee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _departmentController, decoration: const InputDecoration(labelText: 'Department')),
            TextField(controller: _positionController, decoration: const InputDecoration(labelText: 'Position')),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: const [
                DropdownMenuItem(value: 'employee', child: Text('Employee')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                if (value != null) _selectedRole = value;
              },
              decoration: const InputDecoration(labelText: 'Role'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: _createEmployeeWithoutLogin,
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _createEmployeeWithoutLogin() async {
    if (_nameController.text.isEmpty) return;

    await supabase.from('employees').insert({
      'name': _nameController.text,
      'department': _departmentController.text,
      'position': _positionController.text,
      'role': _selectedRole,
      'id': 'manual-${DateTime.now().millisecondsSinceEpoch}', // Fake ID for non-auth employees
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Employee created')));
    _loadEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateEmployeeDialog,
            tooltip: 'Create Employee',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilter();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredEmployees.length,
              itemBuilder: (context, index) {
                final emp = _filteredEmployees[index];
                return Card(
                  child: ListTile(
                    title: Text(emp['name'] ?? 'No Name'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dept: ${emp['department']} | Pos: ${emp['position']}'),
                        Text('Role: ${emp['role']}'),
                        Text('ID: ${emp['id']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<String>(
                          value: emp['role'],
                          items: const [
                            DropdownMenuItem(value: 'employee', child: Text('Employee')),
                            DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          ],
                          onChanged: (value) {
                            if (value != null && value != emp['role']) {
                              _updateRole(emp['id'], value);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEmployee(emp['id']),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
