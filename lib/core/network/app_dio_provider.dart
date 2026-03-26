import 'package:app_not/config/config.dart';
import 'package:app_not/core/session/session_event_bus.dart';
import 'package:app_not/core/storage/session_storage_keys.dart';
import 'package:app_not/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:app_not/features/shared/infrastructure/services/key_value_storage_service_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<Dio> appDioProvider = Provider<Dio>((ref) {
  final KeyValueStorageService keyValueStorageService = ref.watch(
    keyValueStorageServiceProvider,
  );

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    _AuthTokenInterceptor(
      keyValueStorageService: keyValueStorageService,
      ref: ref,
    ),
  );

  return dio;
});

class _AuthTokenInterceptor extends Interceptor {
  final KeyValueStorageService keyValueStorageService;
  final Ref ref;
  static const Set<String> _publicPaths = <String>{
    '/app/login',
    '/app/entidades',
  };

  _AuthTokenInterceptor({
    required this.keyValueStorageService,
    required this.ref,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final bool skipAuth = _shouldSkipAuth(options);

    if (skipAuth) {
      options.headers.remove('Authorization');
      handler.next(options);
      return;
    }

    final String? token = await keyValueStorageService.getValue<String>(
      SessionStorageKeys.accessToken,
    );
    final String? tokenType = await keyValueStorageService.getValue<String>(
      SessionStorageKeys.tokenType,
    );

    if (token != null && token.isNotEmpty) {
      final String resolvedTokenType = tokenType?.isNotEmpty == true
          ? tokenType!
          : 'Bearer';
      options.headers['Authorization'] = '$resolvedTokenType $token';
    } else {
      options.headers.remove('Authorization');
    }

    final String? deviceId = await keyValueStorageService.getValue<String>(
      SessionStorageKeys.pushDeviceId,
    );
    if (deviceId != null && deviceId.trim().isNotEmpty) {
      options.headers['X-App-Device-Id'] = deviceId.trim();
    } else {
      options.headers.remove('X-App-Device-Id');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final bool isUnauthorized = err.response?.statusCode == 401;
    final bool skipAuth = _shouldSkipAuth(err.requestOptions);

    if (isUnauthorized && !skipAuth) {
      ref.read(sessionEventProvider.notifier).state =
          const SessionEvent.sessionExpired();
    }

    handler.next(err);
  }

  bool _shouldSkipAuth(RequestOptions options) {
    final bool isPublicPath = _publicPaths.contains(options.path);
    return options.extra['skipAuth'] == true || isPublicPath;
  }
}

