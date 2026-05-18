import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/experience.dart';
import '../models/topic.dart';
import '../services/firestore_service.dart';
import '../services/moderation_result.dart';
import '../services/openai_moderation_service.dart';
import '../widgets/app_surface_card.dart';
import '../widgets/topic_badge.dart';
import '../widgets/topic_selector.dart';

const int _maxTitleLength = 120;
const int _maxBodyLength = 2000;

enum _ComposeStep { topicSelect, form }

String? titleValidationError(String text) {
  final t = text.trim();
  if (t.isEmpty) return AppStrings.validationTitleEmpty;
  if (t.length > _maxTitleLength) {
    return AppStrings.validationTitleTooLong(_maxTitleLength);
  }
  return null;
}

String? bodyValidationError(String text) {
  final t = text.trim();
  if (t.isEmpty) return AppStrings.validationBodyEmpty;
  if (t.length > _maxBodyLength) {
    return AppStrings.validationBodyTooLong(_maxBodyLength);
  }
  return null;
}

bool isValidTitle(String text) => titleValidationError(text) == null;
bool isValidBody(String text) => bodyValidationError(text) == null;
bool isValidCompose(String title, String body) =>
    isValidTitle(title) && isValidBody(body);

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({
    super.key,
    required this.ownerUserId,
    required this.authorHandle,
    this.onLogout,
  });

  final String ownerUserId;
  final String authorHandle;
  final VoidCallback? onLogout;

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _moderationService = OpenAiModerationService();

  _ComposeStep _step = _ComposeStep.topicSelect;
  Topic? _selectedTopic;
  String? _titleError;
  String? _bodyError;
  bool _submitting = false;
  bool _moderating = false;

  @override
  void dispose() {
    _moderationService.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _goToForm(Topic topic) {
    setState(() {
      _selectedTopic = topic;
      _step = _ComposeStep.form;
    });
  }

  void _changeTopic() {
    setState(() => _step = _ComposeStep.topicSelect);
  }

  Future<void> _showContentViolationDialog(ModerationResult result) async {
    final violations = result.violations.isEmpty
        ? ''
        : '\n\nIssues found: ${result.violations.join(', ')}';
    final reason =
        result.reason.isEmpty ? '' : '\n\n${result.reason}';

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Post Not Allowed'),
        content: Text(
          'Your post couldn\'t be submitted because it may violate our '
          'community guidelines.$violations$reason\n\n'
          'Please revise your post and try again.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Edit Post'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTopicMismatchDialog(ModerationResult result) async {
    final topicName = _selectedTopic?.label ?? 'selected topic';
    final reason =
        result.reason.isEmpty ? '' : '\n\n${result.reason}';
    final details = <String>[];
    if (!result.titleMatchesTopic) {
      details.add('• Title does not match "$topicName"');
    }
    if (!result.bodyMatchesTopic) {
      details.add('• Story body does not match "$topicName"');
    }
    final detailText =
        details.isEmpty ? '' : '\n\n${details.join('\n')}';

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Topic Mismatch'),
        content: Text(
          'Your post was not approved. The title and story must both '
          'clearly relate to "$topicName".$detailText$reason\n\n'
          'Please revise your title and story, or choose a different topic.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _changeTopic();
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedTopic == null) return;

    final titleErr = titleValidationError(_titleController.text);
    final bodyErr = bodyValidationError(_bodyController.text);
    if (titleErr != null || bodyErr != null) {
      setState(() {
        _titleError = titleErr;
        _bodyError = bodyErr;
      });
      return;
    }

    setState(() {
      _submitting = true;
      _moderating = true;
    });

    try {
      final moderation = await _moderationService.moderatePost(
        topicId: _selectedTopic!.id,
        topicLabel: _selectedTopic!.label,
        postTitle: _titleController.text.trim(),
        postContent: _bodyController.text.trim(),
      );

      if (!mounted) return;

      if (moderation.moderationUnavailable) {
        setState(() {
          _submitting = false;
          _moderating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(moderation.reason)),
        );
        return;
      }

      if (!moderation.contentSafe) {
        setState(() {
          _submitting = false;
          _moderating = false;
        });
        await _showContentViolationDialog(moderation);
        return;
      }

      if (!moderation.isApproved) {
        setState(() {
          _submitting = false;
          _moderating = false;
        });
        await _showTopicMismatchDialog(moderation);
        return;
      }

      await FirestoreService.instance.addExperience(
        Experience(
          id: '',
          ownerUserId: widget.ownerUserId,
          authorHandle: widget.authorHandle,
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          createdAt: DateTime.now(),
          topicId: _selectedTopic!.id,
          topicLabel: _selectedTopic!.label,
          topicEmoji: _selectedTopic!.emoji,
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _moderating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to share. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == _ComposeStep.topicSelect) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Choose a topic'),
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
          child: TopicSelector(
            initialTopic: _selectedTopic,
            continueLabel: 'Next',
            onTopicSelected: _goToForm,
          ),
        ),
      );
    }

    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final titleRemaining = _maxTitleLength - _titleController.text.length;
    final bodyRemaining = _maxBodyLength - _bodyController.text.length;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final busy = _submitting || _moderating;

    final previewExperience = Experience(
      id: '',
      ownerUserId: widget.ownerUserId,
      authorHandle: widget.authorHandle,
      title: '',
      body: '',
      createdAt: DateTime.now(),
      topicId: _selectedTopic!.id,
      topicLabel: _selectedTopic!.label,
      topicEmoji: _selectedTopic!.emoji,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.composeAppBarTitle),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  TopicBadge(
                    experience: previewExperience,
                    onTap: busy ? null : _changeTopic,
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: busy ? null : _changeTopic,
                    child: const Text('Change topic'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppSurfaceCard(
                padding: const EdgeInsets.all(16),
                elevation: 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined,
                        color: scheme.primary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.composePrivacyNotice,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('compose_title_field'),
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                enabled: !busy,
                decoration: InputDecoration(
                  hintText: AppStrings.composeTitleHint,
                  errorText: _titleError,
                ),
                onChanged: (_) {
                  setState(() {
                    if (_titleError != null) {
                      _titleError =
                          titleValidationError(_titleController.text);
                    }
                  });
                },
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.composeTitleCharactersLeft(
                  titleRemaining.clamp(0, _maxTitleLength),
                  _maxTitleLength,
                ),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: TextField(
                  key: const Key('compose_body_field'),
                  controller: _bodyController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !busy,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    hintText: AppStrings.composeBodyHint,
                    errorText: _bodyError,
                  ),
                  onChanged: (_) {
                    setState(() {
                      if (_bodyError != null) {
                        _bodyError =
                            bodyValidationError(_bodyController.text);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.composeBodyCharactersLeft(
                  bodyRemaining.clamp(0, _maxBodyLength),
                  _maxBodyLength,
                ),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
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
                      'Reviewing your post...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy
                          ? null
                          : () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(AppStrings.composeCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: (!busy &&
                              _selectedTopic != null &&
                              isValidCompose(
                                _titleController.text,
                                _bodyController.text,
                              ))
                          ? _submit
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _submitting && !_moderating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(AppStrings.composeShare),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
