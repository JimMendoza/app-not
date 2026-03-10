import 'package:app_gore_callao/core/network/app_dio_provider.dart';
import 'package:app_gore_callao/features/home/domain/domain.dart';
import 'package:app_gore_callao/features/home/infrastructure/infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<ModuleRepository> moduleRepositoryProvider =
    Provider<ModuleRepository>((ref) {
      return ModuleRepositoryImpl(
        dataSource: ModuleDataSourceImpl(
          dio: ref.watch(appDioProvider),
        ),
      );
    });

final FutureProvider<List<Module>> modulesProvider = FutureProvider<List<Module>>(
  (ref) async {
    final ModuleRepository repository = ref.watch(moduleRepositoryProvider);
    return repository.getModules();
  },
);
