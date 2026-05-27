import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import 'common/env_badge.dart';
import 'common/glow_dot.dart';
import 'common/tag_pill.dart';

class CredentialCard extends StatefulWidget {
  const CredentialCard({
    super.key,
    required this.credential,
    required this.project,
    required this.env,
    required this.selected,
    required this.onTap,
  });

  final Credential credential;
  final Project? project;
  final EnvDef? env;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<CredentialCard> createState() => _CredentialCardState();
}

class _CredentialCardState extends State<CredentialCard> {
  bool _hover = false;

  static const double _railWidth = 6;
  static const double _railWidthSelected = 8;
  static const double _stripeHeight = 4;
  static const double _stripeHeightSelected = 5;
  static const double _radius = 14;

  @override
  Widget build(BuildContext context) {
    final projectColor = widget.project?.color ?? AppColors.accentCyan;
    final envColor = widget.env?.color ?? AppColors.textMuted;
    final railWidth =
        widget.selected ? _railWidthSelected : _railWidth;
    final stripeHeight =
        widget.selected ? _stripeHeightSelected : _stripeHeight;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translateByDouble(0.0, _hover ? -2.0 : 0.0, 0.0, 1.0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: Stack(
              children: [
                _BackgroundTint(
                  projectColor: projectColor,
                  envColor: envColor,
                  hover: _hover,
                ),
                _EnvRail(color: envColor, width: railWidth),
                _ProjectStripe(
                  color: projectColor,
                  railWidth: railWidth,
                  height: stripeHeight,
                ),
                _CornerGem(
                  projectColor: projectColor,
                  envColor: envColor,
                  width: railWidth,
                  height: stripeHeight,
                ),
                _Body(
                  credential: widget.credential,
                  project: widget.project,
                  env: widget.env,
                  projectColor: projectColor,
                  envColor: envColor,
                  hover: _hover,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackgroundTint extends StatelessWidget {
  const _BackgroundTint({
    required this.projectColor,
    required this.envColor,
    required this.hover,
  });
  final Color projectColor;
  final Color envColor;
  final bool hover;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              envColor.withValues(alpha: hover ? 0.08 : 0.04),
              Colors.transparent,
              projectColor.withValues(alpha: hover ? 0.08 : 0.04),
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
      ),
    );
  }
}

class _EnvRail extends StatelessWidget {
  const _EnvRail({required this.color, required this.width});
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: width,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(color: color),
      ),
    );
  }
}

class _ProjectStripe extends StatelessWidget {
  const _ProjectStripe({
    required this.color,
    required this.railWidth,
    required this.height,
  });
  final Color color;
  final double railWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: railWidth,
      right: 0,
      top: 0,
      height: height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(color: color),
      ),
    );
  }
}

class _CornerGem extends StatelessWidget {
  const _CornerGem({
    required this.projectColor,
    required this.envColor,
    required this.width,
    required this.height,
  });
  final Color projectColor;
  final Color envColor;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      width: width,
      height: height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [projectColor, envColor],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.credential,
    required this.project,
    required this.env,
    required this.projectColor,
    required this.envColor,
    required this.hover,
  });

  final Credential credential;
  final Project? project;
  final EnvDef? env;
  final Color projectColor;
  final Color envColor;
  final bool hover;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ProjectChip(color: projectColor, label: project?.name ?? '—'),
              const Spacer(),
              EnvBadge(label: env?.name ?? '—', color: envColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            credential.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if ((credential.username ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              credential.username!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.mono(
                size: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: credential.tags
                      .take(3)
                      .map((t) => TagPill(label: t))
                      .toList(),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()
                  ..translateByDouble(hover ? 3.0 : 0.0, 0.0, 0.0, 1.0),
                child: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: hover
                      ? Color.lerp(projectColor, envColor, 0.5)
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectChip extends StatelessWidget {
  const _ProjectChip({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlowDot(color: color, size: 8, glow: false),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.mono(
                size: 11,
                color: color,
                weight: FontWeight.w700,
              ).copyWith(letterSpacing: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
