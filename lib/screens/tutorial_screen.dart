import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class TutorialScreen extends StatelessWidget {
  final String? topic;
  const TutorialScreen({super.key, this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topic != null ? 'Help: $topic' : 'Theory & Tutorials'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tutorials').snapshots(),
        builder: (context, snapshot) {
          // Filter logic for dynamic data
          List<DocumentSnapshot> filteredDocs = [];
          if (snapshot.hasData) {
            filteredDocs = snapshot.data!.docs;
            if (topic != null) {
              filteredDocs = filteredDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return (data['title'] ?? '').toString().toLowerCase() == topic!.toLowerCase();
              }).toList();
            }
          }

          // If no matching dynamic data or Firestore is empty, show default ones
          if (filteredDocs.isEmpty) {
            return _buildDefaultTutorials(topic);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final data = filteredDocs[index].data() as Map<String, dynamic>;
              return _buildTutorialCard(
                title: data['title'] ?? 'Tutorial', 
                content: data['content'] ?? '',
                videoUrl: data['videoUrl'],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDefaultTutorials(String? filterTopic) {
    final Map<String, Map<String, String>> tutorials = {
      'Gaussian Elimination': {
        'content': 'A method for solving linear systems through a sequence of row operations to transform the coefficient matrix into an upper triangular form. Once in triangular form, back-substitution is used to find the variables.',
        'videoUrl': 'https://youtu.be/prVPD0sTp-k?si=b8H7l4fed2Gqfr59',
      },
      'LU Decomposition': {
        'content': 'Factors a matrix A into the product of a lower triangular matrix L and an upper triangular matrix U (A = LU). It is highly efficient for solving multiple systems with the same coefficient matrix but different constants.',
        'videoUrl': 'https://youtu.be/Ef2gf_--VMM?si=50AAV1k9ViwYMaDQ',
      },
      'Matrix Inversion': {
        'content': 'Solves the system by calculating the inverse of matrix A (A⁻¹) and multiplying it by the constant vector b (x = A⁻¹b). This method is direct but computationally expensive for large matrices.',
        'videoUrl': 'https://youtu.be/B9Z2e9LSuNw?si=vFQfnDj90CKfxPfy',
      },
      'Jacobi Iterative Method': {
        'content': 'An iterative algorithm for determining the solutions of a diagonally dominant system of linear equations. Each diagonal element is solved for, and an approximate value is plugged in.',
        'videoUrl': 'https://youtu.be/O5TnXFkNcwk?si=CI4rrxy_n7Kap1CQ',
      },
      'Gauss-Seidel Method': {
        'content': 'An improvement over the Jacobi method. It uses the latest updated values as soon as they are available within the same iteration, usually leading to faster convergence.',
        'videoUrl': 'https://youtu.be/91cTAP8-Z5E?si=HWeq78i9ZKorfrg6',
      },
    };

    List<String> keysToShow = tutorials.keys.toList();
    if (filterTopic != null) {
      keysToShow = keysToShow.where((key) => key.toLowerCase() == filterTopic.toLowerCase()).toList();
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ...keysToShow.map((key) => _buildTutorialCard(
          title: key,
          content: tutorials[key]!['content']!,
          videoUrl: tutorials[key]!['videoUrl'],
        )),
        const SizedBox(height: 20),
        const Card(
          color: Colors.indigoAccent,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Note: You can watch real video tutorials by clicking the buttons above.',
              style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTutorialCard({required String title, required String content, String? videoUrl}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: ExpansionTile(
        initiallyExpanded: topic != null, // Auto-expand if coming from a specific solver
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
                if (videoUrl != null && videoUrl.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchURL(videoUrl),
                      icon: const Icon(Icons.play_circle_fill, color: Colors.red),
                      label: const Text('Watch Video Tutorial'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.indigo,
                        side: const BorderSide(color: Colors.indigo),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
