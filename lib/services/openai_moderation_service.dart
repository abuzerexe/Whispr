import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/secrets.dart';
import 'moderation_prompts.dart';
import 'moderation_result.dart';

class OpenAiModerationService {
  OpenAiModerationService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const String _endpoint =
      'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o-mini';
  static const int _maxChars = 3000;

  void dispose() => _client.close();

  String _truncate(String text) =>
      text.length <= _maxChars ? text : text.substring(0, _maxChars);

  Future<ModerationResult> moderatePost({
    required String topicId,
    required String topicLabel,
    required String postTitle,
    required String postContent,
  }) {
    final userMessage = '''
TOPIC_ID: $topicId
TOPIC_LABEL: $topicLabel

TITLE:
${_truncate(postTitle.trim())}

BODY:
${_truncate(postContent.trim())}''';

    return _chat(
      system: ModerationPrompts.postSystem,
      user: userMessage,
      forPost: true,
    );
  }

  Future<ModerationResult> moderateComment({
    required String commentContent,
  }) {
    return _chat(
      system: ModerationPrompts.commentSystem,
      user: 'COMMENT:\n${_truncate(commentContent.trim())}',
      forPost: false,
    );
  }

  Future<ModerationResult> _chat({
    required String system,
    required String user,
    required bool forPost,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${Secrets.openAiApiKey}',
            },
            body: jsonEncode({
              'model': _model,
              'temperature': 0,
              'max_tokens': 512,
              'response_format': {'type': 'json_object'},
              'messages': [
                {'role': 'system', 'content': system},
                {'role': 'user', 'content': user},
              ],
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        _log('HTTP ${response.statusCode}: ${response.body}');
        return _unavailable(forPost);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) return _unavailable(forPost);

      final text = (choices.first as Map<String, dynamic>)['message']?['content']
          as String?;
      if (text == null || text.trim().isEmpty) return _unavailable(forPost);

      final json = _parseJson(text);
      if (json == null) {
        _log('Invalid JSON: $text');
        return _unavailable(forPost);
      }

      if (forPost) return ModerationResult.fromJson(json);

      return ModerationResult.fromCommentJson(json);
    } catch (e, st) {
      _log('Error: $e\n$st');
      return _unavailable(forPost);
    }
  }

  Map<String, dynamic>? _parseJson(String text) {
    var s = text.replaceAll(RegExp(r'```json|```'), '').trim();
    try {
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      final a = s.indexOf('{');
      final b = s.lastIndexOf('}');
      if (a < 0 || b <= a) return null;
      try {
        return jsonDecode(s.substring(a, b + 1)) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
  }

  ModerationResult _unavailable(bool forPost) => ModerationResult(
        contentSafe: false,
        titleMatchesTopic: false,
        bodyMatchesTopic: false,
        topicRelevant: false,
        violations: ['Moderation service unavailable'],
        reason: forPost
            ? 'We could not verify your post right now. Please check your connection and try again.'
            : 'We could not verify your comment right now. Please try again.',
        moderationUnavailable: true,
      );

  void _log(String msg) => debugPrint('[OpenAiModeration] $msg');
}
