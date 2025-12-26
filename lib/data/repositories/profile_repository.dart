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
  Future<int> saveProfile(String name, double income) async {
    return await _db
        .into(_db.profiles)
        .insert(
          ProfilesCompanion.insert(
            name: name,
            monthlyIncome: income,
            savingsGoal: 0.0,
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

  // STREAM: Essa é a "mágica". Ela observa a tabela de transações e perfil.
  // Sempre que algo mudar, ela emite o novo saldo calculado.
  Stream<double> watchCurrentBalance() {
    return _db.select(_db.profiles).watchSingle().asyncMap((profile) async {
      final baseIncome = profile?.monthlyIncome ?? 0.0;

      // Busca todas as transações
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
}
