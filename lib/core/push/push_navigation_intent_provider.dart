import 'package:flutter_riverpod/flutter_riverpod.dart';

final NotifierProvider<PushNavigationIntentNotifier, PushNavigationIntent?>
pushNavigationIntentProvider =
    NotifierProvider<PushNavigationIntentNotifier, PushNavigationIntent?>(
      PushNavigationIntentNotifier.new,
    );

class PushNavigationIntentNotifier extends Notifier<PushNavigationIntent?> {
  int _sequence = 0;

  @override
  PushNavigationIntent? build() {
    return null;
  }

  void publish({int? notificationId}) {
    _sequence += 1;
    state = PushNavigationIntent(
      notificationId: notificationId,
      sequence: _sequence,
    );
  }

  void clear() {
    state = null;
  }
}

class PushNavigationIntent {
  final int? notificationId;
  final int sequence;

  const PushNavigationIntent({
    required this.notificationId,
    required this.sequence,
  });
}
