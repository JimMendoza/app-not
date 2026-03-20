import 'dart:io';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<AppIconBadgeService> appIconBadgeServiceProvider =
    Provider<AppIconBadgeService>((Ref ref) {
      return const AppIconBadgeService();
    });

class AppIconBadgeService {
  const AppIconBadgeService();

  static bool? _isSupportedCache;

  Future<void> syncUnreadCount(int count) async {
    if (!_isBadgePlatform) {
      return;
    }

    try {
      final bool isSupported = await _resolveIsSupported();
      if (!isSupported) {
        return;
      }

      final int normalizedCount = count < 0 ? 0 : count;
      await Future<void>.sync(() => AppBadgePlus.updateBadge(normalizedCount));
    } on MissingPluginException {
      // Ignore on unsupported test/desktop environments.
    } on PlatformException {
      // Ignore platform-specific badge failures and keep app flow stable.
    }
  }

  Future<void> clear() async {
    await syncUnreadCount(0);
  }

  Future<bool> _resolveIsSupported() async {
    final bool? cachedValue = _isSupportedCache;
    if (cachedValue != null) {
      return cachedValue;
    }

    try {
      final bool isSupported = await AppBadgePlus.isSupported();
      _isSupportedCache = isSupported;
      return isSupported;
    } on MissingPluginException {
      _isSupportedCache = false;
      return false;
    } on PlatformException {
      _isSupportedCache = false;
      return false;
    }
  }

  bool get _isBadgePlatform {
    if (kIsWeb) {
      return false;
    }

    return Platform.isAndroid || Platform.isIOS;
  }
}
