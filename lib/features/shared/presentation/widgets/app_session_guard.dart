import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/core/session/session_event_bus.dart';
import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/shared/presentation/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSessionGuard extends ConsumerStatefulWidget {
  final Widget child;

  const AppSessionGuard({super.key, required this.child});

  @override
  ConsumerState<AppSessionGuard> createState() => _AppSessionGuardState();
}

class _AppSessionGuardState extends ConsumerState<AppSessionGuard> {
  bool _isHandlingEvent = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<SessionEvent?>(sessionEventProvider, (previous, next) async {
      if (next == null || _isHandlingEvent) {
        return;
      }

      if (next.type != SessionEventType.sessionExpired) {
        return;
      }

      final AuthState authState = ref.read(authProvider);
      if (authState.authStatus == AuthStatus.notAuthenticated) {
        ref.read(sessionEventProvider.notifier).state = null;
        return;
      }

      _isHandlingEvent = true;
      ref.read(sessionEventProvider.notifier).state = null;

      try {
        await ref.read(authProvider.notifier).logout(
          next.message,
          AppFailureType.sessionExpired,
        );

        if (!mounted) {
          return;
        }

        await AppDialogHelper.showSessionExpiredDialog(
          this.context,
          message: next.message,
        );
      } finally {
        _isHandlingEvent = false;
      }
    });

    return widget.child;
  }
}
