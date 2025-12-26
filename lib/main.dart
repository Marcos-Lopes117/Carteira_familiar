import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'ui/onboarding/onboarding_screen.dart';

void main() {
  runApp(
    // O ProviderScope é obrigatório para o Riverpod funcionar
    const ProviderScope(child: CarteiraFamiliarApp()),
  );
}

class CarteiraFamiliarApp extends StatelessWidget {
  const CarteiraFamiliarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carteira Familiar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const OnboardingScreen(),
    );
  }
}