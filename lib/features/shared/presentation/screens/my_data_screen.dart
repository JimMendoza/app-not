import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class MyDataScreen extends ConsumerWidget {
  const MyDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState authState = ref.watch(authProvider);
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
                _PageHeader(title: 'Mis datos', onBack: () => _goBack(context)),
                const SizedBox(height: AppSpacing.s16),
                Container(
                  padding: AppSpacing.all(AppSpacing.s20),
                  decoration: BoxDecoration(
                    color: appColors.surfacePrimary,
                    borderRadius: AppRadii.cardRadius,
                    boxShadow: AppShadows.panel(context),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: AppComponentSizes.profileAvatar,
                        height: AppComponentSizes.profileAvatar,
                        decoration: BoxDecoration(
                          color: appColors.brandPrimarySoft,
                          borderRadius: AppRadii.avatarRadius,
                        ),
                        child: Icon(
                          Icons.person_outline,
                          size: 34,
                          color: appColors.brandPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        authState.displayName.isEmpty
                            ? 'Usuario sin nombre'
                            : authState.displayName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        authState.displayEntity.isEmpty
                            ? 'Entidad no disponible'
                            : authState.displayEntity,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                _InfoCard(
                  title: 'Informacion de acceso',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _InfoRow(
                        label: 'Nombre completo',
                        value: authState.displayName,
                      ),
                      _InfoRow(
                        label: 'Usuario',
                        value: authState.user?.username ?? '-',
                      ),
                      _InfoRow(
                        label: 'Entidad seleccionada',
                        value: authState.displayEntity.isEmpty
                            ? '-'
                            : authState.displayEntity,
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

class _PageHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _PageHeader({required this.title, required this.onBack});

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
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      padding: AppSpacing.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: appColors.surfacePrimary,
        borderRadius: AppRadii.cardRadius,
        boxShadow: AppShadows.card(context),
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
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: AppSpacing.only(bottom: AppSpacing.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: appColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              color: appColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
