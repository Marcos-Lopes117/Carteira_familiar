import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/profile_repository.dart';
import '../data/local/app_database.dart';

final balanceStreamProvider = StreamProvider<double>((ref) {
  return ref.watch(profileRepositoryProvider).watchCurrentBalance();
});
final recentTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(profileRepositoryProvider).watchRecentTransactions();
});
final expenseSummaryProvider = StreamProvider<Map<String, double>>((ref) {
  return ref.watch(profileRepositoryProvider).watchCategoryTotals(isIncome: false);
});

final incomeSummaryProvider = StreamProvider<Map<String, double>>((ref) {
  return ref.watch(profileRepositoryProvider).watchCategoryTotals(isIncome: true);
});