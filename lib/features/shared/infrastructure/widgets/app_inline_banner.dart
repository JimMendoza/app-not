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
    final _BannerTheme bannerTheme = _resolveTheme(variant);

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

  _BannerTheme _resolveTheme(AppInlineBannerVariant value) {
    switch (value) {
      case AppInlineBannerVariant.warning:
        return const _BannerTheme(
          backgroundColor: Color(0xFFFFF8E1),
          borderColor: Color(0xFFFDD835),
          textColor: Color(0xFF7C5A00),
          iconColor: Color(0xFFC49000),
          icon: Icons.warning_amber_rounded,
        );
      case AppInlineBannerVariant.info:
        return const _BannerTheme(
          backgroundColor: Color(0xFFE3F2FD),
          borderColor: Color(0xFF64B5F6),
          textColor: Color(0xFF0D47A1),
          iconColor: Color(0xFF1565C0),
          icon: Icons.info_outline,
        );
      case AppInlineBannerVariant.success:
        return const _BannerTheme(
          backgroundColor: Color(0xFFE8F5E9),
          borderColor: Color(0xFF66BB6A),
          textColor: Color(0xFF1B5E20),
          iconColor: Color(0xFF2E7D32),
          icon: Icons.check_circle_outline,
        );
      case AppInlineBannerVariant.error:
        return const _BannerTheme(
          backgroundColor: Color(0xFFFFEBEE),
          borderColor: Color(0xFFEF9A9A),
          textColor: Color(0xFFB71C1C),
          iconColor: Color(0xFFC62828),
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
