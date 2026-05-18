import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/comment.dart';
import '../models/experience.dart';
import '../services/firestore_service.dart';
import '../services/openai_moderation_service.dart';
import '../utils/date_format.dart';
import '../widgets/app_surface_card.dart';
import '../widgets/post_vote_bar.dart';
import '../widgets/topic_badge.dart';

const int _maxCommentLength = 800;

String? _commentValidationError(String text) {
  final t = text.trim();
  if (t.isEmpty) return AppStrings.validationCommentEmpty;
  if (t.length > _maxCommentLength) {
    return AppStrings.validationCommentTooLong(_maxCommentLength);
  }
  return null;
}

bool _isValidComment(String text) => _commentValidationError(text) == null;

class ExperienceDetailScreen extends StatefulWidget {
  const ExperienceDetailScreen({
    super.key,
    required this.experience,
    required this.sessionUserId,
    required this.sessionAuthorHandle,
    this.onLogout,
    this.onPostDeleted,
  });

  final Experience experience;
  final String sessionUserId;
  final String sessionAuthorHandle;
  final VoidCallback? onLogout;
  final VoidCallback? onPostDeleted;

  @override
  State<ExperienceDetailScreen> createState() =>
      _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState extends State<ExperienceDetailScreen> {
  final _commentController = TextEditingController();
  final _moderationService = OpenAiModerationService();
  String? _commentError;
  bool _posting = false;
  bool _moderating = false;
  bool _voting = false;

  @override
  void dispose() {
    _moderationService.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    final err = _commentValidationError(_commentController.text);
    if (err != null) {
      setState(() => _commentError = err);
      return;
    }
    setState(() {
      _posting = true;
      _moderating = true;
    });
    try {
      final moderation = await _moderationService.moderateComment(
        commentContent: _commentController.text.trim(),
      );

      if (!mounted) return;

      if (moderation.moderationUnavailable || !moderation.contentSafe) {
        setState(() {
          _posting = false;
          _moderating = false;
        });
        final reason = moderation.reason.isEmpty
            ? 'it may violate community guidelines'
            : moderation.reason;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Comment not posted: $reason. Please revise and try again.',
            ),
          ),
        );
        return;
      }

      await FirestoreService.instance.addComment(
        widget.experience.id,
        Comment(
          id: '',
          ownerUserId: widget.sessionUserId,
          authorHandle: widget.sessionAuthorHandle,
          body: _commentController.text.trim(),
          createdAt: DateTime.now(),
        ),
      );
      if (mounted) {
        _commentController.clear();
        setState(() {
          _commentError = null;
          _posting = false;
          _moderating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.snackCommentPosted)),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _posting = false;
          _moderating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to post comment. Please try again.')),
        );
      }
    }
  }

  bool get _isOwnPost =>
      widget.experience.ownerUserId == widget.sessionUserId;

  Future<void> _confirmDeletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text(
          'This will permanently remove your story and all comments. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await FirestoreService.instance
          .deleteExperience(widget.experience.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onPostDeleted?.call();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not delete post. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _castVote(int direction) async {
    if (_voting) return;
    setState(() => _voting = true);
    try {
      await FirestoreService.instance.voteOnExperience(
        experienceId: widget.experience.id,
        userId: widget.sessionUserId,
        direction: direction,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not register your vote. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _voting = false);
    }
  }

  Future<void> _deleteOwnComment(Comment c) async {
    try {
      await FirestoreService.instance
          .deleteComment(widget.experience.id, c.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.snackCommentRemoved)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not delete comment. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final exp = widget.experience;
    final dateLabel = formatStoryDate(exp.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          exp.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_isOwnPost)
            IconButton(
              tooltip: 'Delete post',
              onPressed: _confirmDeletePost,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          if (widget.onLogout != null)
            IconButton(
              tooltip: AppStrings.authLogoutTooltip,
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StreamBuilder<List<Comment>>(
                stream: FirestoreService.instance
                    .commentsStream(exp.id),
                builder: (context, snapshot) {
                  final comments = snapshot.data ?? [];
                  final commentCount = comments.length;

                  return StreamBuilder<Experience?>(
                    stream: FirestoreService.instance
                        .experienceStream(exp.id),
                    builder: (context, expSnap) {
                      final liveExp = expSnap.data ?? exp;

                      return StreamBuilder<int?>(
                        stream: FirestoreService.instance.userVoteStream(
                          exp.id,
                          widget.sessionUserId,
                        ),
                        builder: (context, voteSnap) {
                          final userVote = voteSnap.data;

                          return ListView(
                            padding: const EdgeInsets.fromLTRB(
                                16, 12, 16, 16),
                            children: [
                              // ── Post card ─────────────────────────
                              AppSurfaceCard(
                        padding:
                            const EdgeInsets.fromLTRB(18, 18, 14, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      scheme.primaryContainer,
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 22,
                                    color: scheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    exp.authorHandle,
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: scheme.surfaceContainerHigh,
                                    borderRadius:
                                        BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    dateLabel,
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 52, top: 16, right: 4),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exp.title,
                                    style: theme
                                        .textTheme.headlineSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  if (exp.hasTopic) ...[
                                    const SizedBox(height: 10),
                                    TopicBadge(experience: exp),
                                  ],
                                  const SizedBox(height: 12),
                                  Text(
                                    liveExp.body,
                                    style: theme.textTheme.bodyLarge
                                        ?.copyWith(
                                      height: 1.5,
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.88),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  PostVoteBar(
                                    upvoteCount: liveExp.upvoteCount,
                                    downvoteCount: liveExp.downvoteCount,
                                    userVote: userVote,
                                    enabled: !_voting,
                                    onUpvote: () => _castVote(1),
                                    onDownvote: () => _castVote(-1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                              const SizedBox(height: 22),

                      // ── Comments heading ───────────────────────────
                      Text(
                        '${AppStrings.detailCommentsHeading} '
                        '(${AppStrings.detailCommentCount(commentCount)})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (snapshot.connectionState ==
                              ConnectionState.waiting &&
                          comments.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (comments.isEmpty)
                        AppSurfaceCard(
                          elevation: 1,
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            AppStrings.detailNoComments,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        )
                      else
                        ...comments.map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AppSurfaceCard(
                              elevation: 1,
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor:
                                        scheme.secondaryContainer,
                                    child: Icon(
                                      Icons
                                          .chat_bubble_outline_rounded,
                                      size: 16,
                                      color:
                                          scheme.onSecondaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .center,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                c.authorHandle,
                                                maxLines: 1,
                                                overflow: TextOverflow
                                                    .ellipsis,
                                                style: theme
                                                    .textTheme
                                                    .labelLarge
                                                    ?.copyWith(
                                                  fontWeight:
                                                      FontWeight.w700,
                                                  height: 1.2,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              formatStoryDate(
                                                  c.createdAt),
                                              style: theme
                                                  .textTheme.labelSmall
                                                  ?.copyWith(
                                                color: scheme
                                                    .onSurfaceVariant,
                                                fontWeight:
                                                    FontWeight.w600,
                                                height: 1.2,
                                              ),
                                            ),
                                            if (c.ownerUserId ==
                                                widget
                                                    .sessionUserId) ...[
                                              const SizedBox(width: 2),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons
                                                      .delete_outline_rounded,
                                                  size: 20,
                                                ),
                                                tooltip: AppStrings
                                                    .detailCommentDeleteTooltip,
                                                onPressed: () =>
                                                    _deleteOwnComment(
                                                        c),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints
                                                        .tightFor(
                                                  width: 32,
                                                  height: 32,
                                                ),
                                                style:
                                                    IconButton.styleFrom(
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  visualDensity:
                                                      VisualDensity
                                                          .compact,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          c.body,
                                          style: theme
                                              .textTheme.bodyMedium
                                              ?.copyWith(height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // ── Comment input bar ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: AppSurfaceCard(
                elevation: 2,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      key: const Key('detail_comment_field'),
                      controller: _commentController,
                      maxLines: 3,
                      minLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      enabled: !_posting && !_moderating,
                      decoration: InputDecoration(
                        hintText: AppStrings.detailCommentHint,
                        errorText: _commentError,
                      ),
                      onChanged: (_) {
                        setState(() {
                          if (_commentError != null) {
                            _commentError = _commentValidationError(
                                _commentController.text);
                          }
                        });
                      },
                    ),
                    if (_moderating) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Reviewing your comment...',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    FilledButton(
                      key: const Key('detail_post_comment'),
                      onPressed: (!_posting &&
                              !_moderating &&
                              _isValidComment(_commentController.text))
                          ? _postComment
                          : null,
                      style: FilledButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _posting && !_moderating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(AppStrings.detailCommentPost),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
