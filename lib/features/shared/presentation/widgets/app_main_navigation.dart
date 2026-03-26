import 'package:app_not/config/config.dart';
import 'package:app_not/features/auth/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppMainTab { home, tramites, notificaciones }

class AppMainNavigationBar extends StatelessWidget {
  final AppMainTab currentTab;
  final int unreadNotifications;
  final bool unreadNotificationsHasError;
  final ValueChanged<AppMainTab> onTabSelected;

  const AppMainNavigationBar({
    super.key,
    required this.currentTab,
    this.unreadNotifications = 0,
    this.unreadNotificationsHasError = false,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return NavigationBar(
      backgroundColor: appColors.surfacePrimary,
      selectedIndex: _tabIndex(currentTab),
      onDestinationSelected: (int index) {
        final AppMainTab selectedTab = AppMainTab.values[index];
        onTabSelected(selectedTab);
      },
      destinations: <NavigationDestination>[
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: const Icon(Icons.description_outlined),
          selectedIcon: const Icon(Icons.description),
          label: 'Tramites',
        ),
        NavigationDestination(
          icon: _NavigationBadgeIcon(
            icon: Icons.notifications_none_rounded,
            badgeLabel: _badgeLabel(),
            isError: unreadNotificationsHasError,
          ),
          selectedIcon: _NavigationBadgeIcon(
            icon: Icons.notifications,
            badgeLabel: _badgeLabel(),
            isError: unreadNotificationsHasError,
          ),
          label: 'Notificaciones',
        ),
      ],
    );
  }

  String? _badgeLabel() {
    if (unreadNotificationsHasError) {
      return '!';
    }

    if (unreadNotifications <= 0) {
      return null;
    }

    return unreadNotifications > 99 ? '99+' : '$unreadNotifications';
  }

  int _tabIndex(AppMainTab tab) {
    switch (tab) {
      case AppMainTab.home:
        return 0;
      case AppMainTab.tramites:
        return 1;
      case AppMainTab.notificaciones:
        return 2;
    }
  }
}

class _NavigationBadgeIcon extends StatelessWidget {
  final IconData icon;
  final String? badgeLabel;
  final bool isError;

  const _NavigationBadgeIcon({
    required this.icon,
    required this.badgeLabel,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Icon(icon),
        if (badgeLabel != null)
          Positioned(
            top: -6,
            right: -10,
            child: Container(
              padding: AppSpacing.symmetric(
                horizontal: AppSpacing.s4,
                vertical: AppSpacing.s2,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: isError ? appColors.danger : appColors.badgeBackground,
                borderRadius: AppRadii.pillRadius,
              ),
              child: Center(
                child: Text(
                  badgeLabel!,
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: isError
                        ? appColors.onBrand
                        : appColors.badgeForeground,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class AppMainDrawer extends ConsumerWidget {
  const AppMainDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState authState = ref.watch(authProvider);
    final appColors = context.appColors;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: AppSpacing.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s16,
                AppSpacing.s20,
                AppSpacing.s20,
              ),
              decoration: BoxDecoration(color: appColors.brandPrimary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/img/logo_gore.png',
                    width: AppComponentSizes.drawerLogo,
                    height: AppComponentSizes.drawerLogo,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    authState.displayName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: appColors.headerOnColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    authState.displayEntity,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: appColors.headerOnColorMuted,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: AppSpacing.vertical(AppSpacing.s8),
                children: <Widget>[
                  const _DrawerSectionTitle(title: 'Mi cuenta'),
                  _DrawerActionTile(
                    icon: Icons.badge_outlined,
                    label: 'Mis datos',
                    onTap: () => _openMyData(context),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  const _DrawerSectionTitle(title: 'Ajustes'),
                  _DrawerActionTile(
                    icon: Icons.palette_outlined,
                    label: 'Tema',
                    onTap: () => _openThemeSettings(context),
                  ),
                  _DrawerActionTile(
                    icon: Icons.tune_outlined,
                    label: 'Notificaciones',
                    onTap: () => _openNotificationSettings(context),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  const _DrawerSectionTitle(title: 'Informacion legal'),
                  _DrawerActionTile(
                    icon: Icons.menu_book_outlined,
                    label: 'Información legal',
                    onTap: () => _openLegalInformation(context),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  const _DrawerSectionTitle(title: 'Sesion'),
                  ListTile(
                    leading: Icon(Icons.logout, color: appColors.danger),
                    title: Text(
                      'Salir',
                      style: GoogleFonts.montserrat(
                        color: appColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await ref.read(authProvider.notifier).logout();
                    },
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: AppSpacing.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s14,
                AppSpacing.s20,
                AppSpacing.s18,
              ),
              decoration: BoxDecoration(
                color: appColors.surfaceSecondary,
                border: Border(top: BorderSide(color: appColors.borderSubtle)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    Environment.appName,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    'Version ${AppMetadata.version}',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLegalInformation(BuildContext context) {
    _navigateFromDrawer(context, '/informacion/legal');
  }

  void _openMyData(BuildContext context) {
    _navigateFromDrawer(context, '/mi-cuenta/mis-datos');
  }

  void _openThemeSettings(BuildContext context) {
    _navigateFromDrawer(context, '/ajustes/tema');
  }

  void _openNotificationSettings(BuildContext context) {
    _navigateFromDrawer(context, '/ajustes/notificaciones');
  }

  void _navigateFromDrawer(BuildContext context, String location) {
    Navigator.of(context).pop();
    context.go(location);
  }
}

class _DrawerActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return ListTile(
      contentPadding: AppSpacing.horizontal(AppSpacing.s12),
      leading: Icon(icon, color: appColors.textSecondary),
      title: Text(
        label,
        style: GoogleFonts.montserrat(
          color: appColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _DrawerSectionTitle extends StatelessWidget {
  final String title;

  const _DrawerSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: AppSpacing.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s8,
        AppSpacing.s16,
        AppSpacing.s4,
      ),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: appColors.textMuted,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

