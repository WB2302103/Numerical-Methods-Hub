import 'package:flutter/material.dart';
import '../logic/database_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _messageController = TextEditingController();
  double _rating = 5.0;
  String _type = 'Feedback';

  void _submit() async {
    if (_messageController.text.isEmpty) return;
    
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    await DatabaseService().submitReport(_type, _messageController.text, rating: _rating);
    
    messenger.showSnackBar(SnackBar(content: Text("$_type Submitted! Thank you.")));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Support & Feedback")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _type,
              items: ['Feedback', 'Bug Report'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 20),
            if (_type == 'Feedback') ...[
              const Text("Rate your experience:"),
              Slider(
                value: _rating, 
                min: 1, max: 5, divisions: 4, 
                label: _rating.toString(),
                onChanged: (v) => setState(() => _rating = v)
              ),
            ],
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: _type == 'Feedback' ? "Your Message" : "Describe the bug",
                border: const OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submit, child: const Text("Submit"))
          ],
        ),
      ),
    );
  }
}
