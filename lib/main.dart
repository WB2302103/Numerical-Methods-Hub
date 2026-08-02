import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/solver_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/history_screen.dart';
import 'screens/support_screen.dart';
import 'logic/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kIsWeb
        ? const FirebaseOptions(
            apiKey: "AIzaSyAZSPLudRoGjda3W8IVU3SGvUT8_kpaUEM",
            authDomain: "numerical-methods-hub.firebaseapp.com",
            projectId: "numerical-methods-hub",
            storageBucket: "numerical-methods-hub.firebasestorage.app",
            messagingSenderId: "515828528680",
            appId: "1:515828528680:web:e56b5c1c838904e54ca71d",
            measurementId: "G-JPCPRH0DC0",
          )
        : null,
  );
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linear System Solver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder(
      stream: authService.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          }
          return const HomeScreen();
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isExpanded = false; // Start false to allow auto-animation
  late AnimationController _controller;
  late Animation<double> _listOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _listOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );

    // Automatically trigger the reveal animation after a small delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isExpanded = true);
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Modern Gradient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF0F2F5),
                    Colors.white,
                    Color(0xFFE8EAF6),
                  ],
                ),
              ),
            ),
          ),

          // Decorative Blurry Blobs
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigo.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Background content (the list) - MUST BE FIRST to not block hit testing for fixed buttons
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    // Spacing to keep list below the button's top position
                    const SizedBox(height: 120),
                    FadeTransition(
                      opacity: _listOpacity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            const Text(
                              'Select a solution method:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                            ),
                            const SizedBox(height: 20),
                            _buildAnimatedCard(0, 'Gaussian Elimination', 'Standard row reduction method', Icons.grid_on, SolverMethod.gaussian),
                            _buildAnimatedCard(1, 'LU Decomposition', 'Factorization into L and U matrices', Icons.functions, SolverMethod.lu),
                            _buildAnimatedCard(2, 'Matrix Inversion', 'Solve using A^-1 * b', Icons.import_export, SolverMethod.inversion),
                            _buildAnimatedCard(3, 'Jacobi Iterative Method', 'Iterative approach for large systems', Icons.loop, SolverMethod.jacobi),
                            _buildAnimatedCard(4, 'Gauss-Seidel Method', 'Faster convergence iterative method', Icons.trending_down, SolverMethod.gaussSeidel),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Profile & History Buttons - Moved below list to be on top
          Positioned(
            left: 20,
            top: 20,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.indigo, size: 30),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => const ProfileScreen()),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.indigo, size: 30),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => const HistoryScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Support Button - Moved below list to be on top
          Positioned(
            right: 20,
            top: 20,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.support_agent, color: Colors.indigo, size: 30),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const SupportScreen()),
                ),
              ),
            ),
          ),
          
          // The Centered Animated Rounded Button - Stays at top of Stack
          AnimatedAlign(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutExpo,
            alignment: _isExpanded ? Alignment.topCenter : Alignment.center,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: _toggleExpand,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: EdgeInsets.symmetric(
                          horizontal: _isExpanded ? 30 : 50,
                          vertical: _isExpanded ? 15 : 40,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.indigo,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 500),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _isExpanded ? 20 : 26,
                            fontWeight: FontWeight.bold,
                          ),
                          child: const Text('Linear System Solver'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard(int index, String title, String desc, IconData icon, SolverMethod method) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double slideProgress = CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.6 + (index * 0.08),
            0.8 + (index * 0.08),
            curve: Curves.easeOutQuart,
          ),
        ).value;

        return Opacity(
          opacity: slideProgress,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - slideProgress)),
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.indigo, size: 28),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A237E)),
                    ),
                    subtitle: Text(
                      desc,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.indigo.withValues(alpha: 0.5)),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => SolverScreen(method: method))),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
