import 'package:app_gore_callao/features/notificaciones/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificacionCard extends StatelessWidget {
  final Notificacion notificacion;
  final bool isMarkingAsRead;
  final VoidCallback onMarkAsRead;
  final VoidCallback onOpenTramite;

  const NotificacionCard({
    super.key,
    required this.notificacion,
    this.isMarkingAsRead = false,
    required this.onMarkAsRead,
    required this.onOpenTramite,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notificacion.leida;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFF9F7FB) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? const Color(0xFF99569E).withValues(alpha: 0.4)
              : Colors.transparent,
        ),
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
                  notificacion.titulo.isEmpty
                      ? 'Sin titulo'
                      : notificacion.titulo,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              _TipoBadge(tipo: notificacion.tipo, isUnread: isUnread),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notificacion.mensaje.isEmpty ? 'Sin mensaje' : notificacion.mensaje,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _InfoPill(
                icon: Icons.receipt_long,
                text: notificacion.codigoTramite.isEmpty
                    ? 'Sin codigo'
                    : notificacion.codigoTramite,
              ),
              _InfoPill(
                icon: Icons.schedule,
                text: notificacion.fechaHora.isEmpty
                    ? 'Sin fecha'
                    : notificacion.fechaHora,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isUnread
                      ? const Color(0xFFEF7F7E).withValues(alpha: 0.15)
                      : const Color(0xFF16A34A).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isUnread ? 'No leida' : 'Leida',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isUnread
                        ? const Color(0xFFEF7F7E)
                        : const Color(0xFF15803D),
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
                  onPressed: isUnread && !isMarkingAsRead ? onMarkAsRead : null,
                  icon: isMarkingAsRead
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          isUnread
                              ? Icons.mark_email_read
                              : Icons.check_circle_outline,
                          size: 18,
                        ),
                  label: Text(
                    isMarkingAsRead
                        ? 'Procesando...'
                        : isUnread
                        ? 'Marcar leida'
                        : 'Leida',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onOpenTramite,
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
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipoBadge extends StatelessWidget {
  final String tipo;
  final bool isUnread;

  const _TipoBadge({required this.tipo, required this.isUnread});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isUnread
            ? const Color(0xFF99569E).withValues(alpha: 0.15)
            : Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        tipo.isEmpty ? 'INFO' : tipo,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isUnread ? const Color(0xFF99569E) : const Color(0xFF4B5563),
        ),
      ),
    );
  }
}
