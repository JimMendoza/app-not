import 'package:app_not/core/errors/errors.dart';
import 'package:app_not/features/tramites/presentation/providers/providers.dart';
import 'package:app_not/features/tramites/presentation/screens/tramite_hoja_ruta_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';
import '../support/test_fakes.dart';

void main() {
  testWidgets('muestra mensaje controlado cuando hoja-ruta responde 501', (
    WidgetTester tester,
  ) async {
    final repository = FakeTramitesRepository()
      ..hojaRutaError = const AppFailure(
        type: AppFailureType.serverError,
        message: 'La hoja de ruta aun no esta disponible.',
        statusCode: 501,
      );

    await tester.pumpWidget(
      buildTestApp(
        const TramiteHojaRutaScreen(tramiteId: 1, codigo: 'TR-001'),
        overrides: <dynamic>[
          tramitesRepositoryProvider.overrideWith((ref) => repository),
        ],
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('No se pudo cargar la hoja de ruta.'), findsOneWidget);
    expect(
      find.text('La hoja de ruta aun no esta disponible.'),
      findsOneWidget,
    );
    expect(find.text('Reintentar'), findsOneWidget);
  });
}
