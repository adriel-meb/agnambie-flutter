import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/download.dart';
import '../../data/repositories/providers.dart';

final offlineDownloadsProvider = FutureProvider<List<Download>>((ref) async {
  final repo = ref.watch(downloadRepositoryProvider);
  return await repo.getAllDownloads();
});

final totalStorageUsedProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(downloadRepositoryProvider);
  return await repo.getTotalStorageUsed();
});
