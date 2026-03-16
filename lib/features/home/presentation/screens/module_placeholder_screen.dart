import 'package:app_gore_callao/config/config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ModulePlaceholderScreen extends StatelessWidget {
  final String moduleId;
  final String moduleName;

  const ModulePlaceholderScreen({
    super.key,
    required this.moduleId,
    required this.moduleName,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: appColors.surfacePrimary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: appColors.shadowMedium,
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.extension_rounded,
                    size: 56,
                    color: appColors.brandPrimary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    moduleName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: appColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'El modulo "$moduleId" aun no esta disponible en esta version.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.go('/home'),
                    style: FilledButton.styleFrom(
                      backgroundColor: appColors.brandPrimary,
                    ),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver a modulos'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
