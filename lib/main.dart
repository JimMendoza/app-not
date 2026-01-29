import 'package:flutter/material.dart';
import 'package:app_gore_callao/config/router/app_router.dart';
import 'package:app_gore_callao/config/theme/app_theme.dart';
import 'package:app_gore_callao/config/constants/environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.initEnvironment();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    );
  }
}
