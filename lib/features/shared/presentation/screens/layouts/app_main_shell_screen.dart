import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/notificaciones/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/shared/presentation/screens/layouts/header.dart';
import 'package:app_gore_callao/features/shared/presentation/widgets/app_main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppMainShellScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppMainShellScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState authState = ref.watch(authProvider);
    final UnreadBadgeUiState unreadBadgeUiState = ref.watch(
      notificacionesUnreadBadgeUiProvider,
    );
    final AppMainTab currentTab = _tabFromIndex(navigationShell.currentIndex);

    return Scaffold(
      drawer: const AppMainDrawer(),
      appBar: Header(
        userName: authState.displayName,
        userEntity: authState.displayEntity,
        unreadNotifications: unreadBadgeUiState.count,
        unreadNotificationsHasError: unreadBadgeUiState.hasError,
        onNotificationsClick: () {
          _goToTab(AppMainTab.notificaciones);
        },
      ),
      bottomNavigationBar: AppMainNavigationBar(
        currentTab: currentTab,
        unreadNotifications: unreadBadgeUiState.count,
        unreadNotificationsHasError: unreadBadgeUiState.hasError,
        onTabSelected: (AppMainTab tab) => _goToTab(tab),
      ),
      body: navigationShell,
    );
  }

  void _goToTab(AppMainTab tab) {
    final int tabIndex = _indexFromTab(tab);
    navigationShell.goBranch(
      tabIndex,
      initialLocation: tabIndex == navigationShell.currentIndex,
    );
  }

  AppMainTab _tabFromIndex(int index) {
    switch (index) {
      case 0:
        return AppMainTab.home;
      case 1:
        return AppMainTab.tramites;
      case 2:
        return AppMainTab.notificaciones;
      default:
        return AppMainTab.home;
    }
  }

  int _indexFromTab(AppMainTab tab) {
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
