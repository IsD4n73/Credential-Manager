import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../common/brand_mark.dart';

class SidebarBrand extends StatelessWidget {
  const SidebarBrand({super.key, required this.collapsed});
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 14 : 18),
      child: Row(
        mainAxisAlignment:
            collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          const BrandMark(),
          if (!collapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'sidebarBrand'.tr(),
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  Text(
                    'appTagline'.tr(),
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.mono(
                      size: 10,
                      color: AppColors.textMuted,
                      weight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
