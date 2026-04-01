import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/experience.dart';
import '../widgets/app_surface_card.dart';

const int _maxTitleLength = 120;
const int _maxBodyLength = 2000;

String? titleValidationError(String text) {
  final t = text.trim();
  if (t.isEmpty) {
    return AppStrings.validationTitleEmpty;
  }
  if (t.length > _maxTitleLength) {
    return AppStrings.validationTitleTooLong(_maxTitleLength);
  }
  return null;
}

String? bodyValidationError(String text) {
  final t = text.trim();
  if (t.isEmpty) {
    return AppStrings.validationBodyEmpty;
  }
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
    required this.onAddExperience,
    required this.ownerUserId,
    required this.authorHandle,
    this.onLogout,
  });

  final void Function(Experience experience) onAddExperience;
  final String ownerUserId;
  final String authorHandle;
  final VoidCallback? onLogout;

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String? _titleError;
  String? _bodyError;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submit() {
    final titleErr = titleValidationError(_titleController.text);
    final bodyErr = bodyValidationError(_bodyController.text);
    if (titleErr != null || bodyErr != null) {
      setState(() {
        _titleError = titleErr;
        _bodyError = bodyErr;
      });
      return;
    }

    final experience = Experience(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerUserId: widget.ownerUserId,
      authorHandle: widget.authorHandle,
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      createdAt: DateTime.now(),
    );

    widget.onAddExperience(experience);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final titleRemaining = _maxTitleLength - _titleController.text.length;
    final bodyRemaining = _maxBodyLength - _bodyController.text.length;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

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
              AppSurfaceCard(
                padding: const EdgeInsets.all(16),
                elevation: 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, color: scheme.primary, size: 22),
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
                decoration: InputDecoration(
                  hintText: AppStrings.composeTitleHint,
                  errorText: _titleError,
                ),
                onChanged: (_) {
                  setState(() {
                    if (_titleError != null) {
                      _titleError = titleValidationError(_titleController.text);
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
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    hintText: AppStrings.composeBodyHint,
                    errorText: _bodyError,
                  ),
                  onChanged: (_) {
                    setState(() {
                      if (_bodyError != null) {
                        _bodyError = bodyValidationError(_bodyController.text);
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
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
                      onPressed: isValidCompose(
                        _titleController.text,
                        _bodyController.text,
                      )
                          ? _submit
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(AppStrings.composeShare),
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
