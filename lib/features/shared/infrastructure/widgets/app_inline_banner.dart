import 'package:app_gore_callao/config/config.dart';
import 'package:flutter/material.dart';

enum AppInlineBannerVariant { error, warning, info, success }

class AppInlineBanner extends StatelessWidget {
  final String message;
  final AppInlineBannerVariant variant;
  final VoidCallback? onClose;

  const AppInlineBanner({
    super.key,
    required this.message,
    this.variant = AppInlineBannerVariant.error,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final _BannerTheme bannerTheme = _resolveTheme(context, variant);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bannerTheme.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bannerTheme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(bannerTheme.icon, color: bannerTheme.iconColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: bannerTheme.textColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onClose != null)
            InkWell(
              onTap: onClose,
              child: Icon(Icons.close, size: 16, color: bannerTheme.iconColor),
            ),
        ],
      ),
    );
  }

  _BannerTheme _resolveTheme(
    BuildContext context,
    AppInlineBannerVariant value,
  ) {
    final appColors = context.appColors;

    switch (value) {
      case AppInlineBannerVariant.warning:
        return _BannerTheme(
          backgroundColor: appColors.warningSoft,
          borderColor: appColors.warning.withValues(alpha: 0.45),
          textColor: appColors.warning,
          iconColor: appColors.warning,
          icon: Icons.warning_amber_rounded,
        );
      case AppInlineBannerVariant.info:
        return _BannerTheme(
          backgroundColor: appColors.brandPrimarySoft,
          borderColor: appColors.brandPrimary.withValues(alpha: 0.4),
          textColor: appColors.brandPrimary,
          iconColor: appColors.brandPrimary,
          icon: Icons.info_outline,
        );
      case AppInlineBannerVariant.success:
        return _BannerTheme(
          backgroundColor: appColors.successSoft,
          borderColor: appColors.success.withValues(alpha: 0.45),
          textColor: appColors.success,
          iconColor: appColors.success,
          icon: Icons.check_circle_outline,
        );
      case AppInlineBannerVariant.error:
        return _BannerTheme(
          backgroundColor: appColors.dangerSoft,
          borderColor: appColors.danger.withValues(alpha: 0.45),
          textColor: appColors.danger,
          iconColor: appColors.danger,
          icon: Icons.error_outline,
        );
    }
  }
}

class _BannerTheme {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final IconData icon;

  const _BannerTheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
    required this.icon,
  });
}
