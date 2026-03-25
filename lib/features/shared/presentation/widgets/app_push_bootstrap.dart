import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/core/push/push_token_backend_client.dart';
import 'package:app_gore_callao/core/storage/session_storage_keys.dart';
import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/notificaciones/presentation/providers/notificaciones_provider.dart';
import 'package:app_gore_callao/features/shared/infrastructure/services/app_icon_badge_service.dart';
import 'package:app_gore_callao/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:app_gore_callao/features/shared/infrastructure/services/key_value_storage_service_provider.dart';
import 'package:app_gore_callao/features/tramites/presentation/providers/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String _generalChannelId = 'notificaciones_generales';
const String _generalChannelName = 'Notificaciones generales';
const String _generalChannelDescription =
    'Canal principal de notificaciones del aplicativo.';

const AndroidNotificationChannel _generalAndroidChannel =
    AndroidNotificationChannel(
      _generalChannelId,
      _generalChannelName,
      description: _generalChannelDescription,
      importance: Importance.high,
    );

@pragma('vm:entry-point')
Future<void> appFirebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  try {
    await Firebase.initializeApp();

    final int? noLeidas = _extractNoLeidasFromPayload(message.data);
    if (noLeidas != null) {
      await const AppIconBadgeService().syncUnreadCountRespectingPreference(
        noLeidas,
      );
    }
  } catch (_) {
    // Keep background isolate resilient even if Firebase is not configured yet.
  }
}

int? _extractNoLeidasFromPayload(Map<String, dynamic> payload) {
  final dynamic rawNoLeidas = payload['noLeidas'];
  if (rawNoLeidas == null) {
    return null;
  }

  final int? parsed = rawNoLeidas is int
      ? rawNoLeidas
      : int.tryParse(rawNoLeidas.toString().trim());

  if (parsed == null || parsed < 0) {
    return null;
  }

  return parsed;
}

int? _extractNotificationIdFromPayload(Map<String, dynamic> payload) {
  final dynamic rawNotificationId = payload['notificationId'];
  if (rawNotificationId == null) {
    return null;
  }

  final int? parsed = rawNotificationId is int
      ? rawNotificationId
      : int.tryParse(rawNotificationId.toString().trim());

  if (parsed == null || parsed <= 0) {
    return null;
  }

  return parsed;
}

int? _extractNotificationIdFromRoutePayload(String? payload) {
  if (payload == null || payload.trim().isEmpty) {
    return null;
  }

  final Uri? payloadUri = Uri.tryParse(payload.trim());
  if (payloadUri == null) {
    return null;
  }

  final String? rawNotificationId =
      payloadUri.queryParameters['notificationId'];
  if (rawNotificationId == null || rawNotificationId.trim().isEmpty) {
    return null;
  }

  final int? parsed = int.tryParse(rawNotificationId.trim());
  if (parsed == null || parsed <= 0) {
    return null;
  }

  return parsed;
}

class AppPushBootstrap extends ConsumerStatefulWidget {
  final Widget child;

  const AppPushBootstrap({super.key, required this.child});

  static bool get _isAndroidTarget {
    if (kIsWeb) {
      return false;
    }

    return Platform.isAndroid;
  }

  static Future<void> preRunSetup() async {
    if (!_isAndroidTarget) {
      return;
    }

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(
        appFirebaseMessagingBackgroundHandler,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Push bootstrap preRunSetup omitido por error Firebase: $e\n$stackTrace',
      );
    }
  }

  @override
  ConsumerState<AppPushBootstrap> createState() => _AppPushBootstrapState();
}

class _AppPushBootstrapState extends ConsumerState<AppPushBootstrap> {
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSubscription;
  StreamSubscription<String>? _onTokenRefreshSubscription;

  bool _runtimeReady = false;
  bool _permissionDenied = false;
  String? _lastRegistrationFingerprint;

  @override
  void initState() {
    super.initState();
    unawaited(_setupRuntime());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (AuthState? _, AuthState next) {
      if (!_runtimeReady || !AppPushBootstrap._isAndroidTarget) {
        return;
      }

      if (next.isAuthenticated) {
        unawaited(_ensurePushRegistration(next));
        return;
      }

      if (next.authStatus == AuthStatus.notAuthenticated) {
        _lastRegistrationFingerprint = null;
        _permissionDenied = false;
        unawaited(_clearStoredPushToken());
      }
    });

    return widget.child;
  }

  @override
  void dispose() {
    _onMessageSubscription?.cancel();
    _onMessageOpenedSubscription?.cancel();
    _onTokenRefreshSubscription?.cancel();
    super.dispose();
  }

  Future<void> _setupRuntime() async {
    if (!AppPushBootstrap._isAndroidTarget) {
      return;
    }

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(
        appFirebaseMessagingBackgroundHandler,
      );

      await _initializeLocalNotifications();
      await _configureMessageStreams();

      _runtimeReady = true;

      final RemoteMessage? initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        await _handleNotificationOpen(initialMessage);
      }

      final AuthState currentAuthState = ref.read(authProvider);
      if (currentAuthState.isAuthenticated) {
        await _ensurePushRegistration(currentAuthState);
      }
    } catch (e, stackTrace) {
      debugPrint('No se pudo inicializar push runtime: $e\n$stackTrace');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/launcher_icon'),
        );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
            _navigateToNotificaciones(
              notificationId: _extractNotificationIdFromRoutePayload(
                notificationResponse.payload,
              ),
            );
          },
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidPlugin?.createNotificationChannel(_generalAndroidChannel);
  }

  Future<void> _configureMessageStreams() async {
    _onMessageSubscription = FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) {
      unawaited(_handleForegroundMessage(message));
    });

    _onMessageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
      RemoteMessage message,
    ) {
      unawaited(_handleNotificationOpen(message));
    });

    _onTokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen((String refreshedToken) {
          unawaited(_handleTokenRefresh(refreshedToken));
        });
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await _syncBadgeFromPayload(message);
    await _showForegroundNotification(message);
    await _syncNotificationsModules();
  }

  Future<void> _handleNotificationOpen(RemoteMessage message) async {
    await _syncBadgeFromPayload(message);
    await _syncNotificationsModules();
    _navigateToNotificaciones(
      notificationId: _extractNotificationIdFromPayload(message.data),
    );
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    if (notification == null) {
      return;
    }

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _generalChannelId,
        _generalChannelName,
        channelDescription: _generalChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
      ),
    );

    await _localNotificationsPlugin.show(
      message.hashCode,
      notification.title ?? 'Notificaciones',
      notification.body ?? '',
      notificationDetails,
      payload: _buildNotificacionesRoute(
        notificationId: _extractNotificationIdFromPayload(message.data),
      ),
    );
  }

  Future<void> _handleTokenRefresh(String refreshedToken) async {
    final AuthState authState = ref.read(authProvider);
    if (!authState.isAuthenticated || refreshedToken.trim().isEmpty) {
      return;
    }

    await _registerTokenWithBackend(
      authState: authState,
      pushToken: refreshedToken.trim(),
    );
  }

  Future<void> _ensurePushRegistration(AuthState authState) async {
    if (!authState.isAuthenticated || _permissionDenied) {
      return;
    }

    final bool permissionGranted = await _requestNotificationPermission();
    if (!permissionGranted) {
      _permissionDenied = true;
      return;
    }

    final String? pushToken = await FirebaseMessaging.instance.getToken();
    if (pushToken == null || pushToken.trim().isEmpty) {
      return;
    }

    await _registerTokenWithBackend(
      authState: authState,
      pushToken: pushToken.trim(),
    );
  }

  Future<void> _registerTokenWithBackend({
    required AuthState authState,
    required String pushToken,
  }) async {
    final KeyValueStorageService keyValueStorageService = ref.read(
      keyValueStorageServiceProvider,
    );
    final String deviceId = await _getOrCreateDeviceId(keyValueStorageService);
    final String username = authState.user?.username.trim().toLowerCase() ?? '';
    final String fingerprint = '$username|$deviceId|$pushToken';

    if (_lastRegistrationFingerprint == fingerprint) {
      return;
    }

    try {
      await ref
          .read(pushTokenBackendClientProvider)
          .upsertPushToken(
            deviceId: deviceId,
            pushToken: pushToken,
            platform: 'android',
            deviceName: 'Android fisico',
            appVersion: AppMetadata.version,
          );

      _lastRegistrationFingerprint = fingerprint;
      await keyValueStorageService.setKeyValue<String>(
        SessionStorageKeys.pushToken,
        pushToken,
      );
    } catch (e, stackTrace) {
      debugPrint('No se pudo registrar push token en backend: $e\n$stackTrace');
    }
  }

  Future<void> _clearStoredPushToken() async {
    final KeyValueStorageService keyValueStorageService = ref.read(
      keyValueStorageServiceProvider,
    );
    await keyValueStorageService.removeKey(SessionStorageKeys.pushToken);
  }

  Future<bool> _requestNotificationPermission() async {
    final NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<String> _getOrCreateDeviceId(
    KeyValueStorageService keyValueStorageService,
  ) async {
    final String? existing = await keyValueStorageService.getValue<String>(
      SessionStorageKeys.pushDeviceId,
    );

    if (existing != null && existing.trim().isNotEmpty) {
      return existing.trim();
    }

    final String generated =
        'android-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000000)}';
    await keyValueStorageService.setKeyValue<String>(
      SessionStorageKeys.pushDeviceId,
      generated,
    );
    return generated;
  }

  Future<void> _syncNotificationsModules() async {
    ref.invalidate(notificacionesNoLeidasProvider);

    unawaited(ref.read(notificacionesProvider.notifier).loadNotificaciones());
    unawaited(ref.read(tramitesProvider.notifier).loadTramites());
  }

  Future<void> _syncBadgeFromPayload(RemoteMessage message) async {
    final int? noLeidas = _extractNoLeidasFromPayload(message.data);
    if (noLeidas == null) {
      return;
    }

    await ref
        .read(appIconBadgeServiceProvider)
        .syncUnreadCountRespectingPreference(noLeidas);
  }

  String _buildNotificacionesRoute({int? notificationId}) {
    if (notificationId == null) {
      return '/notificaciones';
    }

    return '/notificaciones?notificationId=$notificationId';
  }

  void _navigateToNotificaciones({int? notificationId}) {
    ref
        .read(appRouterProvider)
        .go(_buildNotificacionesRoute(notificationId: notificationId));
  }
}
