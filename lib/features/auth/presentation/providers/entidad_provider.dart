import 'package:app_gore_callao/features/auth/domain/domain.dart';
import 'package:app_gore_callao/features/auth/infrastructure/infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider del repositorio
final entidadRepositoryProvider = Provider<EntidadRepository>((ref) {
  return EntidadRepositoryImpl();
});

// Provider para cargar las entidades
final entidadesProvider = FutureProvider<List<Entidad>>((ref) async {
  final repository = ref.watch(entidadRepositoryProvider);
  return repository.getEntidades();
});
