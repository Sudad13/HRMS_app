import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  State<LeaveApprovalScreen> createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final data = await supabase
        .from('leave_requests')
        .select('id, start_date, end_date, reason, status, employees(name)')
        .order('created_at', ascending: false);

    setState(() {
      _requests = data;
      _loading = false;
    });
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    await supabase.from('leave_requests').update({'status': newStatus}).eq('id', id);
    _loadRequests(); // refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approve Leave Requests')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text('${request['employees']['name']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('From: ${request['start_date']}'),
                  Text('To: ${request['end_date']}'),
                  Text('Reason: ${request['reason']}'),
                  Text('Status: ${request['status']}'),
                ],
              ),
              trailing: request['status'] == 'Pending'
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _updateStatus(request['id'], 'Approved'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _updateStatus(request['id'], 'Rejected'),
                  ),
                ],
              )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
