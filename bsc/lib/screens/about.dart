import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("O aplikacji")),
      body: const Center(
        child: Text("Informacje o aplikacji."),
      ),
    );
  }
}
