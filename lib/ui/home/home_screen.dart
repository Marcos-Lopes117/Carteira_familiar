import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; 
import '../../data/repositories/profile_repository.dart';
import '../../providers/balance_provider.dart'; 
import '../../data/local/app_database.dart'; 
import '../../core/constants/categories.dart';
import '../onboarding/onboarding_screen.dart';
import 'widgets/add_transaction_modal.dart';
import 'widgets/category_chart.dart';
import 'widgets/goals_card.dart';

final chartTypeProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  // --- NOVO: MODAL PARA EDITAR PERFIL E META ---
  void _showEditProfileModal(BuildContext context, WidgetRef ref, Profile profile) {
    final nameController = TextEditingController(text: profile.name);
    final incomeController = TextEditingController(text: profile.monthlyIncome.toString());
    final goalController = TextEditingController(text: profile.savingsGoal.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ajustar Perfil e Metas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Sobrenome da Família', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: incomeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Renda Mensal Base', prefixText: 'R\$ ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: goalController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Meta de Economia', prefixText: 'R\$ ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text;
                final income = double.tryParse(incomeController.text.replaceAll(',', '.')) ?? 0.0;
                final goal = double.tryParse(goalController.text.replaceAll(',', '.')) ?? 0.0;

                await ref.read(profileRepositoryProvider).saveProfile(name, income, goal);
                
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Salvar Alterações'),
            ),
            TextButton(
              onPressed: () => {
                Navigator.pop(context),
                _confirmDelete(context, ref)
              },
              child: const Text('Resetar todos os dados', style: TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openAddTransaction(BuildContext context, {bool isIncome = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddTransactionModal(initialIsIncome: isIncome),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Dados?'),
        content: const Text('Isso apagará permanentemente seu perfil e todos os seus gastos registrados.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await ref.read(profileRepositoryProvider).deleteAllData();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Apagar Tudo', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(balanceStreamProvider);
    final transactionsAsync = ref.watch(recentTransactionsProvider); 
    final profileAsync = ref.watch(profileStreamProvider); 
    final isIncomeChart = ref.watch(chartTypeProvider);
    final summaryAsync = ref.watch(isIncomeChart ? incomeSummaryProvider : expenseSummaryProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: profileAsync.when(
          data: (p) => Text('Família ${p?.name ?? ""}'),
          loading: () => const Text('Carregando...'),
          error: (_, __) => const Text('Minha Carteira'),
        ),
        actions: [
          // Ícone de Configurações para editar o perfil/meta
          profileAsync.when(
            data: (profile) => profile != null 
              ? IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => _showEditProfileModal(context, ref, profile),
                )
              : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saudação reativa
            profileAsync.when(
              data: (profile) => Text(
                'Carteira ${profile?.name}!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              loading: () => const SizedBox(height: 24),
              error: (_, __) => const Text('Olá!'),
            ),
            const SizedBox(height: 20),
            
            // Card de Saldo
            balanceAsync.when(
              data: (balance) => _buildBalanceCard(context, balance),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Text('Erro ao calcular saldo'),
            ),
            
            const SizedBox(height: 16),

            // Seção de Metas Reativa
            profileAsync.when(
              data: (profile) {
                if (profile == null || profile.savingsGoal <= 0) return const SizedBox.shrink();
                return balanceAsync.when(
                  data: (balance) => GoalsCard(currentBalance: balance, goal: profile.savingsGoal),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),
            
            // Ações Rápidas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => _openAddTransaction(context, isIncome: true),
                  child: _buildQuickAction(context, Icons.add, 'Entrada', Colors.green),
                ),
                GestureDetector(
                  onTap: () => _openAddTransaction(context, isIncome: false),
                  child: _buildQuickAction(context, Icons.remove, 'Saída', Colors.red),
                ),
                _buildQuickAction(context, Icons.assessment, 'Relatório', Colors.blue),
              ],
            ),

            const SizedBox(height: 32),

            // Gráfico Dinâmico
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isIncomeChart ? 'Distribuição de Renda' : 'Distribuição de Gastos',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    Icon(Icons.trending_down, size: 16, color: !isIncomeChart ? Colors.red : Colors.grey),
                    Switch(
                      value: isIncomeChart,
                      onChanged: (val) => ref.read(chartTypeProvider.notifier).state = val,
                      activeColor: Colors.green,
                      inactiveTrackColor: Colors.red.withOpacity(0.2),
                    ),
                    Icon(Icons.trending_up, size: 16, color: isIncomeChart ? Colors.green : Colors.grey),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            summaryAsync.when(
              data: (data) => CategoryChart(data: data, isIncome: isIncomeChart),
              loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => const Text('Erro ao carregar gráfico'),
            ),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Atividades Recentes', 
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                ),
                TextButton(onPressed: () {}, child: const Text('Ver tudo')),
              ],
            ),

            transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text('Nenhuma transação registrada ainda.'),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final category = appCategories.firstWhere(
                      (c) => c.name == tx.category,
                      orElse: () => appCategories.last,
                    );

                    return Dismissible(
                      key: Key(tx.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        ref.read(profileRepositoryProvider).deleteTransaction(tx.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${tx.description} excluído')),
                        );
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: category.color.withOpacity(0.1),
                          child: Icon(category.icon, color: category.color, size: 20),
                        ),
                        title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${DateFormat('dd/MM/yyyy').format(tx.date)} • ${category.name}'),
                        trailing: Text(
                          (tx.isIncome ? '+ ' : '- ') + _formatCurrency(tx.amount),
                          style: TextStyle(
                            color: tx.isIncome ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Text('Erro ao carregar histórico'),
            ),
            const SizedBox(height: 80), 
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTransaction(context), 
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildBalanceCard(BuildContext context, double totalBalance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Saldo Atual', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(totalBalance),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIncomeExpenseInfo('Disponível', _formatCurrency(totalBalance), Icons.account_balance_wallet),
              const Icon(Icons.trending_up, color: Colors.white24),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}