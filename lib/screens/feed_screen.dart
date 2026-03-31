import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/experience.dart';
import '../utils/date_format.dart' show formatFeedTimestamp;
import '../widgets/experience_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({
    super.key,
    required this.experiences,
    required this.sessionAuthorHandle,
    this.onExperienceTap,
    this.onDismissOwnExperience,
    this.showMyPostsEmptyMessage = false,
    this.showNoSearchResults = false,
  });

  final List<Experience> experiences;
  final String sessionAuthorHandle;
  final void Function(Experience experience)? onExperienceTap;
  final void Function(Experience experience)? onDismissOwnExperience;
  final bool showMyPostsEmptyMessage;
  final bool showNoSearchResults;

  @override
  Widget build(BuildContext context) {
    if (experiences.isEmpty) {
      if (showNoSearchResults) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_outlined,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.feedSearchEmptyTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.feedSearchEmptyBody,
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
        final card = ExperienceCard(
          key: ValueKey<String>('card_${experience.id}'),
          experience: experience,
          subtitle: formatFeedTimestamp(experience.createdAt),
          onTap: onExperienceTap != null
              ? () => onExperienceTap!(experience)
              : null,
        );

        final isOwn = experience.authorHandle == sessionAuthorHandle;
        if (isOwn && onDismissOwnExperience != null) {
          return Dismissible(
            key: ValueKey<String>('dismiss_${experience.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Theme.of(context).colorScheme.errorContainer,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            child: card,
            onDismissed: (_) => onDismissOwnExperience!(experience),
          );
        }

        return card;
      },
    );
  }
}
