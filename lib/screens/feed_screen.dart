import 'package:flutter/material.dart';

import '../models/experience.dart';
import '../widgets/experience_card.dart';

String formatStoryDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  final h = local.hour.toString().padLeft(2, '0');
  final min = local.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $h:$min';
}

class FeedScreen extends StatelessWidget {
  const FeedScreen({
    super.key,
    required this.experiences,
  });

  final List<Experience> experiences;

  @override
  Widget build(BuildContext context) {
    if (experiences.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.forum_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'No stories yet',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the button to share a past experience anonymously. '
                'Nothing is saved once you close the app.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 88),
      itemCount: experiences.length,
      itemBuilder: (context, index) {
        final experience = experiences[index];
        return ExperienceCard(
          experience: experience,
          subtitle: formatStoryDate(experience.createdAt),
        );
      },
    );
  }
}
