import 'package:flutter/material.dart';

class UnauthorizedPage extends StatefulWidget {
  const UnauthorizedPage({super.key});
  @override
  _UnauthorizedPageState createState() => _UnauthorizedPageState();
}

class _UnauthorizedPageState extends State<UnauthorizedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 157, 234, 159), // Set the background color here
      body: Center(
        child: Text(
          'Unauthorized',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 0, 0, 0), // Optional: Set text color for better contrast
          ),
        ),
      ),
    );
  }
}
