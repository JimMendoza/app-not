import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:flutter/material.dart';

class AppSnackBarHelper {
  static void showMessage(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    final AppStateStyle stateStyle = AppStateStyles.resolve(
      context,
      isError ? AppStateTone.danger : AppStateTone.success,
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: context.appColors.onBrand),
        ),
        backgroundColor: stateStyle.foreground,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showError(BuildContext context, Object error) {
    final String message = AppErrorFormatter.readable(error);
    showMessage(context, message, isError: true);
  }
}
