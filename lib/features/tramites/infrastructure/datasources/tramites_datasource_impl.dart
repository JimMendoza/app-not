import 'package:app_gore_callao/features/tramites/domain/domain.dart';
import 'package:app_gore_callao/features/tramites/infrastructure/mappers/tramite_mapper.dart';
import 'package:app_gore_callao/features/tramites/infrastructure/mappers/tramite_movimiento_mapper.dart';
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

  @override
  Future<void> seguirTramite(int tramiteId) async {
    try {
      await dio.post('/app/tramites/$tramiteId/seguir');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['mensaje'] ?? 'No se pudo seguir el tramite',
      );
    }
  }

  @override
  Future<void> dejarDeSeguirTramite(int tramiteId) async {
    try {
      await dio.delete('/app/tramites/$tramiteId/seguir');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['mensaje'] ??
            'No se pudo dejar de seguir el tramite',
      );
    }
  }

  @override
  Future<List<TramiteMovimiento>> getHojaRuta(int tramiteId) async {
    try {
      final Response<dynamic> response = await dio.get(
        '/app/tramites/$tramiteId/hoja-ruta',
      );
      final List<dynamic> hojaRutaJson = _extractHojaRuta(response.data);
      return TramiteMovimientoMapper.tramiteMovimientoListJsonToEntity(
        hojaRutaJson,
      );
    } on DioException catch (e) {
      final int? statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        throw Exception('Sesion expirada. Vuelve a iniciar sesion.');
      }

      throw Exception(
        e.response?.data?['mensaje'] ?? 'No se pudo cargar la hoja de ruta',
      );
    } catch (e) {
      throw Exception('Error al cargar hoja de ruta: $e');
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

  List<dynamic> _extractHojaRuta(dynamic data) {
    if (data is List<dynamic>) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      final dynamic firstLevel =
          data['data'] ?? data['hojaRuta'] ?? data['movimientos'];

      if (firstLevel is List<dynamic>) {
        return firstLevel;
      }

      if (firstLevel is Map<String, dynamic>) {
        final dynamic secondLevel =
            firstLevel['hojaRuta'] ?? firstLevel['movimientos'];

        if (secondLevel is List<dynamic>) {
          return secondLevel;
        }
      }
    }

    return <dynamic>[];
  }
}
