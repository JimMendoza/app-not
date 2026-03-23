import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/core/network/app_dio_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<PushTokenBackendClient> pushTokenBackendClientProvider =
    Provider<PushTokenBackendClient>((Ref ref) {
      return PushTokenBackendClient(dio: ref.watch(appDioProvider));
    });

class PushTokenBackendClient {
  final Dio dio;

  PushTokenBackendClient({required this.dio});

  Future<void> upsertPushToken({
    required String deviceId,
    required String pushToken,
    required String platform,
    required String deviceName,
    required String appVersion,
  }) async {
    try {
      await dio.put(
        '/app/dispositivos/push-token',
        data: <String, dynamic>{
          'deviceId': deviceId,
          'pushToken': pushToken,
          'platform': platform,
          'deviceName': deviceName,
          'appVersion': appVersion,
        },
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(
        e,
        fallbackMessage: 'No se pudo registrar el token push del dispositivo.',
      );
    } catch (e) {
      if (e is AppFailure) {
        rethrow;
      }

      throw DioErrorMapper.unknown(
        e,
        message: 'No se pudo registrar el token push del dispositivo.',
      );
    }
  }

  Future<void> invalidatePushToken({required String deviceId}) async {
    try {
      await dio.delete(
        '/app/dispositivos/push-token',
        data: <String, String>{'deviceId': deviceId},
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(
        e,
        fallbackMessage: 'No se pudo invalidar el token push del dispositivo.',
      );
    } catch (e) {
      if (e is AppFailure) {
        rethrow;
      }

      throw DioErrorMapper.unknown(
        e,
        message: 'No se pudo invalidar el token push del dispositivo.',
      );
    }
  }
}
