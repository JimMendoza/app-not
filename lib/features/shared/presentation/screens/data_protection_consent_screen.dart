import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/shared/presentation/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DataProtectionConsentScreen extends ConsumerStatefulWidget {
  const DataProtectionConsentScreen({super.key});

  @override
  ConsumerState<DataProtectionConsentScreen> createState() =>
      _DataProtectionConsentScreenState();
}

class _DataProtectionConsentScreenState
    extends ConsumerState<DataProtectionConsentScreen> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF808080),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2E8F2),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            size: 32,
                            color: Color(0xFF991B88),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        child: Text(
                          'Proteccion de Datos',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gobierno Regional del Callao informa que datos seran tratados segun Ley N° 29733.',
                        style: GoogleFonts.montserrat(
                          fontSize: 19,
                          color: const Color(0xFF1F2937),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Tratamiento:',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _Bullet(text: 'Datos para seguimiento de tramites'),
                            _Bullet(text: 'Notificaciones push en tiempo real'),
                            _Bullet(text: 'Informacion confidencial protegida'),
                            _Bullet(text: 'Derecho a rectificar o cancelar'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : _onAccept,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF991B88),
                            disabledBackgroundColor: const Color(0xFF991B88)
                                .withValues(alpha: 0.6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Acepto',
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
      ),
    );
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
}

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '•',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: const Color(0xFF1F2937),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
