import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/auth/presentation/screens/screens.dart';
import 'package:app_gore_callao/features/home/presentation/screens/screens.dart';
import 'package:app_gore_callao/features/shared/presentation/screens/auth_checking_screen.dart';
import 'package:app_gore_callao/features/tramites/presentation/screens/screens.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final Provider<RouterNotifier> routerNotifierProvider =
    Provider<RouterNotifier>((Ref ref) {
      final RouterNotifier notifier = RouterNotifier(ref);
      ref.onDispose(notifier.dispose);
      return notifier;
    });

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  final RouterNotifier routerNotifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/checking',
    refreshListenable: routerNotifier,
    redirect: routerNotifier.redirect,
    routes: <RouteBase>[
      GoRoute(
        path: '/checking',
        builder: (context, state) => const AuthCheckingScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/tramites',
        builder: (context, state) => const TramitesScreen(),
      ),
      GoRoute(
        path: '/tramites/:tramiteId/hoja-ruta',
        builder: (context, state) {
          final String tramiteIdPath = state.pathParameters['tramiteId'] ?? '0';
          final int tramiteId = int.tryParse(tramiteIdPath) ?? 0;
          final String codigo = state.uri.queryParameters['codigo'] ?? '-';

          return TramiteHojaRutaScreen(
            tramiteId: tramiteId,
            codigo: codigo,
          );
        },
      ),
      GoRoute(
        path: '/modulo/:moduleId',
        builder: (context, state) {
          final String moduleId = state.pathParameters['moduleId'] ?? 'modulo';
          final String moduleName =
              state.uri.queryParameters['nombre'] ?? 'Modulo';

          return ModulePlaceholderScreen(
            moduleId: moduleId,
            moduleName: moduleName,
          );
        },
      ),
    ],
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref ref;

  RouterNotifier(this.ref) {
    ref.listen<AuthState>(authProvider, (AuthState? previous, AuthState next) {
      notifyListeners();
    });
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final AuthStatus authStatus = ref.read(authProvider).authStatus;
    final String currentLocation = state.matchedLocation;

    final bool isGoingToChecking = currentLocation == '/checking';
    final bool isGoingToLogin = currentLocation == '/';

    if (authStatus == AuthStatus.checking) {
      return isGoingToChecking ? null : '/checking';
    }

    if (authStatus == AuthStatus.notAuthenticated) {
      return isGoingToLogin ? null : '/';
    }

    if (authStatus == AuthStatus.authenticated &&
        (isGoingToLogin || isGoingToChecking)) {
      return '/home';
    }

    return null;
  }
}
