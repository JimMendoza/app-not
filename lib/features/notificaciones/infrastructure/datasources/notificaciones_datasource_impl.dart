import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/features/notificaciones/domain/domain.dart';
import 'package:app_gore_callao/features/notificaciones/infrastructure/mappers/notificacion_mapper.dart';
import 'package:app_gore_callao/features/notificaciones/infrastructure/mappers/notificacion_configuracion_mapper.dart';
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
      return NotificacionMapper.notificacionListJsonToEntity(
        notificacionesJson,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(
        e,
        fallbackMessage: 'No se pudo cargar notificaciones.',
      );
    } catch (e) {
      if (e is AppFailure) {
        rethrow;
      }

      throw DioErrorMapper.unknown(
        e,
        message: 'No se pudo cargar notificaciones.',
      );
    }
  }

  @override
  Future<NotificacionesResumen> getResumenNotificaciones() async {
    try {
      final Response<dynamic> response = await dio.get(
        '/app/notificaciones/resumen',
      );
      final Map<String, dynamic> resumenJson = _extractResumen(response.data);
      return NotificacionesResumenMapper.resumenJsonToEntity(resumenJson);
    } on DioException catch (e) {
      throw DioErrorMapper.map(
        e,
        fallbackMessage: 'No se pudo cargar resumen de notificaciones.',
      );
    } catch (e) {
      if (e is AppFailure) {
        rethrow;
      }

      throw DioErrorMapper.unknown(
        e,
        message: 'No se pudo cargar resumen de notificaciones.',
      );
    }
  }

  @override
  Future<NotificacionConfiguracion> getConfiguracionNotificaciones() async {
    try {
      final Response<dynamic> response = await dio.get(
        '/app/notificaciones/configuracion',
      );
      final Map<String, dynamic> configuracionJson = _extractConfiguracion(
        response.data,
      );
      return NotificacionConfiguracionMapper.jsonToEntity(configuracionJson);
    } on DioException catch (e) {
      throw DioErrorMapper.map(
        e,
        fallbackMessage:
            'No se pudo cargar la configuracion de notificaciones.',
      );
    } catch (e) {
      if (e is AppFailure) {
        rethrow;
      }

      throw DioErrorMapper.unknown(
        e,
        message: 'No se pudo cargar la configuracion de notificaciones.',
      );
    }
  }

  @override
  Future<void> guardarConfiguracionNotificaciones(
    NotificacionConfiguracion configuracion,
  ) async {
    try {
      final Map<String, dynamic> payload =
          NotificacionConfiguracionMapper.entityToJson(configuracion);
      await dio.put('/app/notificaciones/configuracion', data: payload);
    } on DioException catch (e) {
      throw DioErrorMapper.map(
        e,
        fallbackMessage:
            'No se pudo guardar la configuracion de notificaciones.',
      );
    } catch (e) {
      if (e is AppFailure) {
        rethrow;
      }

      throw DioErrorMapper.unknown(
        e,
        message: 'No se pudo guardar la configuracion de notificaciones.',
      );
    }
  }

  @override
  Future<void> marcarComoLeida(int notificacionId) async {
    try {
      await dio.patch('/app/notificaciones/$notificacionId/leida');
    } on DioException catch (e) {
      throw DioErrorMapper.map(
        e,
        fallbackMessage: 'No se pudo marcar como leida.',
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

  Map<String, dynamic> _extractConfiguracion(dynamic data) {
    if (data is Map<String, dynamic>) {
      final dynamic firstLevel = data['data'];
      if (firstLevel is Map<String, dynamic>) {
        return firstLevel;
      }

      if (firstLevel is Map) {
        return Map<String, dynamic>.from(firstLevel);
      }

      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return <String, dynamic>{};
  }
}
