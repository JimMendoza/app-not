import 'package:app_gore_callao/features/tramites/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TramiteCard extends StatelessWidget {
  final Tramite tramite;
  final bool isSeguimientoLoading;
  final VoidCallback onToggleSeguimiento;
  final VoidCallback onOpenHojaRuta;

  const TramiteCard({
    super.key,
    required this.tramite,
    this.isSeguimientoLoading = false,
    required this.onToggleSeguimiento,
    required this.onOpenHojaRuta,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(tramite.estadoActual);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  tramite.codigo.isEmpty ? 'SIN-CODIGO' : tramite.codigo,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF99569E),
                  ),
                ),
              ),
              if (tramite.notificacionesNoLeidas > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF7F7E),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${tramite.notificacionesNoLeidas}',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tramite.titulo,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    tramite.fecha,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tramite.estadoActual,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: tramite.siguiendo
                      ? const Color(0xFF16A34A).withValues(alpha: 0.15)
                      : const Color(0xFF6B7280).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tramite.siguiendo ? 'Siguiendo' : 'No seguido',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: tramite.siguiendo
                        ? const Color(0xFF15803D)
                        : const Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSeguimientoLoading ? null : onToggleSeguimiento,
                  icon: isSeguimientoLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          tramite.siguiendo
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 18,
                        ),
                  label: Text(
                    isSeguimientoLoading
                        ? 'Procesando...'
                        : tramite.siguiendo
                        ? 'Dejar de seguir'
                        : 'Seguir',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onOpenHojaRuta,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF99569E),
                  ),
                  icon: const Icon(Icons.alt_route, size: 18),
                  label: const Text('Hoja de ruta'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String estado) {
    final String normalized = estado.toLowerCase();
    if (normalized.contains('derivad')) {
      return const Color(0xFFF59E0B);
    }
    if (normalized.contains('aprobad') || normalized.contains('atendid')) {
      return const Color(0xFF16A34A);
    }
    if (normalized.contains('rechazad') || normalized.contains('observad')) {
      return const Color(0xFFDC2626);
    }
    return const Color(0xFF4B5563);
  }
}
