import 'dart:math';

import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/experience.dart';

const int _maxStoryLength = 2000;

final List<String> _adjectives = [
  'Quiet',
  'Curious',
  'Wandering',
  'Thoughtful',
  'Bold',
  'Gentle',
  'Restless',
  'Sleepy',
  'Hopeful',
  'Lost',
];

final List<String> _nouns = [
  'Traveler',
  'Student',
  'Dreamer',
  'Stranger',
  'Local',
  'NightOwl',
  'EarlyBird',
  'Storyteller',
  'Watcher',
  'Wanderer',
];

bool isValidStory(String text) {
  final t = text.trim();
  return t.isNotEmpty && t.length <= _maxStoryLength;
}

String? storyValidationError(String text) {
  final t = text.trim();
  if (t.isEmpty) {
    return AppStrings.validationEmpty;
  }
  if (t.length > _maxStoryLength) {
    return AppStrings.validationTooLong(_maxStoryLength);
  }
  return null;
}

String generateAnonymousName() {
  final random = Random();
  final a = _adjectives[random.nextInt(_adjectives.length)].trim();
  final n = _nouns[random.nextInt(_nouns.length)];
  final suffix = random.nextInt(900) + 100;
  return 'Anonymous $a$n$suffix';
}

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({
    super.key,
    required this.onAddExperience,
  });

  final void Function(Experience experience) onAddExperience;

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final body = _controller.text;
    final err = storyValidationError(body);
    if (err != null) {
      setState(() => _errorText = err);
      return;
    }

    final experience = Experience(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorHandle: generateAnonymousName(),
      body: body.trim(),
      createdAt: DateTime.now(),
    );

    widget.onAddExperience(experience);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _maxStoryLength - _controller.text.length;

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
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    hintText: AppStrings.composeHint,
                    border: const OutlineInputBorder(),
                    errorText: _errorText,
                  ),
                  onChanged: (_) {
                    if (_errorText != null) {
                      setState(() {
                        _errorText = storyValidationError(_controller.text);
                      });
                    } else {
                      setState(() {});
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.composeCharactersLeft(
                  remaining.clamp(0, _maxStoryLength),
                  _maxStoryLength,
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
                      onPressed: isValidStory(_controller.text) ? _submit : null,
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
