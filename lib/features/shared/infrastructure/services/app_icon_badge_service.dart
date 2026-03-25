import 'dart:io';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Provider<AppIconBadgeService> appIconBadgeServiceProvider =
    Provider<AppIconBadgeService>((Ref ref) {
      return const AppIconBadgeService();
    });

class AppIconBadgeService {
  const AppIconBadgeService();

  static const String _showUnreadBadgePreferenceKey =
      'show_unread_notifications_badge';
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

  Future<void> setUnreadBadgeVisible(bool isVisible) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_showUnreadBadgePreferenceKey, isVisible);
    } catch (_) {
      // Keep app flow stable if preference persistence is unavailable.
    }

    if (!isVisible) {
      await clear();
    }
  }

  Future<bool> isUnreadBadgeVisible() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_showUnreadBadgePreferenceKey) ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> syncUnreadCountRespectingPreference(int count) async {
    final bool isVisible = await isUnreadBadgeVisible();
    await syncUnreadCount(isVisible ? count : 0);
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
