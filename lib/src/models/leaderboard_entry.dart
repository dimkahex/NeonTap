/// One row in `leaderboard/global/{uid}`.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.score,
    required this.bestCombo,
    this.isMe = false,
  });

  final String uid;
  final String displayName;
  final int score;
  final int bestCombo;
  final bool isMe;

  static LeaderboardEntry fromSnapshotMap(String uid, Map<Object?, Object?> raw) {
    final Map<String, Object?> m = raw.map((Object? k, Object? v) => MapEntry(k.toString(), v));
    return LeaderboardEntry(
      uid: uid,
      displayName: (m['displayName'] as String?)?.trim().isNotEmpty == true
          ? (m['displayName'] as String).trim()
          : 'Player',
      score: (m['score'] as num?)?.toInt() ?? 0,
      bestCombo: (m['bestCombo'] as num?)?.toInt() ?? 1,
    );
  }

  LeaderboardEntry copyWith({bool? isMe}) {
    return LeaderboardEntry(
      uid: uid,
      displayName: displayName,
      score: score,
      bestCombo: bestCombo,
      isMe: isMe ?? this.isMe,
    );
  }
}
