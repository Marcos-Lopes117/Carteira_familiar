import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'ui/onboarding/onboarding_screen.dart';
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
      // Usamos um FutureBuilder para decidir qual tela mostrar
      home: FutureBuilder(
        future: ref.read(profileRepositoryProvider).getProfile(),
        builder: (context, snapshot) {
          // Enquanto verifica o banco, mostra um carregamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          
          // Se o perfil existir (não for nulo), vai para a Home (vamos criar agora)
          if (snapshot.hasData && snapshot.data != null) {
            return const Scaffold(body: Center(child: Text("Bem-vindo de volta! (Home)")));
          }
          
          // Se não tiver dados, mostra o Onboarding
          return const OnboardingScreen();
        },
      ),
    );
  }
}