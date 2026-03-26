import 'package:app_not/core/errors/errors.dart';
import 'package:app_not/features/tramites/domain/domain.dart';
import 'package:app_not/features/tramites/infrastructure/mappers/tramite_mapper.dart';
import 'package:app_not/features/tramites/infrastructure/mappers/tramite_movimiento_mapper.dart';
import 'package:dio/dio.dart';

class TramitesDataSourceImpl extends TramitesDataSource {
  final Dio dio;

  TramitesDataSourceImpl({required this.dio});

  @override
  Future<List<Tramite>> getTramites() async {
    try {
      final Response<dynamic> response = await dio.get('/app/tramites');
      final List<dynamic> tramitesJson = ResponseContractValidator.expectList(
        response.data,
        message: 'Respuesta invalida del servidor al cargar /app/tramites.',
      );
      return TramiteMapper.tramiteListJsonToEntity(tramitesJson);
    } on DioException catch (e) {
      throw DioErrorMapper.map(
        e,
        fallbackMessage: 'No se pudo cargar los tramites.',
      );
    } catch (e) {
      if (e is AppFailure) {
        rethrow;
      }

      throw DioErrorMapper.unknown(
        e,
        message: 'No se pudo cargar los tramites.',
      );
    }
  }

  @override
  Future<void> seguirTramite(int tramiteId) async {
    try {
      await dio.post('/app/tramites/$tramiteId/seguir');
    } on DioException catch (e) {
      throw DioErrorMapper.map(
        e,
        fallbackMessage: 'No se pudo seguir el tramite.',
      );
    }
  }

  @override
  Future<void> dejarDeSeguirTramite(int tramiteId) async {
    try {
      await dio.delete('/app/tramites/$tramiteId/seguir');
    } on DioException catch (e) {
      throw DioErrorMapper.map(
        e,
        fallbackMessage: 'No se pudo dejar de seguir el tramite.',
      );
    }
  }

  @override
  Future<List<TramiteMovimiento>> getHojaRuta(int tramiteId) async {
    try {
      final Response<dynamic> response = await dio.get(
        '/app/tramites/$tramiteId/hoja-ruta',
      );
      final List<dynamic> hojaRutaJson = ResponseContractValidator.expectList(
        response.data,
        message:
            'Respuesta invalida del servidor al cargar /app/tramites/$tramiteId/hoja-ruta.',
      );
      return TramiteMovimientoMapper.tramiteMovimientoListJsonToEntity(
        hojaRutaJson,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 501) {
        throw const AppFailure(
          type: AppFailureType.serverError,
          message: 'La hoja de ruta aun no esta disponible.',
          statusCode: 501,
        );
      }

      throw DioErrorMapper.map(
        e,
        fallbackMessage: 'No se pudo cargar la hoja de ruta.',
      );
    } catch (e) {
      if (e is AppFailure) {
        rethrow;
      }

      throw DioErrorMapper.unknown(
        e,
        message: 'No se pudo cargar la hoja de ruta.',
      );
    }
  }
}

