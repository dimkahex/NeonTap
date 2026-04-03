import 'package:flutter/material.dart';

import '../config/online_config.dart';
import '../models/leaderboard_entry.dart';
import '../services/friends_service.dart';
import '../services/leaderboard_service.dart';
import '../ui/neon_background.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  static const String route = '/leaderboard';

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('РЕЙТИНГ'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const <Widget>[
            Tab(text: 'ГЛОБАЛЬНЫЙ'),
            Tab(text: 'ДРУЗЬЯ'),
          ],
        ),
      ),
      body: NeonBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (!kFirebaseOnlineFeaturesEnabled)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'Офлайн: только ваши результаты на устройстве. Общий рейтинг — после Firebase.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                ),
              ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: <Widget>[
                  _GlobalTab(),
                  _FriendsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlobalTab extends StatefulWidget {
  @override
  State<_GlobalTab> createState() => _GlobalTabState();
}

class _GlobalTabState extends State<_GlobalTab> {
  Future<List<LeaderboardEntry>>? _localFuture;

  @override
  void initState() {
    super.initState();
    if (!kFirebaseOnlineFeaturesEnabled) {
      _localFuture = LeaderboardService.loadLocalGlobalLeaderboard();
    }
  }

  void _reloadLocal() {
    setState(() {
      _localFuture = LeaderboardService.loadLocalGlobalLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kFirebaseOnlineFeaturesEnabled) {
      return StreamBuilder<List<LeaderboardEntry>>(
        stream: LeaderboardService.watchGlobalTop(limit: 100),
        builder: (BuildContext context, AsyncSnapshot<List<LeaderboardEntry>> snap) {
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Не удалось загрузить таблицу.\nПроверьте Firebase и правила RTDB.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ),
              ),
            );
          }
          final List<LeaderboardEntry> rows = snap.data ?? <LeaderboardEntry>[];
          if (rows.isEmpty) {
            return Center(
              child: Text(
                'Пока нет записей — сыграйте и улучшите лучший счёт.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0x22FFFFFF)),
            itemBuilder: (BuildContext context, int i) {
              return _Row(rank: i + 1, entry: rows[i]);
            },
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _reloadLocal();
        await _localFuture;
      },
      child: FutureBuilder<List<LeaderboardEntry>>(
        future: _localFuture,
        builder: (BuildContext context, AsyncSnapshot<List<LeaderboardEntry>> snap) {
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Ошибка: ${snap.error}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            );
          }
          final List<LeaderboardEntry> rows = snap.data ?? <LeaderboardEntry>[];
          if (rows.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Сыграйте партию — здесь появится ваш лучший счёт.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                ),
              ],
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0x22FFFFFF)),
            itemBuilder: (BuildContext context, int i) {
              return _Row(rank: i + 1, entry: rows[i]);
            },
          );
        },
      ),
    );
  }
}

class _FriendsTab extends StatefulWidget {
  @override
  State<_FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<_FriendsTab> {
  Future<List<LeaderboardEntry>>? _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = FriendsService.loadFriendsBoard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _reload();
        await _future;
      },
      child: FutureBuilder<List<LeaderboardEntry>>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<List<LeaderboardEntry>> snap) {
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Ошибка: ${snap.error}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            );
          }
          final List<LeaderboardEntry> rows = snap.data ?? <LeaderboardEntry>[];
          if (rows.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Добавьте друзей по коду в Профиле — здесь будут ваши очки и их лучшие результаты.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                ),
              ],
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0x22FFFFFF)),
            itemBuilder: (BuildContext context, int i) {
              return _Row(rank: i + 1, entry: rows[i]);
            },
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.rank, required this.entry});

  final int rank;
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final TextStyle? base = Theme.of(context).textTheme.titleMedium;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: entry.isMe ? const Color(0x4435E6FF) : const Color(0x22FFFFFF),
        child: Text(
          '#$rank',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
        ),
      ),
      title: Text(
        '${entry.displayName}${entry.isMe ? '  (вы)' : ''}',
        style: base?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        'x${entry.bestCombo} комбо',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
      ),
      trailing: Text(
        entry.score.toString(),
        style: base?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: const Color(0xFF35E6FF),
        ),
      ),
    );
  }
}
