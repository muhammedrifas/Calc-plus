import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class MatchFixture {
  final int matchNumber;
  final String poolName;
  final String teamA;
  final String teamB;

  const MatchFixture({
    required this.matchNumber,
    required this.poolName,
    required this.teamA,
    required this.teamB,
  });
}

class TournamentPool {
  final String id;
  final String name;
  final List<String> teams;
  final int matchesPerTeam;

  const TournamentPool({
    required this.id,
    required this.name,
    required this.teams,
    this.matchesPerTeam = 3,
  });

  TournamentPool copyWith({
    String? name,
    List<String>? teams,
    int? matchesPerTeam,
  }) {
    return TournamentPool(
      id: id,
      name: name ?? this.name,
      teams: teams ?? this.teams,
      matchesPerTeam: matchesPerTeam ?? this.matchesPerTeam,
    );
  }
}

class RoundRobinState {
  final List<TournamentPool> pools;
  final bool randomizeOrder;
  final List<MatchFixture> generatedSchedule;

  const RoundRobinState({
    required this.pools,
    this.randomizeOrder = true,
    this.generatedSchedule = const [],
  });

  RoundRobinState copyWith({
    List<TournamentPool>? pools,
    bool? randomizeOrder,
    List<MatchFixture>? generatedSchedule,
  }) {
    return RoundRobinState(
      pools: pools ?? this.pools,
      randomizeOrder: randomizeOrder ?? this.randomizeOrder,
      generatedSchedule: generatedSchedule ?? this.generatedSchedule,
    );
  }
}

final roundRobinProvider =
    StateNotifierProvider.autoDispose<RoundRobinNotifier, RoundRobinState>((ref) {
  return RoundRobinNotifier();
});

class RoundRobinNotifier extends StateNotifier<RoundRobinState> {
  RoundRobinNotifier()
      : super(
          const RoundRobinState(
            pools: [
              TournamentPool(
                id: 'pool_a',
                name: 'Pool A',
                teams: ['Team A', 'Team B', 'Team C'],
                matchesPerTeam: 2,
              ),
            ],
          ),
        );

  void addPool() {
    final poolLetter = String.fromCharCode(65 + state.pools.length);
    final newPool = TournamentPool(
      id: 'pool_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Pool $poolLetter',
      teams: [],
      matchesPerTeam: 1,
    );
    state = state.copyWith(pools: [...state.pools, newPool]);
  }

  void removePool(String poolId) {
    if (state.pools.isEmpty) return;
    state = state.copyWith(
      pools: state.pools.where((p) => p.id != poolId).toList(),
    );
  }

  void addTeam(String poolId, String teamName) {
    final trimmed = teamName.trim();
    if (trimmed.isEmpty) return;

    final updated = state.pools.map((pool) {
      if (pool.id == poolId) {
        if (pool.teams.contains(trimmed)) return pool;
        return pool.copyWith(teams: [...pool.teams, trimmed]);
      }
      return pool;
    }).toList();

    state = state.copyWith(pools: updated);
  }

  void removeTeam(String poolId, String teamName) {
    final updated = state.pools.map((pool) {
      if (pool.id == poolId) {
        final newTeams = pool.teams.where((t) => t != teamName).toList();
        return pool.copyWith(teams: newTeams);
      }
      return pool;
    }).toList();

    state = state.copyWith(pools: updated);
  }

  void setMatchesPerTeam(String poolId, int count) {
    final updated = state.pools.map((pool) {
      if (pool.id == poolId) {
        return pool.copyWith(matchesPerTeam: max(1, count));
      }
      return pool;
    }).toList();

    state = state.copyWith(pools: updated);
  }

  void toggleRandomize(bool val) {
    state = state.copyWith(randomizeOrder: val);
  }

  void generateSchedule() {
    final allFixtures = <MatchFixture>[];
    final random = Random();

    for (final pool in state.pools) {
      final teams = pool.teams;
      final n = teams.length;
      if (n < 2) continue;

      final targetMatchesPerTeam = pool.matchesPerTeam;
      final singleCycleLimit = n - 1;

      final fullCycles = targetMatchesPerTeam ~/ singleCycleLimit;
      final remainderMatches = targetMatchesPerTeam % singleCycleLimit;

      final List<(String, String)> poolMatches = [];

      // 1. Add complete round-robin cycles
      for (int cycle = 0; cycle < fullCycles; cycle++) {
        final cycleMatches = _generateSingleRoundRobin(teams);
        // Alternate home/away sides on repeated legs
        if (cycle.isOdd) {
          poolMatches.addAll(cycleMatches.map((pair) => (pair.$2, pair.$1)));
        } else {
          poolMatches.addAll(cycleMatches);
        }
      }

      // 2. Add partial regular pairings if remainder > 0
      if (remainderMatches > 0) {
        final partial = _generateKRegularPairings(teams, remainderMatches);
        if (fullCycles.isOdd) {
          poolMatches.addAll(partial.map((pair) => (pair.$2, pair.$1)));
        } else {
          poolMatches.addAll(partial);
        }
      }

      // 3. Shuffle & minimize back-to-back games for any team
      if (state.randomizeOrder) {
        poolMatches.shuffle(random);
        _minimizeBackToBack(poolMatches);
      }

      for (final pair in poolMatches) {
        allFixtures.add(
          MatchFixture(
            matchNumber: allFixtures.length + 1,
            poolName: pool.name,
            teamA: pair.$1,
            teamB: pair.$2,
          ),
        );
      }
    }

    state = state.copyWith(generatedSchedule: allFixtures);
  }

  List<(String, String)> _generateSingleRoundRobin(List<String> teams) {
    final fixtures = <(String, String)>[];
    final n = teams.length;
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        fixtures.add((teams[i], teams[j]));
      }
    }
    return fixtures;
  }

  List<(String, String)> _generateKRegularPairings(List<String> teams, int k) {
    final n = teams.length;
    final Set<String> addedPairs = {};
    final List<(String, String)> fixtures = [];

    void addMatch(int i, int j) {
      final u = min(i, j);
      final v = max(i, j);
      final key = '$u-$v';
      if (!addedPairs.contains(key) && u != v) {
        addedPairs.add(key);
        fixtures.add((teams[u], teams[v]));
      }
    }

    final halfK = k ~/ 2;
    for (int step = 1; step <= halfK; step++) {
      for (int i = 0; i < n; i++) {
        addMatch(i, (i + step) % n);
      }
    }

    if (k % 2 != 0) {
      if (n % 2 == 0) {
        final step = n ~/ 2;
        for (int i = 0; i < n ~/ 2; i++) {
          addMatch(i, i + step);
        }
      } else {
        for (int i = 0; i < n - 1; i += 2) {
          addMatch(i, i + 1);
        }
      }
    }

    return fixtures;
  }

  void _minimizeBackToBack(List<(String, String)> matches) {
    if (matches.length <= 2) return;
    for (int i = 0; i < matches.length - 1; i++) {
      final current = matches[i];
      final next = matches[i + 1];
      if (current.$1 == next.$1 ||
          current.$1 == next.$2 ||
          current.$2 == next.$1 ||
          current.$2 == next.$2) {
        for (int j = i + 2; j < matches.length; j++) {
          final candidate = matches[j];
          if (current.$1 != candidate.$1 &&
              current.$1 != candidate.$2 &&
              current.$2 != candidate.$1 &&
              current.$2 != candidate.$2) {
            final temp = matches[i + 1];
            matches[i + 1] = matches[j];
            matches[j] = temp;
            break;
          }
        }
      }
    }
  }
}