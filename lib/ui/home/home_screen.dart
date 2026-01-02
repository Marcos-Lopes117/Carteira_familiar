import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; 
import '../../data/repositories/profile_repository.dart';
import '../../providers/balance_provider.dart'; 
import '../../data/local/app_database.dart'; 
import '../onboarding/onboarding_screen.dart';
import 'widgets/add_transaction_modal.dart'; 

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
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
    final profileRepo = ref.watch(profileRepositoryProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Minha Carteira'),
        actions: [
          IconButton(
            onPressed: () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: profileRepo.getProfile(),
              builder: (context, snapshot) {
                final name = snapshot.data?.name ?? 'Família';
                return Text(
                  'Olá, Família $name!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                );
              },
            ),
            const SizedBox(height: 20),
            
            balanceAsync.when(
              data: (balance) => _buildBalanceCard(context, balance),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Text('Erro ao calcular saldo'),
            ),
            
            const SizedBox(height: 24),
            
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
                    
                    // --- IMPLEMENTAÇÃO DO DISMISSIBLE (DESLIZAR PARA EXCLUIR) ---
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
                      confirmDismiss: (direction) async {
                        // Opcional: Adicionar uma confirmação antes de excluir
                        return true;
                      },
                      onDismissed: (direction) {
                        // Chama o repositório para deletar do banco
                        ref.read(profileRepositoryProvider).deleteTransaction(tx.id);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${tx.description} excluído'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: tx.isIncome 
                              ? Colors.green.withOpacity(0.1) 
                              : Colors.red.withOpacity(0.1),
                          child: Icon(
                            tx.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                            color: tx.isIncome ? Colors.green : Colors.red,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          tx.description, 
                          style: const TextStyle(fontWeight: FontWeight.w600)
                        ),
                        subtitle: Text(DateFormat('dd/MM/yyyy').format(tx.date)),
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