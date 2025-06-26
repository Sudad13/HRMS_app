import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final supabase = Supabase.instance.client;
  final _reasonController = TextEditingController();
  DateTimeRange? _selectedRange;

  Future<void> _submitRequest() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null || _selectedRange == null || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fill all fields')));
      return;
    }

    await supabase.from('leave_requests').insert({
      'employee_id': userId,
      'start_date': _selectedRange!.start.toIso8601String(),
      'end_date': _selectedRange!.end.toIso8601String(),
      'reason': _reasonController.text,
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave request submitted')));
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Leave')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FilledButton(
              onPressed: _pickDateRange,
              child: const Text('Select Date Range'),
            ),
            const SizedBox(height: 12),
            if (_selectedRange != null)
              Text(
                  'From ${_selectedRange!.start.toLocal().toString().split(" ")[0]} to ${_selectedRange!.end.toLocal().toString().split(" ")[0]}'),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'Reason'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitRequest,
              child: const Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}
