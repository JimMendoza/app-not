import 'package:app_gore_callao/config/config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return SafeArea(
      child: SingleChildScrollView(
        padding: AppSpacing.all(AppSpacing.s16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxFeatureWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _HeaderCard(
                  title: 'Seleccion de notificaciones',
                  subtitle: '',
                  onBack: () => _goBack(context),
                ),
                const SizedBox(height: AppSpacing.s16),
                _InfoPanel(
                  title: 'Que podra configurarse despues',
                  items: const <_PlannedSetting>[
                    _PlannedSetting(
                      icon: Icons.notifications_active_outlined,
                      title: 'Cambios de estado del tramite',
                      description:
                          'Recibir alertas cuando un tramite avance o cambie de area.',
                    ),
                    _PlannedSetting(
                      icon: Icons.mark_email_unread_outlined,
                      title: 'Resumen diario o inmediato',
                      description:
                          'Elegir si las alertas llegan al momento o agrupadas por periodos.',
                    ),
                    _PlannedSetting(
                      icon: Icons.volume_off_outlined,
                      title: 'Silencio o prioridad',
                      description:
                          'Definir franjas horarias, prioridad o desactivar categorias especificas.',
                    ),
                    _PlannedSetting(
                      icon: Icons.devices_outlined,
                      title: 'Canales del aplicativo',
                      description:
                          'Administrar futuras notificaciones push, internas o correos de apoyo.',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),
                Container(
                  padding: AppSpacing.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: appColors.surfacePrimary,
                    borderRadius: AppRadii.cardRadius,
                    boxShadow: AppShadows.card(context),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.construction_outlined,
                        color: appColors.brandPrimary,
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Text(
                          'Por ahora esta vista es informativa. Cuando exista el backend y las reglas del negocio, se conectaran aqui las preferencias reales.',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: appColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/home');
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      padding: AppSpacing.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: appColors.surfacePrimary,
        borderRadius: AppRadii.cardRadius,
        boxShadow: AppShadows.panel(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: appColors.brandPrimary,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: appColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final String title;
  final List<_PlannedSetting> items;

  const _InfoPanel({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      padding: AppSpacing.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: appColors.surfacePrimary,
        borderRadius: AppRadii.cardRadius,
        boxShadow: AppShadows.panel(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: appColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          ...items.map(
            (_PlannedSetting item) => Padding(
              padding: AppSpacing.only(bottom: AppSpacing.s12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: AppComponentSizes.iconBadge,
                    height: AppComponentSizes.iconBadge,
                    decoration: BoxDecoration(
                      color: appColors.brandPrimarySoft,
                      borderRadius: AppRadii.avatarRadius,
                    ),
                    child: Icon(
                      item.icon,
                      size: 18,
                      color: appColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.title,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: appColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          item.description,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: appColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlannedSetting {
  final IconData icon;
  final String title;
  final String description;

  const _PlannedSetting({
    required this.icon,
    required this.title,
    required this.description,
  });
}
