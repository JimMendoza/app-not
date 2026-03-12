import 'app_failure.dart';

class AppErrorFormatter {
  static String readable(
    Object error, {
    String fallbackMessage = 'Ocurrio un error inesperado.',
  }) {
    if (error is AppFailure) {
      final String message = error.message.trim();
      return message.isEmpty ? fallbackMessage : message;
    }

    final String rawMessage = error.toString().trim();
    if (rawMessage.isEmpty) {
      return fallbackMessage;
    }

    final String cleanMessage = rawMessage
        .replaceFirst(RegExp(r'^(Exception|CustomError|AppFailure):\s*'), '')
        .replaceFirst(RegExp(r'^Error:\s*'), '')
        .trim();

    return cleanMessage.isEmpty ? fallbackMessage : cleanMessage;
  }
}
