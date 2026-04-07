import 'dart:math';

import 'package:app_not/core/storage/session_storage_keys.dart';
import 'package:app_not/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:app_not/features/shared/infrastructure/services/key_value_storage_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<DeviceIdService> deviceIdServiceProvider =
    Provider<DeviceIdService>((Ref ref) {
      final KeyValueStorageService keyValueStorageService = ref.watch(
        keyValueStorageServiceProvider,
      );

      return DeviceIdService(keyValueStorageService);
    });

class DeviceIdService {
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
        'android-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000000)}';

    await keyValueStorageService.setKeyValue<String>(
      SessionStorageKeys.pushDeviceId,
      generated,
    );

    return generated;
  }
}
