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

  // Salva o perfil
  Future<int> saveProfile(String name, double income) async {
    return await _db.into(_db.profiles).insert(
      ProfilesCompanion.insert(
        name: name,
        monthlyIncome: income,
        savingsGoal: 0.0,
      ),
    );
  }

  // Busca o perfil (O nome gerado pelo Drift para a classe de dados é Profile)
  Future<Profile?> getProfile() async {
    return await _db.select(_db.profiles).getSingleOrNull();
  }

  Future<void> deleteAllData() async {
  await _db.delete(_db.profiles).go();
  await _db.delete(_db.transactions).go();
}
}

