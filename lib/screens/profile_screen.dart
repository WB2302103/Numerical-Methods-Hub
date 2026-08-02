import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/auth_service.dart';
import '../logic/database_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _uniController = TextEditingController();
  final _deptController = TextEditingController();
  final _semController = TextEditingController();
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final user = await auth.getUserProfile(auth.currentUserId!);
    if (user != null) {
      if (!mounted) return;
      setState(() {
        _nameController.text = user.name;
        _uniController.text = user.university;
        _deptController.text = user.department;
        _semController.text = user.semester;
        _isLoading = false;
      });
    }
  }

  void _updateProfile() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);
    final db = DatabaseService();
    final auth = Provider.of<AuthService>(context, listen: false);
    
    await db.updateUserProfile(auth.currentUserId!, {
      'name': _nameController.text.trim(),
      'university': _uniController.text.trim(),
      'department': _deptController.text.trim(),
      'semester': _semController.text.trim(),
    });

    messenger.showSnackBar(const SnackBar(content: Text("Profile Updated")));
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Profile")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 20),
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Name")),
                TextField(controller: _uniController, decoration: const InputDecoration(labelText: "University")),
                TextField(controller: _deptController, decoration: const InputDecoration(labelText: "Department")),
                TextField(controller: _semController, decoration: const InputDecoration(labelText: "Semester")),
                const SizedBox(height: 30),
                ElevatedButton(onPressed: _updateProfile, child: const Text("Save Changes")),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    final authService = Provider.of<AuthService>(context, listen: false);
                    final navigator = Navigator.of(context);
                    await authService.signOut();
                    navigator.pop();
                  }, 
                  child: const Text("Sign Out", style: TextStyle(color: Colors.red))
                ),
              ],
            ),
          ),
    );
  }
}
