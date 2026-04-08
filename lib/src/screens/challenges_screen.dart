import 'dart:async' show unawaited;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../config/online_config.dart';
import '../models/challenge.dart';
import '../services/challenge_service.dart';
import '../l10n_ext/challenge_display_name.dart';
import '../l10n_ext/challenge_duration_l10n.dart';
import '../services/friends_service.dart';
import '../ui/neon_background.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  static const String route = '/challenges';

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  String? _lastIncomingNotifiedId;

  void _openCreateChallenge() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const _CreateChallengeSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.challengesTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.challengesNewTooltip,
            onPressed: kFirebaseOnlineFeaturesEnabled ? _openCreateChallenge : null,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: kFirebaseOnlineFeaturesEnabled ? _openCreateChallenge : null,
        icon: const Icon(Icons.add),
        label: Text(l10n.challengesMakeChallenge),
      ),
      body: NeonBackground(
        child: !kFirebaseOnlineFeaturesEnabled
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.challengesFirebaseDisabled,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                ),
              )
            : StreamBuilder<List<Challenge>>(
                stream: ChallengeService.watchMyChallenges(),
                builder: (BuildContext context, AsyncSnapshot<List<Challenge>> snap) {
                  final List<Challenge> all = snap.data ?? <Challenge>[];

                  // In-app notification: first unseen incoming pending challenge.
                  final String? myUid = FirebaseAuth.instance.currentUser?.uid;
                  if (myUid != null) {
                    final Challenge? incoming = all.where((c) => c.status == ChallengeStatus.pending && c.toUid == myUid).isEmpty
                        ? null
                        : all.firstWhere((c) => c.status == ChallengeStatus.pending && c.toUid == myUid);
                    if (incoming != null && incoming.id != _lastIncomingNotifiedId) {
                      _lastIncomingNotifiedId = incoming.id;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.snackIncomingChallenge(challengePersonName(l10n, incoming.fromName)))),
                        );
                      });
                    }
                  }

                  final Widget makeChallenge = Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _openCreateChallenge,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.challengesMakeChallenge),
                      ),
                    ),
                  );

                  final Widget header = Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (snap.connectionState == ConnectionState.waiting)
                          const LinearProgressIndicator(minHeight: 2),
                        const SizedBox(height: 12),
                        Text(
                          l10n.versusHeadline,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.versusBody,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                height: 1.35,
                              ),
                        ),
                        const SizedBox(height: 12),
                        makeChallenge,
                      ],
                    ),
                  );

                  if (all.isEmpty) {
                    return Column(
                      children: <Widget>[
                        header,
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            l10n.challengesEmpty,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                          ),
                        ),
                        const Spacer(),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    itemCount: all.length + 1,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0x22FFFFFF)),
                    itemBuilder: (BuildContext context, int i) {
                      if (i == 0) return header;
                      return _ChallengeCard(c: all[i - 1]);
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.c});

  final Challenge c;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool over = c.isOver || c.status == ChallengeStatus.completed;
    final String vs = l10n.challengeVersus(
      challengePersonName(l10n, c.fromName),
      challengePersonName(l10n, c.toName),
    );
    final String status = switch (c.status) {
      ChallengeStatus.pending => l10n.challengeStatusPending,
      ChallengeStatus.active => over ? l10n.challengeStatusFinishing : l10n.challengeStatusActive,
      ChallengeStatus.completed => l10n.challengeStatusCompleted,
      ChallengeStatus.declined => l10n.challengeStatusDeclined,
      ChallengeStatus.cancelled => l10n.challengeStatusCancelled,
    };
    final DateTime end = DateTime.fromMillisecondsSinceEpoch(c.endsAtMs);
    final String endLine = l10n.challengeEnds(end.toLocal().toString().split('.').first);

    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    final bool iAmFrom = uid != null && uid == c.fromUid;
    final bool iAmTo = uid != null && uid == c.toUid;
    final bool canArmMyRisk = c.status == ChallengeStatus.active &&
        !over &&
        ((iAmFrom && !c.fromRiskUsed) || (iAmTo && !c.toRiskUsed));

    return Card(
      color: Colors.black.withOpacity(0.25),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    vs,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  status,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: over ? Colors.white54 : const Color(0xFF35E6FF),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              endLine,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: _ScoreMini(
                    name: challengePersonName(l10n, c.fromName),
                    score: c.fromBest,
                    combo: c.fromBestCombo,
                    riskUsed: c.fromRiskUsed,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ScoreMini(
                    name: challengePersonName(l10n, c.toName),
                    score: c.toBest,
                    combo: c.toBestCombo,
                    riskUsed: c.toRiskUsed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: <Widget>[
                if (c.status == ChallengeStatus.pending && iAmTo) ...<Widget>[
                  ElevatedButton(
                    onPressed: () => unawaited(ChallengeService.accept(c.id)),
                    child: Text(l10n.challengeAccept),
                  ),
                  OutlinedButton(
                    onPressed: () => unawaited(ChallengeService.decline(c.id)),
                    child: Text(l10n.challengeDecline),
                  ),
                ],
                if (c.status == ChallengeStatus.pending && iAmFrom)
                  OutlinedButton(
                    onPressed: () => unawaited(ChallengeService.cancel(c.id)),
                    child: Text(l10n.challengeCancel),
                  ),
                if (canArmMyRisk) ...<Widget>[
                  OutlinedButton(
                    onPressed: () => unawaited(ChallengeService.armRisk(c.id, armed: true)),
                    child: Text(l10n.challengeRiskArm),
                  ),
                  OutlinedButton(
                    onPressed: () => unawaited(ChallengeService.armRisk(c.id, armed: false)),
                    child: Text(l10n.challengeRiskDisarm),
                  ),
                ],
              ],
            ),
            Text(
              l10n.challengeRiskHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreMini extends StatelessWidget {
  const _ScoreMini({
    required this.name,
    required this.score,
    required this.combo,
    required this.riskUsed,
  });

  final String name;
  final int score;
  final int combo;
  final bool riskUsed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x22FFFFFF)),
        color: Colors.black.withOpacity(0.18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            score.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: const Color(0xFF35E6FF),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'x$combo  ${riskUsed ? l10n.challengeRiskUsed : l10n.challengeRiskReady}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _CreateChallengeSheet extends StatefulWidget {
  const _CreateChallengeSheet();

  @override
  State<_CreateChallengeSheet> createState() => _CreateChallengeSheetState();
}

class _CreateChallengeSheetState extends State<_CreateChallengeSheet> {
  bool _loadingFriends = true;
  List<_FriendPick> _friends = <_FriendPick>[];
  _FriendPick? _pick;
  ChallengeDuration _dur = ChallengeDuration.hour1;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadFriends());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadFriends() async {
    try {
      final List<String> uids = await FriendsService.listFriendUids();
      final List<_FriendPick> out = <_FriendPick>[];
      for (final String uid in uids) {
        final String name = await FriendsService.displayNameForUid(uid);
        out.add(_FriendPick(uid: uid, displayName: name));
      }
      out.sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
      if (!mounted) return;
      setState(() {
        _friends = out;
        _pick = out.isEmpty ? null : out.first;
        _loadingFriends = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _friends = <_FriendPick>[];
        _pick = null;
        _loadingFriends = false;
      });
    }
  }

  Future<void> _send() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final _FriendPick? pick = _pick;
    if (pick == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.createChallengeNoFriends)));
      return;
    }
    setState(() => _busy = true);
    try {
      final String? id = await ChallengeService.createChallenge(toUid: pick.uid, duration: _dur);
      if (!mounted) return;
      if (id == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.createChallengeFailed)));
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.createChallengeSent)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createChallengeTitle)),
      body: NeonBackground(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: <Widget>[
            Text(
              l10n.createChallengeFriend,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70, letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            if (_loadingFriends)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_friends.isEmpty)
              Text(
                l10n.createChallengeNoFriends,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              )
            else
              DropdownButtonFormField<_FriendPick>(
                value: _pick,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _friends
                    .map(
                      (_FriendPick f) => DropdownMenuItem<_FriendPick>(
                        value: f,
                        child: Text(f.displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (_FriendPick? v) => setState(() => _pick = v),
              ),
            const SizedBox(height: 18),
            Text(
              l10n.createChallengeDuration,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70, letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ChallengeDuration>(
              value: _dur,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: ChallengeDuration.values
                  .map(
                    (ChallengeDuration d) =>
                        DropdownMenuItem<ChallengeDuration>(value: d, child: Text(d.locLabel(l10n))),
                  )
                  .toList(),
              onChanged: (ChallengeDuration? v) {
                if (v == null) return;
                setState(() => _dur = v);
              },
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: (_busy || _loadingFriends || _friends.isEmpty) ? null : _send,
              child: Text(_busy ? l10n.createChallengeBusy : l10n.createChallengeSend),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.createChallengeRuleHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendPick {
  const _FriendPick({required this.uid, required this.displayName});

  final String uid;
  final String displayName;
}

