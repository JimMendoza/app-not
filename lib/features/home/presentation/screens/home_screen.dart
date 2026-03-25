import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/home/domain/domain.dart';
import 'package:app_gore_callao/features/home/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/notificaciones/presentation/providers/providers.dart';
import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = context.appColors;
    final AuthState authState = ref.watch(authProvider);
    final user = authState.user;
    final AsyncValue<List<Module>> modulesAsync = ref.watch(modulesProvider);
    final UnreadBadgeUiState unreadBadgeUiState = ref.watch(
      notificacionesUnreadBadgeUiProvider,
    );

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Center(
        child: Padding(
          padding: AppSpacing.all(AppSpacing.s16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppLayout.maxHomeWidth),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: AppSpacing.symmetric(
                    horizontal: AppSpacing.s24,
                    vertical: AppSpacing.s20,
                  ),
                  decoration: BoxDecoration(
                    color: appColors.surfacePrimary,
                    borderRadius: AppRadii.cardRadius,
                    boxShadow: AppShadows.panel(context),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: AppComponentSizes.homeAvatar,
                        height: AppComponentSizes.homeAvatar,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              appColors.surfacePrimary,
                              appColors.surfaceSecondary,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.subtle(context),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 36,
                          color: appColors.brandPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Hola, ${authState.displayName}',
                              style: GoogleFonts.montserrat(
                                color: appColors.brandPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s4),
                            Text(
                              'Selecciona un modulo para comenzar',
                              style: GoogleFonts.montserrat(
                                color: appColors.brandAccent,
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
                const SizedBox(height: AppSpacing.s24),
                Container(
                  padding: AppSpacing.all(AppSpacing.s32),
                  decoration: BoxDecoration(
                    color: appColors.surfacePrimary,
                    borderRadius: AppRadii.panelRadius,
                    boxShadow: AppShadows.hero(context),
                  ),
                  child: _ModulesContent(
                    modulesAsync: modulesAsync,
                    unreadNotifications: unreadBadgeUiState.count,
                    unreadNotificationsHasError: unreadBadgeUiState.hasError,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModulesContent extends StatelessWidget {
  final AsyncValue<List<Module>> modulesAsync;
  final int unreadNotifications;
  final bool unreadNotificationsHasError;

  const _ModulesContent({
    required this.modulesAsync,
    required this.unreadNotifications,
    required this.unreadNotificationsHasError,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return modulesAsync.when(
      loading: () => Padding(
        padding: AppSpacing.vertical(AppSpacing.s24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace _) {
        final String errorMessage = AppErrorFormatter.readable(error);
        return Column(
          children: <Widget>[
            Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: appColors.brandPrimary,
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              'No se pudo cargar los modulos.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: appColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s6),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: appColors.textMuted,
              ),
            ),
          ],
        );
      },
      data: (List<Module> modules) {
        final List<Module> normalizedModules = _normalizeModules(modules);

        if (normalizedModules.isEmpty) {
          return Column(
            children: <Widget>[
              Icon(
                Icons.apps_outlined,
                size: 40,
                color: appColors.brandPrimary,
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                'No hay modulos habilitados para este usuario.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: appColors.textSecondary,
                ),
              ),
            ],
          );
        }

        return Column(
          children: <Widget>[
            ...normalizedModules.map(
              (Module module) => Padding(
                padding: AppSpacing.only(bottom: AppSpacing.s16),
                child: _ModuleButton(
                  icon: _resolveModuleIcon(module),
                  label: module.nombre,
                  badgeLabel: _resolveBadgeLabel(module),
                  badgeIsError:
                      unreadNotificationsHasError &&
                      _isNotificaciones(
                        _normalizeText(module.nombre),
                        _normalizeText(module.id),
                      ),
                  onPressed: () => context.go(_buildModuleRoute(module)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String? _resolveBadgeLabel(Module module) {
    final bool isNotificaciones = _isNotificaciones(
      _normalizeText(module.nombre),
      _normalizeText(module.id),
    );

    if (!isNotificaciones) {
      return null;
    }

    if (unreadNotificationsHasError) {
      return '!';
    }

    if (unreadNotifications <= 0) {
      return null;
    }

    return unreadNotifications > 99 ? '99+' : '$unreadNotifications';
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
  final String encodedModuleId = Uri.encodeComponent(
    moduleId.isEmpty ? 'modulo' : moduleId,
  );
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
  final String? badgeLabel;
  final bool badgeIsError;
  final VoidCallback onPressed;

  const _ModuleButton({
    required this.icon,
    required this.label,
    this.badgeLabel,
    this.badgeIsError = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: AppSpacing.vertical(AppSpacing.s20),
          backgroundColor: appColors.brandPrimary,
          foregroundColor: appColors.onBrand,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
          elevation: 8,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 28),
                const SizedBox(width: AppSpacing.s12),
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
            if (badgeLabel != null)
              Positioned(
                top: -10,
                right: -8,
                child: Container(
                  padding: AppSpacing.symmetric(
                    horizontal: AppSpacing.s8,
                    vertical: AppSpacing.s4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeIsError
                        ? appColors.danger
                        : appColors.badgeBackground,
                    borderRadius: AppRadii.pillRadius,
                  ),
                  child: Text(
                    badgeLabel!,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: badgeIsError
                          ? appColors.onBrand
                          : appColors.badgeForeground,
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
