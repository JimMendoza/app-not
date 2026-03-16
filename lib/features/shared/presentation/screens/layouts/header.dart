import 'package:app_gore_callao/config/config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userEntity;
  final int unreadNotifications;
  final VoidCallback onNotificationsClick;
  final VoidCallback? onMenuClick;
  final bool showMenuButton;

  const Header({
    super.key,
    required this.userName,
    required this.userEntity,
    this.unreadNotifications = 0,
    required this.onNotificationsClick,
    this.onMenuClick,
    this.showMenuButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool showUserInfo = screenWidth > 600;
    final bool hideTitle = screenWidth < 420;
    final String unreadLabel = unreadNotifications > 99
        ? '99+'
        : '$unreadNotifications';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            appColors.headerGradientStart,
            appColors.headerGradientEnd,
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: appColors.shadowMedium,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Logo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: appColors.avatarBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/img/isotipo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Texto del título
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!hideTitle)
                        Text(
                          Environment.appName,
                          style: GoogleFonts.montserrat(
                            fontSize: screenWidth > 600 ? 24 : 18,
                            fontWeight: FontWeight.bold,
                            color: appColors.headerOnColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Información del usuario y botones
              Row(
                children: [
                  // Información del usuario (oculto en pantallas pequeñas)
                  if (showUserInfo)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
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
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: appColors.headerOnColor.withValues(
                            alpha: 0.1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      if (unreadNotifications > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            decoration: BoxDecoration(
                              color: appColors.badgeBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                unreadLabel,
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: appColors.badgeForeground,
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
