enum ChallengeDuration {
  hour1,
  hour6,
  day1,
}

extension ChallengeDurationUi on ChallengeDuration {
  Duration get duration => switch (this) {
        ChallengeDuration.hour1 => const Duration(hours: 1),
        ChallengeDuration.hour6 => const Duration(hours: 6),
        ChallengeDuration.day1 => const Duration(hours: 24),
      };
}

enum ChallengeStatus {
  pending,
  active,
  completed,
  declined,
  cancelled,
}

class Challenge {
  const Challenge({
    required this.id,
    required this.createdAtMs,
    required this.endsAtMs,
    required this.fromUid,
    required this.toUid,
    required this.fromName,
    required this.toName,
    required this.status,
    required this.fromBest,
    required this.toBest,
    required this.fromBestCombo,
    required this.toBestCombo,
    required this.fromRiskUsed,
    required this.toRiskUsed,
    required this.fromRiskArmed,
    required this.toRiskArmed,
  });

  final String id;
  final int createdAtMs;
  final int endsAtMs;
  final String fromUid;
  final String toUid;
  final String fromName;
  final String toName;
  final ChallengeStatus status;

  /// Best challenge score (may include risk multiplier).
  final int fromBest;
  final int toBest;
  final int fromBestCombo;
  final int toBestCombo;

  /// Risk: one optional boosted attempt per player.
  final bool fromRiskUsed;
  final bool toRiskUsed;
  final bool fromRiskArmed;
  final bool toRiskArmed;

  bool involves(String uid) => fromUid == uid || toUid == uid;

  bool get isOver => DateTime.now().millisecondsSinceEpoch >= endsAtMs;

  Challenge copyWith({
    ChallengeStatus? status,
    int? fromBest,
    int? toBest,
    int? fromBestCombo,
    int? toBestCombo,
    bool? fromRiskUsed,
    bool? toRiskUsed,
    bool? fromRiskArmed,
    bool? toRiskArmed,
    String? fromName,
    String? toName,
  }) {
    return Challenge(
      id: id,
      createdAtMs: createdAtMs,
      endsAtMs: endsAtMs,
      fromUid: fromUid,
      toUid: toUid,
      fromName: fromName ?? this.fromName,
      toName: toName ?? this.toName,
      status: status ?? this.status,
      fromBest: fromBest ?? this.fromBest,
      toBest: toBest ?? this.toBest,
      fromBestCombo: fromBestCombo ?? this.fromBestCombo,
      toBestCombo: toBestCombo ?? this.toBestCombo,
      fromRiskUsed: fromRiskUsed ?? this.fromRiskUsed,
      toRiskUsed: toRiskUsed ?? this.toRiskUsed,
      fromRiskArmed: fromRiskArmed ?? this.fromRiskArmed,
      toRiskArmed: toRiskArmed ?? this.toRiskArmed,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'createdAtMs': createdAtMs,
        'endsAtMs': endsAtMs,
        'fromUid': fromUid,
        'toUid': toUid,
        'fromName': fromName,
        'toName': toName,
        'status': status.name,
        'fromBest': fromBest,
        'toBest': toBest,
        'fromBestCombo': fromBestCombo,
        'toBestCombo': toBestCombo,
        'fromRiskUsed': fromRiskUsed,
        'toRiskUsed': toRiskUsed,
        'fromRiskArmed': fromRiskArmed,
        'toRiskArmed': toRiskArmed,
      };

  static Challenge fromMap(String id, Map<Object?, Object?> raw) {
    final Map<String, Object?> m = raw.map((Object? k, Object? v) => MapEntry(k.toString(), v));
    ChallengeStatus parseStatus(String? s) {
      return switch (s) {
        'pending' => ChallengeStatus.pending,
        'active' => ChallengeStatus.active,
        'completed' => ChallengeStatus.completed,
        'declined' => ChallengeStatus.declined,
        'cancelled' => ChallengeStatus.cancelled,
        _ => ChallengeStatus.pending,
      };
    }

    return Challenge(
      id: id,
      createdAtMs: (m['createdAtMs'] as num?)?.toInt() ?? 0,
      endsAtMs: (m['endsAtMs'] as num?)?.toInt() ?? 0,
      fromUid: (m['fromUid'] as String?) ?? '',
      toUid: (m['toUid'] as String?) ?? '',
      fromName: (m['fromName'] as String?) ?? 'Player',
      toName: (m['toName'] as String?) ?? 'Player',
      status: parseStatus(m['status'] as String?),
      fromBest: (m['fromBest'] as num?)?.toInt() ?? 0,
      toBest: (m['toBest'] as num?)?.toInt() ?? 0,
      fromBestCombo: (m['fromBestCombo'] as num?)?.toInt() ?? 1,
      toBestCombo: (m['toBestCombo'] as num?)?.toInt() ?? 1,
      fromRiskUsed: (m['fromRiskUsed'] as bool?) ?? false,
      toRiskUsed: (m['toRiskUsed'] as bool?) ?? false,
      fromRiskArmed: (m['fromRiskArmed'] as bool?) ?? false,
      toRiskArmed: (m['toRiskArmed'] as bool?) ?? false,
    );
  }
}

