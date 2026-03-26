import 'package:app_not/config/config.dart';
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
          padding: AppSpacing.all(AppSpacing.s24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxPlaceholderWidth,
            ),
            child: Container(
              padding: AppSpacing.all(AppSpacing.s32),
              decoration: BoxDecoration(
                color: appColors.surfacePrimary,
                borderRadius: AppRadii.panelRadius,
                boxShadow: AppShadows.floating(context),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.extension_rounded,
                    size: 56,
                    color: appColors.brandPrimary,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    moduleName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: appColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Text(
                    'El modulo "$moduleId" aun no esta disponible en esta version.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),
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

