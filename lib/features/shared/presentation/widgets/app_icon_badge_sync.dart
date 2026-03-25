import 'dart:async';

import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/notificaciones/presentation/providers/notificaciones_provider.dart';
import 'package:app_gore_callao/features/shared/infrastructure/services/app_icon_badge_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppIconBadgeSync extends ConsumerStatefulWidget {
  final Widget child;

  const AppIconBadgeSync({super.key, required this.child});

  @override
  ConsumerState<AppIconBadgeSync> createState() => _AppIconBadgeSyncState();
}

class _AppIconBadgeSyncState extends ConsumerState<AppIconBadgeSync> {
  int? _lastScheduledBadgeCount;
  bool? _lastScheduledBadgeVisibility;

  @override
  Widget build(BuildContext context) {
    final AuthState authState = ref.watch(authProvider);

    if (authState.authStatus == AuthStatus.notAuthenticated) {
      _scheduleBadgeSync(0);
      return widget.child;
    }

    if (!authState.isAuthenticated) {
      return widget.child;
    }

    final bool? shouldShowBadge = ref
        .watch(notificacionesBadgeVisiblePreferenceProvider)
        .asData
        ?.value;

    if (shouldShowBadge != null) {
      _scheduleBadgeVisibilitySync(shouldShowBadge);
      if (!shouldShowBadge) {
        _scheduleBadgeSync(0);
        return widget.child;
      }
    }

    final AsyncValue<int> unreadNotificationsAsync = ref.watch(
      notificacionesNoLeidasProvider,
    );
    final int? unreadNotifications = unreadNotificationsAsync.maybeWhen(
      data: (int value) => value,
      orElse: () => null,
    );

    if (unreadNotifications != null) {
      _scheduleBadgeSync(unreadNotifications);
    }

    return widget.child;
  }

  void _scheduleBadgeSync(int count) {
    if (_lastScheduledBadgeCount == count) {
      return;
    }

    _lastScheduledBadgeCount = count;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(ref.read(appIconBadgeServiceProvider).syncUnreadCount(count));
    });
  }

  void _scheduleBadgeVisibilitySync(bool isVisible) {
    if (_lastScheduledBadgeVisibility == isVisible) {
      return;
    }

    _lastScheduledBadgeVisibility = isVisible;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(
        ref.read(appIconBadgeServiceProvider).setUnreadBadgeVisible(isVisible),
      );
    });
  }
}
