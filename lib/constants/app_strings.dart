abstract final class AppStrings {
  AppStrings._();

  static const String appTitle = 'Anonymous experiences';

  static const String splashTagline = 'Share experiences. Stay anonymous.';

  static const String homeAppBarTitle = appTitle;

  static const String shareFabTooltip = 'Share an experience';

  static const String navFeedLabel = 'Home';

  static const String navMyPostsLabel = 'My posts';

  static const String navProfileLabel = 'Profile';

  static const String feedEmptyTitle = 'No stories yet';

  static const String feedEmptyBody =
      'Tap the button to share a past experience anonymously. '
      'Nothing is saved once you close the app.';

  static const String feedEmptyMyPostsTitle = 'No posts from this session';

  static const String feedEmptyMyPostsBody =
      'During this session your posts share one anonymous label. '
      'Add a story from the Home tab to see it listed here.';

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

  static const String authLoginTab = 'Login';
  static const String authSignupTab = 'Sign up';
  static const String authUsernameHint = 'Username';
  static const String authLoginIdentifierHint = 'Username or email';
  static const String authEmailHint = 'Email';
  static const String authPasswordHint = 'Password';
  static const String authConfirmPasswordHint = 'Confirm password';
  static const String authLoginButton = 'Log in';
  static const String authSignupButton = 'Create account';
  static const String authSwitchToSignup = 'No account yet? Sign up';
  static const String authSwitchToLogin = 'Already have an account? Log in';
  static const String authLogoutTooltip = 'Log out';
  static const String authLoggedOut = 'Logged out.';
  static const String authLoginFailed =
      'Invalid username, email, or password.';
  static const String authValidationUsername = 'Enter a username.';
  static const String authValidationLoginIdentifier =
      'Enter your username or email.';
  static const String authValidationEmail = 'Enter an email.';
  static const String authValidationEmailInvalid =
      'Enter a valid email address.';
  static const String authValidationEmailTaken = 'That email is already in use.';
  static const String authValidationPassword = 'Enter a password.';
  static const String authValidationPasswordShort =
      'Password must be at least 4 characters.';
  static const String authValidationPasswordMismatch =
      'Passwords do not match.';
  static const String authValidationUsernameTaken =
      'Username already exists.';
  static String authWelcome(String username) => 'Welcome, $username';

  static const String profileTitle = 'Profile';
  static const String profileAccountSection = 'Account';
  static const String profileDetailsSection = 'Sign-up details (read-only)';
  static const String profileCurrentUsername = 'Username';
  static const String profileReadOnlyEmailLabel = 'Email';
  static const String profileReadOnlyHandleLabel = 'Anonymous name on posts';
  static const String profileReadOnlyNote =
      'Email and anonymous name are set at sign-up and cannot be changed here.';
  static const String profileSaveUsername = 'Save username';
  static const String profileSecuritySection = 'Security';
  static const String profileCurrentPassword = 'Current password';
  static const String profileNewPassword = 'New password';
  static const String profileConfirmNewPassword = 'Confirm new password';
  static const String profileChangePassword = 'Update password';
  static const String profileSaved = 'Saved.';
  static const String profileErrorNotSignedIn = 'Not signed in.';
  static const String profileErrorWrongPassword = 'Current password is incorrect.';
}
