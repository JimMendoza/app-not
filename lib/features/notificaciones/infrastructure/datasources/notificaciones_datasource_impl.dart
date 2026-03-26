import 'package:app_not/core/errors/errors.dart';
import 'package:app_not/features/notificaciones/domain/domain.dart';
import 'package:app_not/features/notificaciones/infrastructure/mappers/notificacion_mapper.dart';
import 'package:app_not/features/notificaciones/infrastructure/mappers/notificacion_configuracion_mapper.dart';
import 'package:app_not/features/notificaciones/infrastructure/mappers/notificaciones_resumen_mapper.dart';
import 'package:dio/dio.dart';

class NotificacionesDataSourceImpl extends NotificacionesDataSource {
  final Dio dio;

  NotificacionesDataSourceImpl({required this.dio});

  @override
  Future<List<Notificacion>> getNotificaciones() async {
    try {
      final Response<dynamic> response = await dio.get('/app/notificaciones');
      final List<dynamic>
      notificacionesJson = ResponseContractValidator.expectList(
        response.data,
        message:
            'Respuesta invalida del servidor al cargar /app/notificaciones.',
      );
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
      final Map<String, dynamic>
      resumenJson = ResponseContractValidator.expectMap(
        response.data,
        message:
            'Respuesta invalida del servidor al cargar /app/notificaciones/resumen.',
      );
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
      final Map<String, dynamic>
      configuracionJson = ResponseContractValidator.expectMap(
        response.data,
        message:
            'Respuesta invalida del servidor al cargar /app/notificaciones/configuracion.',
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
}

