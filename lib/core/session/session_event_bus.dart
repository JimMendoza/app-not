import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SessionEventType { sessionExpired }

class SessionEvent {
  final SessionEventType type;
  final String message;

  const SessionEvent({required this.type, required this.message});

  const SessionEvent.sessionExpired({
    this.message = 'Tu sesion expiro. Inicia sesion nuevamente.',
  }) : type = SessionEventType.sessionExpired;
}

final NotifierProvider<SessionEventNotifier, SessionEvent?>
sessionEventProvider = NotifierProvider<SessionEventNotifier, SessionEvent?>(
  SessionEventNotifier.new,
);

class SessionEventNotifier extends Notifier<SessionEvent?> {
  @override
  SessionEvent? build() => null;

  void clear() {
    state = null;
  }

  void publish(SessionEvent event) {
    state = event;
  }
}
