import 'dart:math';

import 'package:app_not/core/storage/session_storage_keys.dart';
import 'package:app_not/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:app_not/features/shared/infrastructure/services/key_value_storage_service_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<DeviceIdService> deviceIdServiceProvider =
    Provider<DeviceIdService>((Ref ref) {
      final KeyValueStorageService keyValueStorageService = ref.watch(
        keyValueStorageServiceProvider,
      );

      return DeviceIdService(keyValueStorageService);
    });

class DeviceIdService {
  static const MethodChannel _channel = MethodChannel('app_not/device_id');

  final KeyValueStorageService keyValueStorageService;

  const DeviceIdService(this.keyValueStorageService);

  Future<String> getOrCreateDeviceId() async {
    final String? existing = await keyValueStorageService.getValue<String>(
      SessionStorageKeys.pushDeviceId,
    );

    if (existing != null && existing.trim().isNotEmpty) {
      return existing.trim();
    }

    final String generated =
        await _resolveStableAndroidDeviceId() ?? _generateFallbackDeviceId();

    await keyValueStorageService.setKeyValue<String>(
      SessionStorageKeys.pushDeviceId,
      generated,
    );

    return generated;
  }

  Future<String?> _resolveStableAndroidDeviceId() async {
    try {
      final String? rawAndroidId = await _channel.invokeMethod<String>(
        'getAndroidId',
      );
      if (rawAndroidId == null) {
        return null;
      }

      final String normalized = rawAndroidId.trim().toLowerCase();
      if (normalized.isEmpty) {
        return null;
      }

      return normalized;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    } catch (_) {
      return null;
    }
  }

  String _generateFallbackDeviceId() {
    return 'android-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000000)}';
  }
}
