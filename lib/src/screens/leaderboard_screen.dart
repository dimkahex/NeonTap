import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../config/online_config.dart';
import '../models/leaderboard_entry.dart';
import '../services/friends_service.dart';
import '../services/leaderboard_service.dart';
import '../l10n_ext/leaderboard_name.dart';
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
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.leaderboardTitle),
        bottom: TabBar(
          controller: _tabs,
          tabs: <Widget>[
            Tab(text: l10n.leaderboardGlobalTab),
            Tab(text: l10n.leaderboardFriendsTab),
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
                  l10n.leaderboardOfflineBanner,
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
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (kFirebaseOnlineFeaturesEnabled) {
      return ValueListenableBuilder<String?>(
        valueListenable: LeaderboardService.status,
        builder: (BuildContext context, String? status, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (status != null && status.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Text(
                    l10n.leaderboardOnlineUnavailable(status),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                  ),
                ),
              Expanded(
                child: StreamBuilder<List<LeaderboardEntry>>(
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
                            l10n.leaderboardLoadError,
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
                          l10n.leaderboardEmptyGlobal,
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
                ),
              ),
            ],
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
                    l10n.leaderboardErrorGeneric(snap.error.toString()),
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
                    l10n.leaderboardEmptyLocal,
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
    final AppLocalizations l10n = AppLocalizations.of(context)!;
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
                    l10n.leaderboardErrorGeneric(snap.error.toString()),
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
                    l10n.leaderboardFriendsEmpty,
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
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TextStyle? base = Theme.of(context).textTheme.titleMedium;
    final String display = leaderboardDisplayName(l10n, entry);
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
        '$display${entry.isMe ? l10n.leaderboardYouSuffix : ''}',
        style: base?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        l10n.leaderboardComboLine(entry.bestCombo),
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
