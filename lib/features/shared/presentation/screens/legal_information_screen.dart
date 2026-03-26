import 'package:app_not/config/config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LegalInformationScreen extends StatelessWidget {
  const LegalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: AppSpacing.all(AppSpacing.s16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxFeatureWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: AppSpacing.all(AppSpacing.s20),
                  decoration: BoxDecoration(
                    color: appColors.surfacePrimary,
                    borderRadius: AppRadii.cardRadius,
                    boxShadow: AppShadows.panel(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Informacion legal',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: appColors.brandPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        'Consulta los documentos informativos disponibles de la aplicacion.',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                Expanded(
                  child: Container(
                    padding: AppSpacing.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: appColors.surfacePrimary,
                      borderRadius: AppRadii.cardRadius,
                      boxShadow: AppShadows.card(context),
                    ),
                    child: Column(
                      children: <Widget>[
                        _LegalOptionTile(
                          icon: Icons.shield_outlined,
                          title: 'Proteccion de datos',
                          subtitle:
                              'Informacion sobre el tratamiento de datos personales.',
                          onTap: () =>
                              context.go('/informacion/proteccion-datos'),
                        ),
                        _LegalOptionTile(
                          icon: Icons.gavel_outlined,
                          title: 'Terminos y condiciones',
                          subtitle:
                              'Condiciones generales de uso de la aplicacion.',
                          onTap: () => context.go(
                            '/informacion/terminos-condiciones',
                          ),
                        ),
                        _LegalOptionTile(
                          icon: Icons.info_outline,
                          title: 'Acerca de',
                          subtitle:
                              'Informacion general sobre la aplicacion y su finalidad.',
                          onTap: () => context.go('/informacion/acerca-de'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LegalStaticContentScreen extends StatelessWidget {
  final String title;
  final String intro;
  final List<String> bulletPoints;

  const LegalStaticContentScreen({
    super.key,
    required this.title,
    required this.intro,
    required this.bulletPoints,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: AppSpacing.all(AppSpacing.s16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxConsentWidth,
            ),
            child: Container(
              width: double.infinity,
              padding: AppSpacing.fromLTRB(
                AppSpacing.s28,
                AppSpacing.s30,
                AppSpacing.s28,
                AppSpacing.s24,
              ),
              decoration: BoxDecoration(
                color: appColors.surfacePrimary,
                borderRadius: AppRadii.largeRadius,
                boxShadow: AppShadows.panel(context),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Align(
                    child: Container(
                      width: AppComponentSizes.consentIllustration,
                      height: AppComponentSizes.consentIllustration,
                      decoration: BoxDecoration(
                        color: appColors.brandPrimarySoft,
                        borderRadius: AppRadii.avatarRadius,
                      ),
                      child: Icon(
                        Icons.info_outline,
                        size: 32,
                        color: appColors.brandPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  Align(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: appColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    intro,
                    style: GoogleFonts.montserrat(
                      fontSize: 17,
                      color: appColors.textPrimary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s18),
                  if (bulletPoints.isNotEmpty) ...<Widget>[
                    Container(
                      width: double.infinity,
                      padding: AppSpacing.all(AppSpacing.s16),
                      decoration: BoxDecoration(
                        color: appColors.surfaceSecondary,
                        borderRadius: AppRadii.mediumRadius,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ...bulletPoints.map(
                            (String point) => _LegalBullet(text: point),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _close(context),
                      child: Text(
                        'Cerrar',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _close(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    context.go('/informacion/legal');
  }
}

class _LegalOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LegalOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Card(
      elevation: 0,
      margin: AppSpacing.only(bottom: AppSpacing.s12),
      child: ListTile(
        contentPadding: AppSpacing.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s6,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.mediumRadius),
        leading: Icon(icon, color: appColors.brandPrimary),
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: appColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: appColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _LegalBullet extends StatelessWidget {
  final String text;

  const _LegalBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: AppSpacing.only(bottom: AppSpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('•', style: GoogleFonts.montserrat(fontSize: 16, height: 1.4)),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: appColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

