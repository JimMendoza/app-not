import 'package:app_not/config/config.dart';
import 'package:app_not/features/auth/domain/domain.dart';
import 'package:app_not/features/auth/presentation/providers/providers.dart';
import 'package:app_not/features/shared/presentation/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class MyDataScreen extends ConsumerWidget {
  const MyDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState authState = ref.watch(authProvider);
    final AuthNotifier authNotifier = ref.read(authProvider.notifier);
    final appColors = context.appColors;

    Future<void> onPullToRefresh() async {
      if (authState.authStatus == AuthStatus.authenticated) {
        final Object? refreshError = await authNotifier.refreshCurrentUser();
        if (!context.mounted) {
          return;
        }

        if (refreshError != null) {
          AppSnackBarHelper.showError(context, refreshError);
        }
        return;
      }

      await authNotifier.checkAuthStatus();
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onPullToRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.all(AppSpacing.s16),
          children: <Widget>[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppLayout.maxFeatureWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const _PageHeader(title: 'Mis datos'),
                    const SizedBox(height: AppSpacing.s16),
                    if (authState.authStatus == AuthStatus.checking)
                      const _LoadingCard()
                    else if (!authState.isAuthenticated ||
                        authState.user == null)
                      _ErrorCard(
                        message: authState.errorMessage.isEmpty
                            ? 'No se pudo obtener datos del usuario autenticado.'
                            : authState.errorMessage,
                      )
                    else
                      _UserDataContent(
                        user: authState.user!,
                        displayName: authState.displayName,
                        displayEntity: authState.displayEntity,
                        appColors: appColors,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;

  const _PageHeader({required this.title});

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
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: appColors.brandPrimary,
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

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
      child: const Center(
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.s12),
            Text('Cargando datos personales del usuario...'),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

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
          Text(
            'No fue posible cargar los datos del usuario.',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: appColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            message,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: appColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Desliza hacia abajo para reintentar.',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: appColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserDataContent extends StatelessWidget {
  final User user;
  final String displayName;
  final String displayEntity;
  final AppThemeColors appColors;

  const _UserDataContent({
    required this.user,
    required this.displayName,
    required this.displayEntity,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
                displayName.isEmpty ? 'Usuario sin nombre' : displayName,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: appColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                displayEntity.isEmpty ? 'Entidad no disponible' : displayEntity,
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
          title: 'Informacion personal',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _InfoRow(
                label: 'Nombre completo',
                value: displayName.isEmpty ? '-' : displayName,
              ),
              _InfoRow(
                label: 'Usuario',
                value: user.username.isEmpty ? '-' : user.username,
              ),
              _InfoRow(
                label: 'Entidad',
                value: displayEntity.isEmpty ? '-' : displayEntity,
              ),
            ],
          ),
        ),
      ],
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

