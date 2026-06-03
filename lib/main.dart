import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFFDF5F7),
        body: const Center(
          child: WidgetExamplePage(),
        ),
      ),
    );
  }
}

class WidgetExamplePage extends StatefulWidget {
  const WidgetExamplePage({super.key});

  @override
  State<WidgetExamplePage> createState() => _WidgetExamplePageState();
}

class _WidgetExamplePageState extends State<WidgetExamplePage> {
  bool _isCircle = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Below is an example of widgets:',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildColorBox(Colors.red),
            const SizedBox(width: 10),
            _buildColorBox(Colors.green),
            const SizedBox(width: 10),
            _buildColorBox(Colors.blue),
          ],
        ),
        const SizedBox(height: 50),


        GestureDetector(
          onTap: () {
            setState(() {
              _isCircle = !_isCircle;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_isCircle ? 125 : 40),
              color: Colors.black,
            ),

            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_isCircle ? 100 : 35),
                  color: Colors.grey[700],
                ),
                child: Center(
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_isCircle ? 75 : 30),
                        color: Colors.grey[400],
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(_isCircle ? 50 : 25),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorBox(Color color) {
    return Container(
      width: 80,
      height: 60,
      color: color,
    );
  }
}