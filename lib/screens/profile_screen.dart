import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/auth_service.dart';
import '../logic/database_service.dart';
import '../logic/theme_service.dart';
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

    messenger.showSnackBar(const SnackBar(content: Text("Profile Updated Successfully!")));
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Your Profile")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 25),
                _buildTextField(_nameController, "Full Name", Icons.person_outline),
                _buildTextField(_uniController, "University", Icons.school_outlined),
                _buildTextField(_deptController, "Department", Icons.business_outlined),
                _buildTextField(_semController, "Semester", Icons.calendar_today_outlined),
                const SizedBox(height: 20),
                ListTile(
                  title: const Text("Dark Mode"),
                  trailing: Switch(
                    value: themeService.isDarkMode, 
                    onChanged: (_) => themeService.toggleTheme(),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updateProfile, 
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Save Changes")
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () async {
                    final authService = Provider.of<AuthService>(context, listen: false);
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    try {
                      await authService.signOut();
                      // Pop back to the initial route (AuthWrapper)
                      navigator.popUntil((route) => route.isFirst);
                    } catch (e) {
                      messenger.showSnackBar(SnackBar(content: Text("Log out failed: $e")));
                    }
                  }, 
                  child: const Text("Log Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
