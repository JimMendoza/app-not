import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:flutter/material.dart';

class AppSnackBarHelper {
  static void showMessage(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    final Color backgroundColor =
        isError ? const Color(0xFFB71C1C) : const Color(0xFF1B5E20);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showError(BuildContext context, Object error) {
    final String message = AppErrorFormatter.readable(error);
    showMessage(context, message, isError: true);
  }
}
