import 'package:app_gore_callao/core/network/app_dio_provider.dart';
import 'package:app_gore_callao/features/tramites/domain/domain.dart';
import 'package:app_gore_callao/features/tramites/infrastructure/infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<TramitesRepository> tramitesRepositoryProvider =
    Provider<TramitesRepository>((ref) {
      return TramitesRepositoryImpl(
        dataSource: TramitesDataSourceImpl(
          dio: ref.watch(appDioProvider),
        ),
      );
    });

final FutureProvider<List<Tramite>> tramitesProvider =
    FutureProvider<List<Tramite>>((ref) async {
      final TramitesRepository repository = ref.watch(tramitesRepositoryProvider);
      return repository.getTramites();
    });
