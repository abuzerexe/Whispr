import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/experience.dart';
import '../utils/date_format.dart';
import '../widgets/experience_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({
    super.key,
    required this.experiences,
    this.onExperienceTap,
    this.showMyPostsEmptyMessage = false,
  });

  final List<Experience> experiences;
  final void Function(Experience experience)? onExperienceTap;
  final bool showMyPostsEmptyMessage;

  @override
  Widget build(BuildContext context) {
    if (experiences.isEmpty) {
      final title = showMyPostsEmptyMessage
          ? AppStrings.feedEmptyMyPostsTitle
          : AppStrings.feedEmptyTitle;
      final body = showMyPostsEmptyMessage
          ? AppStrings.feedEmptyMyPostsBody
          : AppStrings.feedEmptyBody;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                showMyPostsEmptyMessage ? Icons.person_outline : Icons.forum_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                body,
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
          onTap: onExperienceTap != null
              ? () => onExperienceTap!(experience)
              : null,
        );
      },
    );
  }
}
