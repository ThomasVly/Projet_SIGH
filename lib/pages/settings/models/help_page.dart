import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les notifications'),
        backgroundColor: const Color(0xFF264777),
      ),
      body: const Center(
        child: Text('Page de gestion des notifications'),
      ),
    );
  }
}
