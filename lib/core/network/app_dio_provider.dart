import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/core/storage/session_storage_keys.dart';
import 'package:app_gore_callao/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:app_gore_callao/features/shared/infrastructure/services/key_value_storage_service_provider.dart';
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
    _AuthTokenInterceptor(keyValueStorageService: keyValueStorageService),
  );

  return dio;
});

class _AuthTokenInterceptor extends Interceptor {
  final KeyValueStorageService keyValueStorageService;
  static const Set<String> _publicPaths = <String>{
    '/app/login',
    '/app/entidades',
  };

  _AuthTokenInterceptor({required this.keyValueStorageService});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final bool isPublicPath = _publicPaths.contains(options.path);
    final bool skipAuth = options.extra['skipAuth'] == true || isPublicPath;

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

    handler.next(options);
  }
}
