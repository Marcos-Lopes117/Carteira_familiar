import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'ui/home/home_screen.dart'; 
import 'data/repositories/profile_repository.dart';

void main() {
  runApp(const ProviderScope(child: CarteiraFamiliarApp()));
}

class CarteiraFamiliarApp extends ConsumerWidget {
  const CarteiraFamiliarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Carteira Familiar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FutureBuilder(
        future: ref.read(profileRepositoryProvider).getProfile(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          
          
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen(); 
          }
          
          
          return const OnboardingScreen();
        },
      ),
    );
  }
}