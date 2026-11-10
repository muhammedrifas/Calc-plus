import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omni_calc/core/models/calculator_module.dart';
import 'package:omni_calc/core/models/calculator_category.dart';
import 'package:omni_calc/core/theme/app_colors.dart';
import 'package:omni_calc/core/theme/app_theme_extension.dart';
import 'round_robin_provider.dart';

class RoundRobinModule extends CalculatorModule {
  const RoundRobinModule()
      : super(
          id: 'round_robin',
          name: 'Tournament Scheduler',
          description: 'Round-robin tournament fixtures with pools & match limits',
          icon: Icons.sports_cricket_rounded,
          category: CalculatorCategory.everyday,
          primaryColor: AppColors.teal,
        );

  @override
  Widget buildUI(BuildContext context) {
    return const RoundRobinScreen();
  }
}

class RoundRobinScreen extends ConsumerStatefulWidget {
  const RoundRobinScreen({super.key});

  @override
  ConsumerState<RoundRobinScreen> createState() => _RoundRobinScreenState();
}

class _RoundRobinScreenState extends ConsumerState<RoundRobinScreen> {
  final Map<String, TextEditingController> _teamControllers = {};

  @override
  void dispose() {
    for (final c in _teamControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String poolId) {
    return _teamControllers.putIfAbsent(poolId, () => TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roundRobinProvider);
    final notifier = ref.read(roundRobinProvider.notifier);
    final theme = context.omniTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBg,
      appBar: AppBar(
        title: const Text('Tournament Scheduler', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Pools Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tournament Pools (${state.pools.length})',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary),
                ),
                TextButton.icon(
                  onPressed: notifier.addPool,
                  icon: Icon(Icons.add, color: theme.primary, size: 18),
                  label: Text('Add Pool', style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Pool Cards
            ...state.pools.map((pool) => _buildPoolCard(context, pool, notifier)),

            const SizedBox(height: 12),

            // Global Match Order Toggle Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.divider.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shuffle_rounded, color: theme.secondary, size: 20),
                      const SizedBox(width: 10),
                      Text('Randomize Match Order', style: TextStyle(color: theme.textSecondary, fontSize: 14)),
                    ],
                  ),
                  Switch(
                    value: state.randomizeOrder,
                    activeColor: theme.primary,
                    onChanged: notifier.toggleRandomize,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Generate Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.scaffoldBg,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text('Generate Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: () {
                notifier.generateSchedule();
                if (state.generatedSchedule.isNotEmpty) {
                  _showScheduleBottomSheet(context);
                }
              },
            ),

            if (state.generatedSchedule.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fixtures (${state.generatedSchedule.length} Matches)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary),
                  ),
                  TextButton.icon(
                    onPressed: () => _showScheduleBottomSheet(context),
                    icon: Icon(Icons.fullscreen, color: theme.secondary, size: 18),
                    label: Text('Expanded View', style: TextStyle(color: theme.secondary, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...state.generatedSchedule.take(15).map((match) => _buildMatchCard(context, match)),
              if (state.generatedSchedule.length > 15)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Text(
                      '+ ${state.generatedSchedule.length - 15} more matches in Expanded View',
                      style: TextStyle(color: theme.textMuted, fontSize: 12),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPoolCard(BuildContext context, TournamentPool pool, RoundRobinNotifier notifier) {
    final theme = context.omniTheme;
    final controller = _getController(pool.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.divider.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                pool.name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.primary),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: theme.error, size: 20),
                onPressed: () => notifier.removePool(pool.id),
                tooltip: 'Delete Pool',
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Matches per team selector (Uncapped)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Matches per team:', style: TextStyle(color: theme.textSecondary, fontSize: 13)),
                  if (pool.teams.length >= 2 && pool.matchesPerTeam > pool.teams.length - 1)
                    Text(
                      '${(pool.matchesPerTeam / (pool.teams.length - 1)).toStringAsFixed(1)}x round-robin legs',
                      style: TextStyle(color: theme.secondary, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                ],
              ),
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 14),
                      color: theme.textSecondary,
                      onPressed: pool.matchesPerTeam > 1
                          ? () => notifier.setMatchesPerTeam(pool.id, pool.matchesPerTeam - 1)
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        '${pool.matchesPerTeam}',
                        style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 14),
                      color: theme.textSecondary,
                      onPressed: () => notifier.setMatchesPerTeam(pool.id, pool.matchesPerTeam + 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Team tags chip list
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: pool.teams.map((t) {
              return Chip(
                backgroundColor: theme.surface,
                side: BorderSide(color: theme.divider),
                label: Text(t, style: TextStyle(color: theme.textPrimary, fontSize: 13)),
                deleteIcon: const Icon(Icons.close, size: 16),
                deleteIconColor: theme.textMuted,
                onDeleted: () => notifier.removeTeam(pool.id, t),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Add team input
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.divider),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: controller,
                    style: TextStyle(color: theme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter team name...',
                      hintStyle: TextStyle(color: theme.textMuted, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onSubmitted: (val) {
                      notifier.addTeam(pool.id, val);
                      controller.clear();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: theme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: Icon(Icons.add, color: theme.primary, size: 20),
                onPressed: () {
                  notifier.addTeam(pool.id, controller.text);
                  controller.clear();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, MatchFixture match) {
    final theme = context.omniTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.divider.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '#${match.matchNumber}',
              style: TextStyle(color: theme.secondary, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              match.poolName,
              style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              match.teamA,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('vs', style: TextStyle(color: theme.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(
              match.teamB,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showScheduleBottomSheet(BuildContext context) {
    final state = ref.read(roundRobinProvider);
    final theme = context.omniTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: theme.divider, borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Full Fixture Schedule',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textPrimary),
                      ),
                      Text(
                        '${state.generatedSchedule.length} Total Matches',
                        style: TextStyle(color: theme.secondary, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Divider(color: theme.divider, height: 1),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.generatedSchedule.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      return _buildMatchCard(context, state.generatedSchedule[index]);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}