import 'package:app_gore_callao/features/tramites/domain/domain.dart';
import 'package:app_gore_callao/features/tramites/infrastructure/mappers/tramite_mapper.dart';
import 'package:dio/dio.dart';

class TramitesDataSourceImpl extends TramitesDataSource {
  final Dio dio;

  TramitesDataSourceImpl({required this.dio});

  @override
  Future<List<Tramite>> getTramites() async {
    try {
      final Response<dynamic> response = await dio.get('/app/tramites');
      final List<dynamic> tramitesJson = _extractTramites(response.data);
      return TramiteMapper.tramiteListJsonToEntity(tramitesJson);
    } on DioException catch (e) {
      final int? statusCode = e.response?.statusCode;

      if (statusCode == 401) {
        throw Exception('Sesion expirada. Vuelve a iniciar sesion.');
      }

      throw Exception(
        e.response?.data?['mensaje'] ?? 'No se pudo cargar los tramites',
      );
    } catch (e) {
      throw Exception('Error al cargar tramites: $e');
    }
  }

  List<dynamic> _extractTramites(dynamic data) {
    if (data is List<dynamic>) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      final dynamic firstLevel =
          data['data'] ?? data['tramites'] ?? data['items'];

      if (firstLevel is List<dynamic>) {
        return firstLevel;
      }

      if (firstLevel is Map<String, dynamic>) {
        final dynamic secondLevel =
            firstLevel['tramites'] ?? firstLevel['items'];
        if (secondLevel is List<dynamic>) {
          return secondLevel;
        }
      }
    }

    return <dynamic>[];
  }
}
