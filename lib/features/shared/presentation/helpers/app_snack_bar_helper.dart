import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:flutter/material.dart';

class AppSnackBarHelper {
  static void showMessage(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    final appColors = context.appColors;
    final Color backgroundColor = isError
        ? appColors.danger
        : appColors.success;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: appColors.onBrand)),
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
