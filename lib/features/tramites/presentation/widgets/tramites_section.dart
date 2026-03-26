import 'package:app_not/config/config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TramitesSection extends StatelessWidget {
  final String storageId;
  final String title;
  final int count;
  final String emptyMessage;
  final List<Widget> children;
  final bool initiallyExpanded;
  final IconData icon;

  const TramitesSection({
    super.key,
    required this.storageId,
    required this.title,
    required this.count,
    required this.emptyMessage,
    required this.children,
    required this.icon,
    this.initiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final AppStateStyle countStyle = AppStateStyles.resolve(
      context,
      count > 0 ? AppStateTone.accent : AppStateTone.neutral,
    );

    return Container(
      decoration: BoxDecoration(
        color: appColors.surfacePrimary,
        borderRadius: AppRadii.cardRadius,
        boxShadow: AppShadows.card(context),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: appColors.transparent),
        child: ExpansionTile(
          key: PageStorageKey<String>('tramites_section_$storageId'),
          initiallyExpanded: initiallyExpanded,
          maintainState: true,
          tilePadding: AppSpacing.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s6,
          ),
          childrenPadding: AppSpacing.fromLTRB(
            AppSpacing.s16,
            0,
            AppSpacing.s16,
            AppSpacing.s16,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: AppRadii.cardRadius,
          ),
          iconColor: appColors.brandPrimary,
          collapsedIconColor: appColors.textSecondary,
          leading: Container(
            width: AppComponentSizes.iconBadge,
            height: AppComponentSizes.iconBadge,
            decoration: BoxDecoration(
              color: appColors.brandPrimarySoft,
              borderRadius: AppRadii.avatarRadius,
            ),
            child: Icon(icon, size: 20, color: appColors.brandPrimary),
          ),
          title: Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: appColors.textPrimary,
            ),
          ),
          subtitle: Text(
            count == 1 ? '1 tramite' : '$count tramites',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: appColors.textSecondary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: AppSpacing.symmetric(
                  horizontal: AppSpacing.s10,
                  vertical: AppSpacing.s4,
                ),
                decoration: BoxDecoration(
                  color: countStyle.background,
                  borderRadius: AppRadii.pillRadius,
                  border: Border.all(color: countStyle.border),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: countStyle.foreground,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              const Icon(Icons.expand_more_rounded),
            ],
          ),
          children: <Widget>[
            if (children.isEmpty)
              Container(
                width: double.infinity,
                padding: AppSpacing.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: appColors.surfaceSecondary,
                  borderRadius: AppRadii.mediumRadius,
                ),
                child: Text(
                  emptyMessage,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: appColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              )
            else
              ..._separateChildren(children),
          ],
        ),
      ),
    );
  }

  List<Widget> _separateChildren(List<Widget> children) {
    final List<Widget> result = <Widget>[];

    for (int index = 0; index < children.length; index++) {
      result.add(children[index]);
      if (index < children.length - 1) {
        result.add(const SizedBox(height: AppSpacing.s12));
      }
    }

    return result;
  }
}

