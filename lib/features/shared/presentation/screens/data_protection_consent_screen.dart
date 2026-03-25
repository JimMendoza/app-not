import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/shared/presentation/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DataProtectionConsentScreen extends ConsumerStatefulWidget {
  final bool readOnly;

  const DataProtectionConsentScreen({super.key, this.readOnly = false});

  @override
  ConsumerState<DataProtectionConsentScreen> createState() =>
      _DataProtectionConsentScreenState();
}

class _DataProtectionConsentScreenState
    extends ConsumerState<DataProtectionConsentScreen> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final Widget content = Scaffold(
      backgroundColor: appColors.pageBackground,
      body: SafeArea(
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
                          Icons.error_outline,
                          size: 32,
                          color: appColors.brandPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    Align(
                      child: Text(
                        'Proteccion de Datos',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: appColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Text(
                      'Gobierno Regional del Callao informa que datos seran tratados segun Ley N° 29733.',
                      style: GoogleFonts.montserrat(
                        fontSize: 19,
                        color: appColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s18),
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
                          Text(
                            'Tratamiento:',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: appColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s8),
                          const _Bullet(
                            text: 'Datos para seguimiento de tramites',
                          ),
                          const _Bullet(
                            text: 'Notificaciones push en tiempo real',
                          ),
                          const _Bullet(
                            text: 'Informacion confidencial protegida',
                          ),
                          const _Bullet(
                            text: 'Derecho a rectificar o cancelar',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isSubmitting
                            ? null
                            : widget.readOnly
                            ? () => _closeReadOnlyView(context)
                            : _onAccept,
                        style: FilledButton.styleFrom(
                          backgroundColor: appColors.brandPrimary,
                          disabledBackgroundColor: appColors.brandPrimary
                              .withValues(alpha: 0.6),
                          padding: AppSpacing.vertical(AppSpacing.s14),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.mediumRadius,
                          ),
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                width: AppComponentSizes.compactLoader,
                                height: AppComponentSizes.compactLoader,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: appColors.onBrand,
                                ),
                              )
                            : Text(
                                widget.readOnly ? 'Cerrar' : 'Acepto',
                                style: GoogleFonts.montserrat(
                                  fontSize: 26,
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
      ),
    );

    if (widget.readOnly) {
      return content;
    }

    return PopScope(canPop: false, child: content);
  }

  Future<void> _onAccept() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(authProvider.notifier).acceptDataPolicy();

      if (!mounted) {
        return;
      }

      context.go('/home');
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackBarHelper.showError(context, error);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _closeReadOnlyView(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/informacion/legal');
  }
}

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet({required this.text});

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
