import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/comment.dart';
import '../models/experience.dart';
import '../utils/date_format.dart';
import '../widgets/app_surface_card.dart';

const int _maxCommentLength = 800;

String? _commentValidationError(String text) {
  final t = text.trim();
  if (t.isEmpty) {
    return AppStrings.validationCommentEmpty;
  }
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
    required this.onAddComment,
    this.onLogout,
  });

  final Experience experience;
  final String sessionUserId;
  final String sessionAuthorHandle;
  final void Function(Comment comment) onAddComment;
  final VoidCallback? onLogout;

  @override
  State<ExperienceDetailScreen> createState() => _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState extends State<ExperienceDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  String? _commentError;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _postComment() {
    final err = _commentValidationError(_commentController.text);
    if (err != null) {
      setState(() => _commentError = err);
      return;
    }
    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerUserId: widget.sessionUserId,
      authorHandle: widget.sessionAuthorHandle,
      body: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );
    widget.onAddComment(comment);
    _commentController.clear();
    setState(() {
      _commentError = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.snackCommentPosted)),
    );
  }

  void _deleteOwnComment(Comment c) {
    setState(() {
      widget.experience.comments.removeWhere((x) => x.id == c.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.snackCommentRemoved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final exp = widget.experience;
    final commentCount = exp.comments.length;
    final dateLabel = formatStoryDate(exp.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          exp.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  AppSurfaceCard(
                    padding: const EdgeInsets.fromLTRB(18, 18, 14, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: scheme.primaryContainer,
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
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                dateLabel,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 52, top: 16, right: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exp.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                exp.body,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                  color: scheme.onSurface.withValues(alpha: 0.88),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    '${AppStrings.detailCommentsHeading} '
                    '(${AppStrings.detailCommentCount(commentCount)})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (exp.comments.isEmpty)
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
                    ...exp.comments.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppSurfaceCard(
                          elevation: 1,
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: scheme.secondaryContainer,
                                child: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 16,
                                  color: scheme.onSecondaryContainer,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            c.authorHandle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.labelLarge?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          formatStoryDate(c.createdAt),
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                            height: 1.2,
                                          ),
                                        ),
                                        if (c.ownerUserId == widget.sessionUserId) ...[
                                          const SizedBox(width: 2),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                            tooltip: AppStrings.detailCommentDeleteTooltip,
                                            onPressed: () => _deleteOwnComment(c),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints.tightFor(
                                              width: 32,
                                              height: 32,
                                            ),
                                            style: IconButton.styleFrom(
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              visualDensity: VisualDensity.compact,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      c.body,
                                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
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
              ),
            ),
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
                      decoration: InputDecoration(
                        hintText: AppStrings.detailCommentHint,
                        errorText: _commentError,
                      ),
                      onChanged: (_) {
                        setState(() {
                          if (_commentError != null) {
                            _commentError =
                                _commentValidationError(_commentController.text);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      key: const Key('detail_post_comment'),
                      onPressed: _isValidComment(_commentController.text)
                          ? _postComment
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(AppStrings.detailCommentPost),
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
