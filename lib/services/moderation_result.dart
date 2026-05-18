class ModerationResult {
  final bool contentSafe;
  final bool titleMatchesTopic;
  final bool bodyMatchesTopic;
  final bool topicRelevant;
  final List<String> violations;
  final String reason;
  final bool moderationUnavailable;
  final bool? approved;

  ModerationResult({
    required this.contentSafe,
    this.titleMatchesTopic = true,
    this.bodyMatchesTopic = true,
    required this.topicRelevant,
    required this.violations,
    required this.reason,
    this.moderationUnavailable = false,
    this.approved,
  });

  bool get isApproved {
    if (moderationUnavailable) return false;
    if (approved != null) return approved!;
    return contentSafe &&
        titleMatchesTopic &&
        bodyMatchesTopic &&
        topicRelevant;
  }

  factory ModerationResult.fromJson(Map<String, dynamic> json) {
    final titleOk = json['titleMatchesTopic'] as bool? ?? false;
    final bodyOk = json['bodyMatchesTopic'] as bool? ?? false;
    var topicOk = json['topicRelevant'] as bool?;
    topicOk ??= titleOk && bodyOk;

    final safe = json['contentSafe'] as bool? ?? false;
    final explicitApproved = json['approved'] as bool?;

    return ModerationResult(
      contentSafe: safe,
      titleMatchesTopic: titleOk,
      bodyMatchesTopic: bodyOk,
      topicRelevant: topicOk,
      violations: List<String>.from(json['violations'] ?? []),
      reason: json['reason'] as String? ?? '',
      approved: explicitApproved,
    );
  }

  factory ModerationResult.fromCommentJson(Map<String, dynamic> json) {
    final safe = json['contentSafe'] as bool? ?? false;
    final explicitApproved = json['approved'] as bool? ?? safe;

    return ModerationResult(
      contentSafe: safe,
      titleMatchesTopic: true,
      bodyMatchesTopic: true,
      topicRelevant: true,
      violations: List<String>.from(json['violations'] ?? []),
      reason: json['reason'] as String? ?? '',
      approved: explicitApproved,
    );
  }
}
