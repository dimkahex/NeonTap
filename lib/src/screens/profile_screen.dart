import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../config/online_config.dart';
import '../services/friends_service.dart';
import '../services/leaderboard_service.dart';
import '../l10n_ext/friend_add_error_l10n.dart';
import '../services/player_prefs.dart';
import '../ui/neon_background.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String route = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _addFriend = TextEditingController();
  String? _friendCode;
  bool _loading = true;
  List<_FriendRow> _friends = <_FriendRow>[];

  @override
  void dispose() {
    _name.dispose();
    _addFriend.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final String n = await PlayerPrefs.getDisplayName();
    _name.text = n;
    final String? code = await FriendsService.ensureFriendCode();
    final List<String> uids = await FriendsService.listFriendUids();
    final List<_FriendRow> rows = <_FriendRow>[];
    for (final String uid in uids) {
      final String name = await FriendsService.displayNameForUid(uid);
      rows.add(_FriendRow(uid: uid, displayName: name));
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _friendCode = code;
      _friends = rows;
      _loading = false;
    });
  }

  Future<void> _saveName() async {
    await PlayerPrefs.setDisplayName(_name.text);
    await LeaderboardService.pushDisplayName(await PlayerPrefs.getDisplayName());
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.snackNameSaved)),
    );
  }

  Future<void> _addFriendTap() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final FriendAddError? err = await FriendsService.addFriendByCode(_addFriend.text);
    if (!mounted) {
      return;
    }
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.message(l10n))));
      return;
    }
    _addFriend.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.snackFriendAdded)),
    );
    await _load();
  }

  Future<void> _removeFriend(String uid) async {
    await FriendsService.removeFriend(uid);
    if (!mounted) {
      return;
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.profileOpenSettings,
            onPressed: () => Navigator.of(context).pushNamed(SettingsScreen.route),
          ),
        ],
      ),
      body: NeonBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(18),
                children: <Widget>[
                  Text(
                    l10n.profileNameInTable,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 1.2,
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _name,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: l10n.profileNameHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _saveName,
                    child: Text(l10n.profileSaveName),
                  ),
                  if (!kFirebaseOnlineFeaturesEnabled) ...<Widget>[
                    const SizedBox(height: 16),
                    Text(
                      l10n.profileOfflineFirebaseNote,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                    ),
                  ],
                  const SizedBox(height: 28),
                  if (kFirebaseOnlineFeaturesEnabled) ...<Widget>[
                    Text(
                      l10n.profileYourFriendCode,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            letterSpacing: 1.2,
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: SelectableText(
                            _friendCode ?? '—',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 4,
                                ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Color(0xFF35E6FF)),
                          tooltip: l10n.profileCopyCode,
                          onPressed: _friendCode == null
                              ? null
                              : () {
                                  Clipboard.setData(ClipboardData(text: _friendCode!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.profileCodeCopied)),
                                  );
                                },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.profileFriendCodeHint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      l10n.profileAddFriend,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            letterSpacing: 1.2,
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _addFriend,
                            style: const TextStyle(color: Colors.white),
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: l10n.profileFriendCodeFieldHint,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addFriendTap,
                          child: Text(l10n.profileOk),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      l10n.profileFriends,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            letterSpacing: 1.2,
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (_friends.isEmpty)
                      Text(
                        l10n.profileFriendsEmpty,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54),
                      )
                    else
                      ..._friends.map(
                        (_FriendRow r) => ListTile(
                          title: Text(r.displayName),
                          subtitle: Text(r.uid, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white54),
                            onPressed: () => unawaited(_removeFriend(r.uid)),
                          ),
                        ),
                      ),
                  ] else
                    Text(
                      l10n.profileFirebaseLaterNote,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(l10n.profileBack),
                  ),
                ],
              ),
      ),
    );
  }
}

class _FriendRow {
  _FriendRow({required this.uid, required this.displayName});

  final String uid;
  final String displayName;
}
