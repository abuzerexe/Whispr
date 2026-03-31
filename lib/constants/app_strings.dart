/// User-visible strings for the anonymous experiences app.
abstract final class AppStrings {
  AppStrings._();

  static const String appTitle = 'Anonymous experiences';

  static const String homeAppBarTitle = appTitle;

  static const String shareFabTooltip = 'Share an experience';

  static const String feedEmptyTitle = 'No stories yet';

  static const String feedEmptyBody =
      'Tap the button to share a past experience anonymously. '
      'Nothing is saved once you close the app.';

  static const String composeAppBarTitle = 'Share anonymously';

  static const String composePrivacyNotice =
      'Your name stays hidden. Only a random label is shown with your story.';

  static const String composeHint = 'Write about a past experience…';

  static const String composeCancel = 'Cancel';

  static const String composeShare = 'Share';

  static const String validationEmpty = 'Please write something before sharing.';

  static String validationTooLong(int maxChars) =>
      'Story is too long (max $maxChars characters).';

  static String composeCharactersLeft(int remaining, int maxChars) =>
      '$remaining characters left (max $maxChars)';
}
