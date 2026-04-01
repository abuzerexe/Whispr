import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/comment.dart';
import '../models/experience.dart';
import '../utils/date_format.dart';

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
    final exp = widget.experience;
    final commentCount = exp.comments.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          exp.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          if (widget.onLogout != null)
            IconButton(
              tooltip: AppStrings.authLogoutTooltip,
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          exp.authorHandle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        formatStoryDate(exp.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    exp.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    exp.body,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Divider(color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 8),
                  Text(
                    '${AppStrings.detailCommentsHeading} '
                    '(${AppStrings.detailCommentCount(commentCount)})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (exp.comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        AppStrings.detailNoComments,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    ...exp.comments.map(
                      (c) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      c.authorHandle,
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    formatStoryDate(c.createdAt),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (c.ownerUserId == widget.sessionUserId)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      tooltip: AppStrings.detailCommentDeleteTooltip,
                                      onPressed: () => _deleteOwnComment(c),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(c.body, style: theme.textTheme.bodyMedium),
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
                      border: const OutlineInputBorder(),
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
                  const SizedBox(height: 8),
                  FilledButton(
                    key: const Key('detail_post_comment'),
                    onPressed: _isValidComment(_commentController.text)
                        ? _postComment
                        : null,
                    child: Text(AppStrings.detailCommentPost),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
