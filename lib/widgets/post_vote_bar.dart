import 'package:flutter/material.dart';

import '../constants/app_strings.dart';

/// Upvote / downvote controls with separate positive counts (not net score).
class PostVoteBar extends StatelessWidget {
  const PostVoteBar({
    super.key,
    required this.upvoteCount,
    required this.downvoteCount,
    required this.userVote,
    required this.onUpvote,
    required this.onDownvote,
    this.compact = false,
    this.enabled = true,
  });

  final int upvoteCount;
  final int downvoteCount;
  final int? userVote;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final bool compact;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final upSelected = userVote == 1;
    final downSelected = userVote == -1;

    final upColor = upSelected ? scheme.primary : scheme.onSurfaceVariant;
    final downColor =
        downSelected ? scheme.error : scheme.onSurfaceVariant;

    final countStyle = (compact
            ? theme.textTheme.labelLarge
            : theme.textTheme.titleSmall)
        ?.copyWith(fontWeight: FontWeight.w800, height: 1);

    final iconSize = compact ? 22.0 : 26.0;

    Widget voteIcon({
      required IconData icon,
      required bool selected,
      required Color color,
      required String tooltip,
      required VoidCallback onPressed,
    }) {
      return IconButton(
        onPressed: enabled ? onPressed : null,
        tooltip: tooltip,
        icon: Icon(icon, size: iconSize, color: color),
        style: IconButton.styleFrom(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: selected
              ? color.withValues(alpha: 0.12)
              : Colors.transparent,
        ),
      );
    }

    Widget countLabel(int count, Color color) {
      return Padding(
        padding: EdgeInsets.only(
          left: compact ? 0 : 2,
          right: compact ? 10 : 14,
        ),
        child: Text(
          _formatCount(count),
          style: countStyle?.copyWith(color: color),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        voteIcon(
          icon: Icons.arrow_upward_rounded,
          selected: upSelected,
          color: upColor,
          tooltip: AppStrings.voteUpTooltip,
          onPressed: onUpvote,
        ),
        countLabel(upvoteCount, upColor),
        voteIcon(
          icon: Icons.arrow_downward_rounded,
          selected: downSelected,
          color: downColor,
          tooltip: AppStrings.voteDownTooltip,
          onPressed: onDownvote,
        ),
        countLabel(downvoteCount, downColor),
      ],
    );
  }

  static String _formatCount(int count) {
    if (count < 1000) return '$count';
    if (count < 10000) {
      return '${(count / 100).truncate() / 10}k';
    }
    if (count < 1000000) {
      return '${(count / 1000).truncate()}k';
    }
    return '${(count / 100000).truncate() / 10}M';
  }
}
