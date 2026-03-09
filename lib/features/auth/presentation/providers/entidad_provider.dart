import 'package:app_gore_callao/core/network/app_dio_provider.dart';
import 'package:app_gore_callao/features/auth/domain/domain.dart';
import 'package:app_gore_callao/features/auth/infrastructure/infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final entidadRepositoryProvider = Provider<EntidadRepository>((ref) {
  return EntidadRepositoryImpl(
    dataSource: EntidadDatasourceImpl(dio: ref.watch(appDioProvider)),
  );
});

final entidadesProvider = FutureProvider<List<Entidad>>((ref) async {
  final repository = ref.watch(entidadRepositoryProvider);
  return repository.getEntidades();
});
