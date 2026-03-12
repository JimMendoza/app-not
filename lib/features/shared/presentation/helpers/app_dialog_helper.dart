import 'package:flutter/material.dart';

class AppDialogHelper {
  static Future<void> showSessionExpiredDialog(
    BuildContext context, {
    String message = 'Tu sesion expiro. Inicia sesion nuevamente.',
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sesion expirada'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }
}
