import 'package:app_not/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

void _ensureTestEnvironment() {
  dotenv.loadFromString(
    envString: '''
APP_NAME=NOT
APP_LEMA=Testing
APP_COPYRIGHT=NOT
API_URL=http://localhost:8000/api
''',
  );
}

Widget buildTestApp(
  Widget child, {
  List<dynamic> overrides = const <dynamic>[],
}) {
  GoogleFonts.config.allowRuntimeFetching = false;
  _ensureTestEnvironment();

  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp(
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      home: child,
    ),
  );
}

Future<GoRouter> pumpRouterApp(
  WidgetTester tester, {
  List<dynamic> overrides = const <dynamic>[],
}) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  _ensureTestEnvironment();
  late GoRouter router;

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides.cast(),
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          router = ref.watch(appRouterProvider);
          return MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
          );
        },
      ),
    ),
  );

  await tester.pump();
  return router;
}
