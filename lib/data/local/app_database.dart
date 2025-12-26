import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

// Esse arquivo .g.dart será gerado automaticamente pelo Flutter no próximo passo
part 'app_database.g.dart';

// Tabela do Perfil do Usuário (Onboarding)
class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  RealColumn get monthlyIncome => real()(); // Renda mensal
  RealColumn get savingsGoal => real()();   // Meta de economia
}

// Tabela de Transações (Entradas e Saídas)
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get category => text()();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))(); // true = Entrada, false = Saída
}

@DriftDatabase(tables: [Profiles, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

// Função para definir onde o banco de dados será salvo no celular (Offline-first)
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}