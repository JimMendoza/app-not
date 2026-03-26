import 'package:app_not/config/config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userEntity;
  final int unreadNotifications;
  final bool unreadNotificationsHasError;
  final VoidCallback onNotificationsClick;
  final VoidCallback? onMenuClick;
  final bool showMenuButton;

  const Header({
    super.key,
    required this.userName,
    required this.userEntity,
    this.unreadNotifications = 0,
    this.unreadNotificationsHasError = false,
    required this.onNotificationsClick,
    this.onMenuClick,
    this.showMenuButton = true,
  });

  @override
  Size get preferredSize =>
      const Size.fromHeight(AppComponentSizes.headerHeight);

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool showUserInfo = screenWidth > 600;
    final bool hideTitle = screenWidth < 420;
    final bool showUnreadBadge =
        unreadNotificationsHasError || unreadNotifications > 0;
    final String unreadLabel = unreadNotificationsHasError
        ? '!'
        : unreadNotifications > 99
        ? '99+'
        : '$unreadNotifications';

    return Container(
      decoration: BoxDecoration(
        color: appColors.brandPrimary,
        boxShadow: AppShadows.subtle(context),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo y título
              Row(
                children: [
                  if (showMenuButton) ...<Widget>[
                    Builder(
                      builder: (BuildContext buttonContext) {
                        return IconButton(
                          onPressed:
                              onMenuClick ??
                              () => Scaffold.of(buttonContext).openDrawer(),
                          tooltip: 'Menu',
                          icon: Icon(
                            Icons.menu,
                            color: appColors.headerOnColor,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: appColors.headerOnColor.withValues(
                              alpha: 0.1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.largeRadius,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  if (!hideTitle) ...<Widget>[
                    const SizedBox(width: AppSpacing.s12),
                    Text(
                      Environment.appName,
                      style: GoogleFonts.montserrat(
                        fontSize: screenWidth > 600 ? 24 : 18,
                        fontWeight: FontWeight.bold,
                        color: appColors.headerOnColor,
                      ),
                    ),
                  ],
                ],
              ),

              // Información del usuario y botones
              Row(
                children: [
                  // Información del usuario (oculto en pantallas pequeñas)
                  if (showUserInfo)
                    Padding(
                      padding: AppSpacing.only(right: AppSpacing.s16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            userName,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: appColors.headerOnColor,
                            ),
                          ),
                          Text(
                            userEntity,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: appColors.headerOnColorMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Botón de notificaciones
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: onNotificationsClick,
                        tooltip: 'Notificaciones',
                        icon: Icon(
                          Icons.notifications,
                          color: appColors.headerOnColor,
                          size: AppComponentSizes.headerActionIcon,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: appColors.headerOnColor.withValues(
                            alpha: 0.1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.largeRadius,
                          ),
                        ),
                      ),
                      if (showUnreadBadge)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: AppSpacing.all(AppSpacing.s4),
                            constraints: const BoxConstraints(
                              minWidth: AppComponentSizes.headerBadgeMin,
                              minHeight: AppComponentSizes.headerBadgeMin,
                            ),
                            decoration: BoxDecoration(
                              color: unreadNotificationsHasError
                                  ? appColors.danger
                                  : appColors.badgeBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                unreadLabel,
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: unreadNotificationsHasError
                                      ? appColors.onBrand
                                      : appColors.badgeForeground,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

