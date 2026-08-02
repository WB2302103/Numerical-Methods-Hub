import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../logic/auth_service.dart';
import '../logic/database_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final db = DatabaseService();

    return Scaffold(
      appBar: AppBar(title: const Text("Saved Favorites")),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.getFavorites(auth.currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 15),
                  Text("No favorites yet", style: TextStyle(color: Colors.grey.shade600, fontSize: 18)),
                  const Text("Save problems from the solver screen to see them here."),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text("${data['method']}"),
                  subtitle: Text("Saved: ${(data['savedAt'] as Timestamp?)?.toDate().toString().substring(0, 10) ?? 'N/A'}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => db.deleteFavorite(auth.currentUserId!, doc.id),
                  ),
                  onTap: () => _showDetails(context, data),
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
        title: Text("Saved ${data['method']}"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Answer:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(data['answer'].toString()),
              const SizedBox(height: 10),
              const Text("Matrix:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(data['matrix'].toString()),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("Close"))],
      ),
    );
  }
}
