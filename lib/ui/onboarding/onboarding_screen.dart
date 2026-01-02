import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/profile_repository.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _incomeController = TextEditingController();
  final _goalController = TextEditingController(); // 1. Novo controlador para a meta

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: screenHeight * 0.05),
                
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: screenHeight * 0.20, // Reduzi um pouco para caber o novo campo
                    ),
                    child: Image.asset(
                      'assets/carteira.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                Text(
                  'Bem-vindo à Carteira \nda sua Família',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 40),
                
                // Campo Nome
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Qual o nome da carteira?',
                    hintText: 'Ex: Lopes, Vangeloti...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                
                // Campo Renda
                TextFormField(
                  controller: _incomeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Qual o montante disponível?',
                    prefixText: 'R\$ ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance_wallet),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),

                // 2. NOVO CAMPO: Meta de Economia
                TextFormField(
                  controller: _goalController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Qual sua meta de economia?',
                    hintText: 'quanto você quer economizar?',
                    prefixText: 'R\$ ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag),
                    helperText: 'Você poderá alterar isso depois nas configurações.',
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo obrigatório' : null,
                ),

                const SizedBox(height: 40),
                
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final name = _nameController.text;
                      
                      final income = double.tryParse(_incomeController.text.replaceAll(',', '.')) ?? 0.0;
                      final goal = double.tryParse(_goalController.text.replaceAll(',', '.')) ?? 0.0;

                       await ref
                          .read(profileRepositoryProvider)
                          .saveProfile(name, income, goal);

                      if (mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Começar minha jornada',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _incomeController.dispose();
    _goalController.dispose();
    super.dispose();
  }
}