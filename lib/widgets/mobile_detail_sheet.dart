import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import 'credential_detail.dart';

/// Bottom sheet that hosts [CredentialDetail] on narrow layouts.
class MobileDetailSheet extends StatelessWidget {
  const MobileDetailSheet({
    super.key,
    required this.credential,
    required this.onClose,
  });

  final Credential credential;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: AppColors.border),
              left: BorderSide(color: AppColors.border),
              right: BorderSide(color: AppColors.border),
            ),
          ),
          child: CredentialDetail(
            credential: credential,
            onClose: onClose,
            scrollController: controller,
          ),
        );
      },
    );
  }
}
