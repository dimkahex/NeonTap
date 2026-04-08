import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../models/challenge.dart';
import '../l10n_ext/challenge_duration_l10n.dart';
import '../services/challenge_service.dart';
import '../services/friends_service.dart';
import '../ui/neon_background.dart';

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
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
                  .toList(growable: false),
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

