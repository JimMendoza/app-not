import 'package:app_gore_callao/features/notificaciones/domain/domain.dart';
import 'package:app_gore_callao/features/notificaciones/infrastructure/mappers/notificacion_mapper.dart';
import 'package:app_gore_callao/features/notificaciones/infrastructure/mappers/notificaciones_resumen_mapper.dart';
import 'package:dio/dio.dart';

class NotificacionesDataSourceImpl extends NotificacionesDataSource {
  final Dio dio;

  NotificacionesDataSourceImpl({required this.dio});

  @override
  Future<List<Notificacion>> getNotificaciones() async {
    try {
      final Response<dynamic> response = await dio.get('/app/notificaciones');
      final List<dynamic> notificacionesJson = _extractList(response.data);
      return NotificacionMapper.notificacionListJsonToEntity(notificacionesJson);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['mensaje'] ?? 'No se pudo cargar notificaciones',
      );
    } catch (e) {
      throw Exception('Error al cargar notificaciones: $e');
    }
  }

  @override
  Future<NotificacionesResumen> getResumenNotificaciones() async {
    try {
      final Response<dynamic> response = await dio.get('/app/notificaciones/resumen');
      final Map<String, dynamic> resumenJson = _extractResumen(response.data);
      return NotificacionesResumenMapper.resumenJsonToEntity(resumenJson);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['mensaje'] ??
            'No se pudo cargar resumen de notificaciones',
      );
    } catch (e) {
      throw Exception('Error al cargar resumen de notificaciones: $e');
    }
  }

  @override
  Future<void> marcarComoLeida(int notificacionId) async {
    try {
      await dio.patch('/app/notificaciones/$notificacionId/leida');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['mensaje'] ?? 'No se pudo marcar como leida',
      );
    }
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List<dynamic>) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      final dynamic firstLevel =
          data['data'] ?? data['notificaciones'] ?? data['items'];
      if (firstLevel is List<dynamic>) {
        return firstLevel;
      }

      if (firstLevel is Map<String, dynamic>) {
        final dynamic secondLevel =
            firstLevel['notificaciones'] ?? firstLevel['items'];
        if (secondLevel is List<dynamic>) {
          return secondLevel;
        }
      }
    }

    return <dynamic>[];
  }

  Map<String, dynamic> _extractResumen(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) {
        return data['data'] as Map<String, dynamic>;
      }

      if (data['resumen'] is Map<String, dynamic>) {
        return data['resumen'] as Map<String, dynamic>;
      }

      return data;
    }

    return <String, dynamic>{'noLeidas': 0};
  }
}
