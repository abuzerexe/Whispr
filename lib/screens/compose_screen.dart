import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/experience.dart';

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
    required this.authorHandle,
  });

  final void Function(Experience experience) onAddExperience;
  final String authorHandle;

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
      authorHandle: widget.authorHandle,
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      createdAt: DateTime.now(),
    );

    widget.onAddExperience(experience);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final titleRemaining = _maxTitleLength - _titleController.text.length;
    final bodyRemaining = _maxBodyLength - _bodyController.text.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.composeAppBarTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.composePrivacyNotice,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('compose_title_field'),
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: AppStrings.composeTitleHint,
                  border: const OutlineInputBorder(),
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
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
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
                    border: const OutlineInputBorder(),
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
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
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
