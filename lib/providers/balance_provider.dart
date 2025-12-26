import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/profile_repository.dart';

final balanceStreamProvider = StreamProvider<double>((ref) {
  return ref.watch(profileRepositoryProvider).watchCurrentBalance();
});