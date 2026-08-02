import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../logic/auth_service.dart';
import '../logic/database_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final db = DatabaseService();

    return Scaffold(
      appBar: AppBar(title: const Text("Calculation History")),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.getHistory(auth.currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No history found"));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  title: Text("Method: ${data['method']}"),
                  subtitle: Text("Solved on: ${(data['timestamp'] as Timestamp?)?.toDate().toString() ?? 'N/A'}"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Optionally show full details in a dialog
                    _showDetails(context, data);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDetails(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("${data['method']} Details"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Answer:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(data['answer'].toString()),
              const SizedBox(height: 10),
              const Text("Input Matrix:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(data['matrix'].toString()),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("Close"))],
      ),
    );
  }
}
