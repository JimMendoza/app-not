import 'package:app_gore_callao/features/shared/presentation/screens/legal_information_screen.dart';
import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalStaticContentScreen(
      title: 'Terminos y condiciones',
      intro:
          'El uso de la aplicacion implica aceptar las condiciones operativas definidas por la institucion.\n\nLa informacion mostrada esta sujeta a actualizaciones funcionales y normativas.',
      bulletPoints: <String>[],
    );
  }
}
