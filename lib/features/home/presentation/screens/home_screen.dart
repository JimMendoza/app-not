import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/home/domain/domain.dart';
import 'package:app_gore_callao/features/home/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/notificaciones/presentation/providers/providers.dart';
import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/features/shared/presentation/screens/layouts/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState authState = ref.watch(authProvider);
    final user = authState.user;
    final AsyncValue<List<Module>> modulesAsync = ref.watch(modulesProvider);
    final AsyncValue<int> noLeidasAsync = ref.watch(
      notificacionesNoLeidasProvider,
    );
    final int unreadNotifications = noLeidasAsync.asData?.value ?? 0;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: Header(
        userName: authState.displayName,
        userEntity: authState.displayEntity,
        unreadNotifications: unreadNotifications,
        onNotificationsClick: () {
          context.go('/notificaciones');
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
                    child: _ModulesContent(
                      modulesAsync: modulesAsync,
                      unreadNotifications: unreadNotifications,
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

class _ModulesContent extends ConsumerWidget {
  final AsyncValue<List<Module>> modulesAsync;
  final int unreadNotifications;

  const _ModulesContent({
    required this.modulesAsync,
    required this.unreadNotifications,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return modulesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace _) {
        final String errorMessage = AppErrorFormatter.readable(error);
        return Column(
          children: <Widget>[
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: Color(0xFF99569E),
            ),
            const SizedBox(height: 12),
            Text(
              'No se pudo cargar los modulos.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => ref.refresh(modulesProvider),
              child: const Text('Reintentar'),
            ),
          ],
        );
      },
      data: (List<Module> modules) {
        final List<Module> normalizedModules = _normalizeModules(modules);

        if (normalizedModules.isEmpty) {
          return Column(
            children: <Widget>[
              const Icon(
                Icons.apps_outlined,
                size: 40,
                color: Color(0xFF99569E),
              ),
              const SizedBox(height: 12),
              Text(
                'No hay modulos habilitados para este usuario.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => ref.refresh(modulesProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar'),
              ),
            ],
          );
        }

        return Column(
          children: <Widget>[
            ...normalizedModules.map(
              (Module module) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ModuleButton(
                  icon: _resolveModuleIcon(module),
                  label: module.nombre,
                  badgeCount: _isNotificaciones(
                        _normalizeText(module.nombre),
                        _normalizeText(module.id),
                      )
                      ? unreadNotifications
                      : 0,
                  onPressed: () => context.go(_buildModuleRoute(module)),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => ref.refresh(modulesProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar modulos'),
              ),
            ),
          ],
        );
      },
    );
  }
}

List<Module> _normalizeModules(List<Module> modules) {
  final List<Module> normalized = <Module>[];
  final Set<String> seen = <String>{};

  for (final Module module in modules) {
    if (module.nombre.trim().isEmpty) {
      continue;
    }

    final String key = _normalizedModuleKey(module);
    if (key.isEmpty || seen.contains(key)) {
      continue;
    }

    seen.add(key);
    normalized.add(module);
  }

  return normalized;
}

String _buildModuleRoute(Module module) {
  final String normalizedName = _normalizeText(module.nombre);
  final String normalizedId = _normalizeText(module.id);

  if (_isMesaPartesVirtual(normalizedName, normalizedId)) {
    return '/tramites';
  }

  if (_isNotificaciones(normalizedName, normalizedId)) {
    return '/notificaciones';
  }

  final String moduleId = _normalizedModuleKey(module);
  final String encodedModuleId = Uri.encodeComponent(moduleId.isEmpty ? 'modulo' : moduleId);
  final String encodedModuleName = Uri.encodeComponent(module.nombre);
  return '/modulo/$encodedModuleId?nombre=$encodedModuleName';
}

String _normalizedModuleKey(Module module) {
  final String normalizedName = _normalizeText(module.nombre);
  if (normalizedName.isNotEmpty) {
    return normalizedName;
  }

  return _normalizeText(module.id);
}

String _normalizeText(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

bool _isMesaPartesVirtual(String normalizedName, String normalizedId) {
  return normalizedId == 'mesa_partes_virtual' ||
      normalizedId == 'mesa_partes' ||
      normalizedName == 'mesa_partes_virtual' ||
      normalizedName == 'mesa_de_partes_virtual' ||
      normalizedName.contains('mesa_partes') ||
      normalizedName.contains('mesa_de_partes');
}

bool _isNotificaciones(String normalizedName, String normalizedId) {
  return normalizedId == 'notificaciones' ||
      normalizedName == 'notificaciones' ||
      normalizedName.contains('notificacion');
}

IconData _resolveModuleIcon(Module module) {
  final String normalizedKey = _normalizedModuleKey(module);
  final String normalizedIcon = module.icono.toLowerCase().trim();
  final Map<String, IconData> iconMap = <String, IconData>{
    'description': Icons.description,
    'notifications': Icons.notifications,
    'notification': Icons.notifications,
    'list_alt': Icons.list_alt,
    'assignment': Icons.assignment,
    'receipt_long': Icons.receipt_long,
    'timeline': Icons.timeline,
    'folder': Icons.folder,
    'dashboard': Icons.dashboard,
    'home': Icons.home,
  };

  if (iconMap.containsKey(normalizedIcon)) {
    return iconMap[normalizedIcon]!;
  }

  if (normalizedKey.contains('mesa_partes') ||
      normalizedIcon.contains('mesa') ||
      normalizedIcon.contains('partes')) {
    return Icons.description;
  }

  if (normalizedKey.contains('notificacion') ||
      normalizedIcon.contains('notificacion') ||
      normalizedIcon.contains('notification')) {
    return Icons.notifications;
  }

  if (normalizedKey.contains('tramite') || normalizedIcon.contains('tramite')) {
    return Icons.assignment;
  }

  if (normalizedKey.contains('seguimiento') ||
      normalizedIcon.contains('seguimiento')) {
    return Icons.timeline;
  }

  return Icons.apps;
}

class _ModuleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int badgeCount;
  final VoidCallback onPressed;

  const _ModuleButton({
    required this.icon,
    required this.label,
    this.badgeCount = 0,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (badgeCount > 0)
              Positioned(
                top: -10,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEB3B),
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7A1575),
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
