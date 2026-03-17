import 'package:app_gore_callao/config/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppShadows {
  static List<BoxShadow> subtle(BuildContext context) => <BoxShadow>[
    BoxShadow(
      color: context.appColors.shadowSoft,
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> card(BuildContext context) => <BoxShadow>[
    BoxShadow(
      color: context.appColors.shadowSoft,
      blurRadius: 14,
      offset: const Offset(0, 5),
    ),
  ];

  static List<BoxShadow> panel(BuildContext context) => <BoxShadow>[
    BoxShadow(
      color: context.appColors.shadowSoft,
      blurRadius: 18,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> hero(BuildContext context) => <BoxShadow>[
    BoxShadow(
      color: context.appColors.shadowMedium,
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> floating(BuildContext context) => <BoxShadow>[
    BoxShadow(
      color: context.appColors.shadowMedium,
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
  ];
}
