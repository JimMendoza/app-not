import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/auth/presentation/screens/screens.dart';
import 'package:app_gore_callao/features/home/presentation/screens/home_screen.dart';
import 'package:app_gore_callao/features/shared/presentation/screens/auth_checking_screen.dart';
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
