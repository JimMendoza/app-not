import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppMainTab { home, tramites, notificaciones }

class AppMainNavigationBar extends StatelessWidget {
  final AppMainTab currentTab;

  const AppMainNavigationBar({super.key, required this.currentTab});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _tabIndex(currentTab),
      onDestinationSelected: (int index) {
        final AppMainTab selectedTab = AppMainTab.values[index];
        if (selectedTab == currentTab) {
          return;
        }

        context.go(_routeForTab(selectedTab));
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

  String _routeForTab(AppMainTab tab) {
    switch (tab) {
      case AppMainTab.home:
        return '/home';
      case AppMainTab.tramites:
        return '/tramites';
      case AppMainTab.notificaciones:
        return '/notificaciones';
    }
  }
}

class AppMainDrawer extends ConsumerWidget {
  final AppMainTab currentTab;

  const AppMainDrawer({super.key, required this.currentTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState authState = ref.watch(authProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[Color(0xFF910C87), Color(0xFF6D0D67)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    authState.displayName,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    authState.displayEntity,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: <Widget>[
                  _DrawerTile(
                    icon: Icons.home,
                    label: 'Inicio',
                    isSelected: currentTab == AppMainTab.home,
                    onTap: () => _goToTab(context, AppMainTab.home),
                  ),
                  _DrawerTile(
                    icon: Icons.description,
                    label: 'Tramites',
                    isSelected: currentTab == AppMainTab.tramites,
                    onTap: () => _goToTab(context, AppMainTab.tramites),
                  ),
                  _DrawerTile(
                    icon: Icons.notifications,
                    label: 'Notificaciones',
                    isSelected: currentTab == AppMainTab.notificaciones,
                    onTap: () =>
                        _goToTab(context, AppMainTab.notificaciones),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFB91C1C)),
              title: Text(
                'Salir',
                style: GoogleFonts.montserrat(
                  color: const Color(0xFFB91C1C),
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

  void _goToTab(BuildContext context, AppMainTab targetTab) {
    Navigator.of(context).pop();
    if (targetTab == currentTab) {
      return;
    }

    switch (targetTab) {
      case AppMainTab.home:
        context.go('/home');
        break;
      case AppMainTab.tramites:
        context.go('/tramites');
        break;
      case AppMainTab.notificaciones:
        context.go('/notificaciones');
        break;
    }
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
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF7E1B77) : const Color(0xFF4B5563),
      ),
      title: Text(
        label,
        style: GoogleFonts.montserrat(
          color: isSelected ? const Color(0xFF7E1B77) : const Color(0xFF111827),
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFFF5ECF5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: onTap,
    );
  }
}
