import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/app_database.dart';
import '../../providers/database_provider.dart';

final profileRepositoryProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return ProfileRepository(db);
});

class ProfileRepository {
  final AppDatabase _db;
  ProfileRepository(this._db);

  // --- PERFIL ---
  Future<int> saveProfile(String name, double income, double goal) async {
    return await _db
        .into(_db.profiles)
        .insert(
          ProfilesCompanion.insert(
            name: name,
            monthlyIncome: income,
            savingsGoal: goal,
          ),
        );
  }

  Future<Profile?> getProfile() async =>
      await _db.select(_db.profiles).getSingleOrNull();

  Future<void> deleteAllData() async {
    await _db.delete(_db.profiles).go();
    await _db.delete(_db.transactions).go();
  }

  // --- TRANSAÇÕES ---
  Future<int> addTransaction(
    String desc,
    double val,
    bool isIncome,
    String cat,
  ) async {
    return await _db
        .into(_db.transactions)
        .insert(
          TransactionsCompanion.insert(
            description: desc,
            amount: val,
            date: DateTime.now(),
            isIncome: Value(isIncome),
            category: cat,
          ),
        );
  }

  Stream<Map<String, double>> watchCategoryTotals({required bool isIncome}) {
    return _db.select(_db.transactions).watch().map((transactions) {
      final Map<String, double> totals = {};

      // Filtra apenas pelo tipo (Entrada ou Saída)
      final filtered = transactions.where((t) => t.isIncome == isIncome);

      for (var tx in filtered) {
        totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
      }

      // O Map resultante conterá apenas categorias com valores > 0
      return totals;
    });
  }

  // CORREÇÃO DA MÁGICA: Agora observamos a tabela de transações para o saldo atualizar sempre!
  Stream<double> watchCurrentBalance() {
    // Escutamos qualquer mudança na tabela de transações
    return _db.select(_db.transactions).watch().asyncMap((_) async {
      final profile = await getProfile();
      final baseIncome = profile?.monthlyIncome ?? 0.0;

      final allTransactions = await _db.select(_db.transactions).get();

      double totalItems = 0;
      for (var t in allTransactions) {
        if (t.isIncome) {
          totalItems += t.amount;
        } else {
          totalItems -= t.amount;
        }
      }

      return baseIncome + totalItems;
    });
  }

  Stream<List<Transaction>> watchRecentTransactions() {
    return (_db.select(_db.transactions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ])
          ..limit(10))
        .watch();
  }

  Stream<Profile?> watchProfile() {
    return _db.select(_db.profiles).watchSingleOrNull();
  }

  // CORRIGIDO: de 'database' para '_db'
  Future<void> deleteTransaction(int id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }
}
