import 'package:go_router/go_router.dart';
import 'package:app_gore_callao/features/home/presentation/screens/home_screen.dart';
import 'package:app_gore_callao/features/auth/presentation/screens/screens.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
  ],
);
