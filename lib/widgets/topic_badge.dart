import 'package:flutter/material.dart';

import '../models/experience.dart';

class TopicBadge extends StatelessWidget {
  const TopicBadge({
    super.key,
    required this.experience,
    this.compact = false,
    this.onTap,
  });

  final Experience experience;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (!experience.hasTopic) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = '${experience.topicEmoji} ${experience.topicLabel}';

    final chip = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (onTap == null) return chip;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: chip,
      ),
    );
  }
}
