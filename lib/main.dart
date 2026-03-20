import 'package:flutter/material.dart';
import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/features/shared/presentation/widgets/app_session_guard.dart';
import 'package:app_gore_callao/features/shared/presentation/widgets/app_icon_badge_sync.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.initEnvironment();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp.router(
      title: Environment.appName,
      routerConfig: ref.watch(appRouterProvider),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      builder: (BuildContext context, Widget? child) {
        return AppSessionGuard(
          child: AppIconBadgeSync(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
