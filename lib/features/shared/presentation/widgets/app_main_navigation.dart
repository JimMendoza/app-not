import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppMainTab { home, tramites, notificaciones }

class AppMainNavigationBar extends StatelessWidget {
  final AppMainTab currentTab;
  final ValueChanged<AppMainTab> onTabSelected;

  const AppMainNavigationBar({
    super.key,
    required this.currentTab,
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
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.description_outlined),
          selectedIcon: Icon(Icons.description),
          label: 'Tramites',
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_none_rounded),
          selectedIcon: Icon(Icons.notifications),
          label: 'Notificaciones',
        ),
      ],
    );
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

class AppMainDrawer extends ConsumerWidget {
  final AppMainTab currentTab;
  final ValueChanged<AppMainTab> onTabSelected;

  const AppMainDrawer({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState authState = ref.watch(authProvider);
    final ThemeMode currentThemeMode = ref.watch(appThemeModeProvider);
    final AppThemeModeNotifier themeModeNotifier = ref.read(
      appThemeModeProvider.notifier,
    );
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
                  _DrawerTile(
                    icon: Icons.home,
                    label: 'Inicio',
                    isSelected: currentTab == AppMainTab.home,
                    onTap: () => _selectTab(context, AppMainTab.home),
                  ),
                  _DrawerTile(
                    icon: Icons.description,
                    label: 'Tramites',
                    isSelected: currentTab == AppMainTab.tramites,
                    onTap: () => _selectTab(context, AppMainTab.tramites),
                  ),
                  _DrawerTile(
                    icon: Icons.notifications,
                    label: 'Notificaciones',
                    isSelected: currentTab == AppMainTab.notificaciones,
                    onTap: () => _selectTab(context, AppMainTab.notificaciones),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Padding(
                    padding: AppSpacing.fromLTRB(
                      AppSpacing.s16,
                      AppSpacing.s8,
                      AppSpacing.s16,
                      AppSpacing.s4,
                    ),
                    child: Text(
                      'Apariencia',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: appColors.textMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  RadioGroup<ThemeMode>(
                    groupValue: currentThemeMode,
                    onChanged: (ThemeMode? selectedMode) {
                      if (selectedMode == null) {
                        return;
                      }

                      themeModeNotifier.setThemeMode(selectedMode);
                    },
                    child: Column(
                      children: <Widget>[
                        _ThemeModeTile(
                          value: ThemeMode.light,
                          icon: Icons.light_mode_outlined,
                          label: 'Claro',
                        ),
                        _ThemeModeTile(
                          value: ThemeMode.dark,
                          icon: Icons.dark_mode_outlined,
                          label: 'Oscuro',
                        ),
                        _ThemeModeTile(
                          value: ThemeMode.system,
                          icon: Icons.settings_suggest_outlined,
                          label: 'Sistema',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
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
    );
  }

  void _selectTab(BuildContext context, AppMainTab targetTab) {
    Navigator.of(context).pop();
    if (targetTab == currentTab) {
      return;
    }

    onTabSelected(targetTab);
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? appColors.brandPrimary : appColors.textSecondary,
      ),
      title: Text(
        label,
        style: GoogleFonts.montserrat(
          color: isSelected ? appColors.brandPrimary : appColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedTileColor: appColors.drawerSelection,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.mediumRadius),
      onTap: onTap,
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  final ThemeMode value;
  final IconData icon;
  final String label;

  const _ThemeModeTile({
    required this.value,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return ListTile(
      dense: true,
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
      trailing: Radio<ThemeMode>(value: value),
      onTap: () {
        final RadioGroupRegistry<ThemeMode>? group =
            RadioGroup.maybeOf<ThemeMode>(context);
        group?.onChanged(value);
      },
    );
  }
}
