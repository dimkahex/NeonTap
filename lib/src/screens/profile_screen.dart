import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/online_config.dart';
import '../services/friends_service.dart';
import '../services/leaderboard_service.dart';
import '../services/player_prefs.dart';
import '../ui/neon_background.dart';

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
      const SnackBar(content: Text('Имя сохранено')),
    );
  }

  Future<void> _addFriendTap() async {
    final String? err = await FriendsService.addFriendByCode(_addFriend.text);
    if (!mounted) {
      return;
    }
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    _addFriend.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Друг добавлен')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('ПРОФИЛЬ')),
      body: NeonBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(18),
                children: <Widget>[
                  Text(
                    'ИМЯ В ТАБЛИЦЕ',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 1.2,
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _name,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Как вас видят другие',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _saveName,
                    child: const Text('СОХРАНИТЬ ИМЯ'),
                  ),
                  if (!kFirebaseOnlineFeaturesEnabled) ...<Widget>[
                    const SizedBox(height: 16),
                    Text(
                      'Сейчас всё только на этом устройстве. Облако и общий рейтинг — когда поставите '
                      'kFirebaseOnlineFeaturesEnabled = true и настроите Firebase.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                    ),
                  ],
                  const SizedBox(height: 28),
                  if (kFirebaseOnlineFeaturesEnabled) ...<Widget>[
                    Text(
                      'ВАШ КОД ДРУГА',
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
                          tooltip: 'Копировать',
                          onPressed: _friendCode == null
                              ? null
                              : () {
                                  Clipboard.setData(ClipboardData(text: _friendCode!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Код скопирован')),
                                  );
                                },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Передайте код другу — он введёт его ниже у себя.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'ДОБАВИТЬ ДРУГА',
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
                            decoration: const InputDecoration(
                              hintText: '6-символьный код',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addFriendTap,
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'ДРУЗЬЯ',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            letterSpacing: 1.2,
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (_friends.isEmpty)
                      Text(
                        'Пока никого — добавьте по коду.',
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
                      'Код друга и список друзей появятся после включения Firebase '
                      '(см. lib/src/config/online_config.dart).',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('НАЗАД'),
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
