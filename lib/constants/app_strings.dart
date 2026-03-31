/// User-visible strings for the anonymous experiences app.
abstract final class AppStrings {
  AppStrings._();

  static const String appTitle = 'Anonymous experiences';

  static const String splashTagline =
      'Share experiences. Stay anonymous. All local—nothing is saved after you close the app.';

  static const String homeAppBarTitle = appTitle;

  static const String shareFabTooltip = 'Share an experience';

  static const String navFeedLabel = 'Feed';

  static const String navMyPostsLabel = 'My posts';

  static const String feedEmptyTitle = 'No stories yet';

  static const String feedEmptyBody =
      'Tap the button to share a past experience anonymously. '
      'Nothing is saved once you close the app.';

  static const String feedEmptyMyPostsTitle = 'No posts from this session';

  static const String feedEmptyMyPostsBody =
      'During this session your posts share one anonymous label. '
      'Add a story from the Feed tab to see it listed here.';

  static const String composeAppBarTitle = 'Share anonymously';

  static const String composePrivacyNotice =
      'Your name stays hidden. Only a random label is shown with your story.';

  static const String composeTitleHint = 'Short title for your experience';

  static const String composeBodyHint = 'What happened? Share the details…';

  static const String composeCancel = 'Cancel';

  static const String composeShare = 'Share';

  static const String validationTitleEmpty = 'Please add a title.';

  static const String validationBodyEmpty = 'Please write the story.';

  static String validationTitleTooLong(int maxChars) =>
      'Title is too long (max $maxChars characters).';

  static String validationBodyTooLong(int maxChars) =>
      'Story is too long (max $maxChars characters).';

  static String composeTitleCharactersLeft(int remaining, int maxChars) =>
      'Title: $remaining characters left (max $maxChars)';

  static String composeBodyCharactersLeft(int remaining, int maxChars) =>
      'Story: $remaining characters left (max $maxChars)';

  static const String detailCommentsHeading = 'Comments';

  static const String detailNoComments = 'No comments yet. Add one below.';

  static const String detailCommentHint = 'Write a comment…';

  static const String detailCommentPost = 'Post';

  static const String detailCommentDeleteTooltip = 'Delete your comment';

  static const String validationCommentEmpty = 'Please write a comment.';

  static String validationCommentTooLong(int maxChars) =>
      'Comment is too long (max $maxChars characters).';

  static String detailCommentCount(int n) => '$n comment${n == 1 ? '' : 's'}';

  static const String searchHint = 'Search titles and stories…';

  static const String feedSearchEmptyTitle = 'No matches';

  static const String feedSearchEmptyBody =
      'Try different words or clear the search box.';

  static const String sortNewestTooltip = 'Sort: newest first';

  static const String sortOldestTooltip = 'Sort: oldest first';

  static const String snackStoryShared = 'Story shared.';

  static const String snackStoryRemoved = 'Story removed from this device.';

  static const String snackCommentPosted = 'Comment posted.';

  static const String snackCommentRemoved = 'Comment removed.';
}
