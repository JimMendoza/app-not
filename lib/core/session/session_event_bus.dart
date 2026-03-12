import 'package:flutter_riverpod/legacy.dart';

enum SessionEventType { sessionExpired }

class SessionEvent {
  final SessionEventType type;
  final String message;

  const SessionEvent({required this.type, required this.message});

  const SessionEvent.sessionExpired({
    this.message = 'Tu sesion expiro. Inicia sesion nuevamente.',
  }) : type = SessionEventType.sessionExpired;
}

final StateProvider<SessionEvent?> sessionEventProvider =
    StateProvider<SessionEvent?>((ref) => null);
