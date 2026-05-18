import 'package:flutter/material.dart';

import '../constants/topics_constants.dart';
import '../models/topic.dart';

class TopicFilterBar extends StatelessWidget {
  const TopicFilterBar({
    super.key,
    required this.selectedTopicId,
    required this.onTopicSelected,
  });

  /// `null` means "All".
  final String? selectedTopicId;
  final ValueChanged<String?> onTopicSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final topics = kTopicList;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _FilterChip(
            label: 'All',
            emoji: null,
            isSelected: selectedTopicId == null,
            onTap: () => onTopicSelected(null),
            scheme: scheme,
          ),
          ...topics.map(
            (Topic topic) => _FilterChip(
              label: topic.label,
              emoji: topic.emoji,
              isSelected: selectedTopicId == topic.id,
              onTap: () => onTopicSelected(topic.id),
              scheme: scheme,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
    required this.scheme,
  });

  final String label;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final display = emoji != null ? '$emoji $label' : label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? scheme.primary : scheme.surface,
        elevation: isSelected ? 1 : 0,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected ? scheme.primary : scheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(
                display,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? scheme.onPrimary
                          : scheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
