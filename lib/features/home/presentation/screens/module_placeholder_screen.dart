import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/shared/presentation/screens/layouts/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ModulePlaceholderScreen extends ConsumerWidget {
  final String moduleId;
  final String moduleName;

  const ModulePlaceholderScreen({
    super.key,
    required this.moduleId,
    required this.moduleName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState authState = ref.watch(authProvider);

    return Scaffold(
      appBar: Header(
        userName: authState.displayName,
        userEntity: authState.displayEntity,
        unreadNotifications: 0,
        onNotificationsClick: () {
          context.go('/modulo/notificaciones?nombre=Notificaciones');
        },
        onLogout: () {
          ref.read(authProvider.notifier).logout();
        },
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.extension_rounded,
                      size: 56,
                      color: Color(0xFF99569E),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      moduleName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF99569E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ruta "$moduleId" preparada. Este modulo se conectara en el siguiente bloque.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.go('/home'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF99569E),
                      ),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver a modulos'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
