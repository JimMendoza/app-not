import 'package:app_not/features/shared/presentation/screens/legal_information_screen.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalStaticContentScreen(
      title: 'Acerca de',
      intro:
          'Aplicacion orientada al seguimiento de tramites y notificaciones del usuario autenticado. Facilita la consulta de informacion relevante del usuario y el acceso a los modulos institucionales disponibles.',
      bulletPoints: <String>[],
    );
  }
}

