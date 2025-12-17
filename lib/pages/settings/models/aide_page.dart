import 'package:flutter/material.dart';

class AidePage extends StatelessWidget {
  const AidePage({Key? key}) : super(key: key);

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
