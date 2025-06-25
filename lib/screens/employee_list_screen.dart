import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> employees = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await supabase
          .from('employees')
          .select('*')
          .order('created_at', ascending: false);

      setState(() {
        employees = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load employees: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _addEmployee(String name, String department, String position) async {
    try {
      setState(() => _isProcessing = true);

      await supabase.from('employees').insert({
        'name': name,
        'department': department,
        'position': position,
      });

      await _loadEmployees();
      _showSnackBar('Employee added successfully', isError: false);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      _showSnackBar('Failed to add employee: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _updateEmployee(
      String id,
      String name,
      String department,
      String position
      ) async {
    try {
      setState(() => _isProcessing = true);

      await supabase
          .from('employees')
          .update({
        'name': name,
        'department': department,
        'position': position,
      })
          .eq('id', id);

      await _loadEmployees();
      _showSnackBar('Employee updated successfully', isError: false);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      _showSnackBar('Failed to update employee: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _deleteEmployee(String id) async {
    try {
      setState(() => _isProcessing = true);

      await supabase
          .from('employees')
          .delete()
          .eq('id', id);

      await _loadEmployees();
      _showSnackBar('Employee deleted successfully', isError: false);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      _showSnackBar('Failed to delete employee: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showEmployeeDialog(Map<String, dynamic>? employee) {
    final isEditing = employee != null;
    final nameController = TextEditingController(text: employee?['name']);
    final deptController = TextEditingController(text: employee?['department']);
    final positionController = TextEditingController(text: employee?['position']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Employee' : 'Add Employee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: deptController,
              decoration: const InputDecoration(labelText: 'Department'),
            ),
            TextField(
              controller: positionController,
              decoration: const InputDecoration(labelText: 'Position'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isProcessing
                ? null
                : () async {
              if (nameController.text.isEmpty) {
                _showSnackBar('Name is required');
                return;
              }

              if (isEditing) {
                await _updateEmployee(
                  employee!['id'],
                  nameController.text,
                  deptController.text,
                  positionController.text,
                );
              } else {
                await _addEmployee(
                  nameController.text,
                  deptController.text,
                  positionController.text,
                );
              }
              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete "$name"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteEmployee(id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isProcessing ? null : _loadEmployees,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: _isProcessing
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add),
        onPressed: _isProcessing
            ? null
            : () => _showEmployeeDialog(null),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : employees.isEmpty
          ? const Center(child: Text('No employees found'))
          : ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(employee['name']),
              subtitle: Text(
                  '${employee['position']} • ${employee['department']}'),
              trailing: _isProcessing
                  ? const CircularProgressIndicator()
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit,
                        color: Colors.blue),
                    onPressed: () =>
                        _showEmployeeDialog(employee),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(
                        employee['id'], employee['name']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}