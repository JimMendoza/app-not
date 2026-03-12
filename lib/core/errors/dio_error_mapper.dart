import 'package:dio/dio.dart';

import 'app_failure.dart';

class DioErrorMapper {
  static AppFailure map(
    DioException error, {
    String fallbackMessage = 'No se pudo completar la solicitud.',
    bool treatUnauthorizedAsInvalidCredentials = false,
    String? invalidCredentialsMessage,
  }) {
    final int? statusCode = error.response?.statusCode;
    final String responseMessage = _extractResponseMessage(error.response?.data);

    if (treatUnauthorizedAsInvalidCredentials &&
        (statusCode == 400 || statusCode == 401)) {
      return AppFailure(
        type: AppFailureType.invalidCredentials,
        message:
            responseMessage.isNotEmpty
                ? responseMessage
                : (invalidCredentialsMessage ?? 'Credenciales invalidas.'),
        statusCode: statusCode,
        cause: error,
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppFailure(
          type: AppFailureType.timeout,
          message: 'La solicitud tardo demasiado. Intenta nuevamente.',
          statusCode: statusCode,
          cause: error,
        );
      case DioExceptionType.connectionError:
        return AppFailure(
          type: AppFailureType.noConnection,
          message: 'No se pudo conectar a internet. Verifica tu conexion.',
          statusCode: statusCode,
          cause: error,
        );
      case DioExceptionType.badResponse:
        if (statusCode == 401) {
          return AppFailure(
            type: AppFailureType.sessionExpired,
            message: 'Tu sesion expiro. Inicia sesion nuevamente.',
            statusCode: statusCode,
            cause: error,
          );
        }

        if (statusCode != null && statusCode >= 500) {
          return AppFailure(
            type: AppFailureType.serverError,
            message:
                responseMessage.isNotEmpty
                    ? responseMessage
                    : 'El servidor no pudo procesar la solicitud.',
            statusCode: statusCode,
            cause: error,
          );
        }

        return AppFailure(
          type: AppFailureType.serverError,
          message: responseMessage.isNotEmpty ? responseMessage : fallbackMessage,
          statusCode: statusCode,
          cause: error,
        );
      case DioExceptionType.cancel:
        return AppFailure(
          type: AppFailureType.unknown,
          message: fallbackMessage,
          statusCode: statusCode,
          cause: error,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return AppFailure(
          type: AppFailureType.unknown,
          message: responseMessage.isNotEmpty ? responseMessage : fallbackMessage,
          statusCode: statusCode,
          cause: error,
        );
    }
  }

  static AppFailure unknown(
    Object error, {
    String message = 'Ocurrio un error inesperado.',
  }) {
    return AppFailure(
      type: AppFailureType.unknown,
      message: message,
      cause: error,
    );
  }

  static String _extractResponseMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      const List<String> messageKeys = <String>[
        'mensaje',
        'message',
        'error',
        'detail',
      ];

      for (final String key in messageKeys) {
        final dynamic value = data[key];
        if (value != null) {
          final String parsed = value.toString().trim();
          if (parsed.isNotEmpty) {
            return parsed;
          }
        }
      }
    }

    return '';
  }
}
