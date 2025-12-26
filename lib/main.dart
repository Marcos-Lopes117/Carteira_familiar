import 'package:flutter/material.dart';

void main() {
  runApp(const CarteiraFamiliarApp());
}

class CarteiraFamiliarApp extends StatelessWidget {
  const CarteiraFamiliarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carteira Familiar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Bem-vindo à Carteira Familiar!')),
      ),
    );
  }
}