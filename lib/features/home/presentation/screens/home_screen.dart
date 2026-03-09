import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/shared/presentation/screens/layouts/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<_ModuleInfo> modules = _buildModules(authState.permisos);
    final int unreadNotifications = authState.permisos.contains('notificaciones')
        ? 1
        : 0;

    return Scaffold(
      appBar: Header(
        userName: authState.displayName,
        userEntity: authState.displayEntity,
        unreadNotifications: unreadNotifications,
        onNotificationsClick: () {
          // Pendiente en siguiente bloque.
        },
        onLogout: () {
          ref.read(authProvider.notifier).logout();
        },
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 672),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[Colors.white, Color(0xFFF3F4F6)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 36,
                            color: Color(0xFF99569E),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Hola, ${authState.displayName}',
                                style: GoogleFonts.montserrat(
                                  color: const Color(0xFF99569E),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Selecciona un modulo para comenzar',
                                style: GoogleFonts.montserrat(
                                  color: const Color(0xFFEF7F7E),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: modules.isEmpty
                        ? Text(
                            'No hay modulos habilitados para este usuario.',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          )
                        : Column(
                            children: modules
                                .map(
                                  (_ModuleInfo module) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _ModuleButton(
                                      icon: module.icon,
                                      label: module.label,
                                      badge: module.badge,
                                      onPressed: () {
                                        // Pendiente en bloque de modulos.
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<_ModuleInfo> _buildModules(List<String> permisos) {
  final List<_ModuleInfo> modules = <_ModuleInfo>[];

  for (final String permiso in permisos) {
    switch (permiso) {
      case 'mesa_partes_virtual':
        modules.add(
          const _ModuleInfo(
            label: 'Mesa de Partes Virtual',
            icon: Icons.description,
          ),
        );
        break;
      case 'notificaciones':
        modules.add(
          const _ModuleInfo(
            label: 'Notificaciones',
            icon: Icons.notifications,
            badge: 1,
          ),
        );
        break;
      default:
        modules.add(
          _ModuleInfo(
            label: _humanizePermission(permiso),
            icon: Icons.apps,
          ),
        );
        break;
    }
  }

  return modules;
}

String _humanizePermission(String permiso) {
  return permiso
      .split('_')
      .map((String part) => part.isEmpty
          ? part
          : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

class _ModuleInfo {
  final String label;
  final IconData icon;
  final int? badge;

  const _ModuleInfo({
    required this.label,
    required this.icon,
    this.badge,
  });
}

class _ModuleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? badge;
  final VoidCallback onPressed;

  const _ModuleButton({
    required this.icon,
    required this.label,
    this.badge,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final int? badgeCount = badge;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: const Color(0xFF99569E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 28),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (badgeCount != null && badgeCount > 0)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF7F7E),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  child: Center(
                    child: Text(
                      '$badgeCount',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
