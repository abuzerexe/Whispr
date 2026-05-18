import 'package:flutter/material.dart';

import '../constants/topics_constants.dart';
import '../models/topic.dart';

class TopicSelector extends StatefulWidget {
  const TopicSelector({
    super.key,
    this.initialTopic,
    required this.onTopicSelected,
    this.showContinueButton = true,
    this.continueLabel = 'Continue',
  });

  final Topic? initialTopic;
  final ValueChanged<Topic> onTopicSelected;
  final bool showContinueButton;
  final String continueLabel;

  @override
  State<TopicSelector> createState() => _TopicSelectorState();
}

class _TopicSelectorState extends State<TopicSelector> {
  Topic? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialTopic;
  }

  void _select(Topic topic) {
    setState(() => _selected = topic);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final topics = kTopicList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            'Choose a topic',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Pick the topic that best fits your story. This helps others find support.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.82,
            ),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              final isSelected = _selected?.id == topic.id;
              return _TopicCard(
                topic: topic,
                isSelected: isSelected,
                onTap: () => _select(topic),
              );
            },
          ),
        ),
        if (widget.showContinueButton)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton(
              onPressed: _selected == null
                  ? null
                  : () => widget.onTopicSelected(_selected!),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(widget.continueLabel),
            ),
          ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.isSelected,
    required this.onTap,
  });

  final Topic topic;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Material(
      color: scheme.surface,
      elevation: isSelected ? 2 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? scheme.primary : scheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(topic.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Text(
                  topic.label,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    height: 1.15,
                    color: isSelected
                        ? scheme.primary
                        : scheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
