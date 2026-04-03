import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/stats_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'All Time',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2,
                children: [
                  _MetricCard(
                    title: 'Completed',
                    value: '${stats.totalCompleted}',
                    color: colorScheme.primary,
                  ),
                  _MetricCard(
                    title: 'Active',
                    value: '${stats.totalActive}',
                    color: colorScheme.outline,
                  ),
                  _MetricCard(
                    title: 'Streak',
                    value: '${stats.currentStreak} days',
                    color: colorScheme.secondary,
                  ),
                  _MetricCard(
                    title: 'Completion',
                    value: '${(stats.completionRate * 100).toStringAsFixed(0)}%',
                    color: colorScheme.tertiary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Completed Tasks – Last 7 Days',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _WeeklyChart(stats: stats, colorScheme: colorScheme),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'By Priority',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _PriorityBreakdown(stats: stats, colorScheme: colorScheme),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Completion Rate',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 240,
                    child: _CompletionChart(stats: stats, colorScheme: colorScheme),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Insights',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _InsightsList(stats: stats, colorScheme: colorScheme),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({
    required this.stats,
    required this.colorScheme,
  });

  final StatsData stats;
  final ColorScheme colorScheme;

  /// Build day-of-week abbreviations anchored to today so the labels
  /// always match the actual dates behind each bar.
  /// last7DayCounts[0] = 6 days ago, last7DayCounts[6] = today.
  List<String> _buildDayLabels() {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();
    return List.generate(7, (i) {
      final date = today.subtract(Duration(days: 6 - i));
      return names[date.weekday - 1]; // weekday: 1=Mon … 7=Sun
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildDayLabels();
    final counts = stats.last7DayCounts;
    final maxY = (counts.isEmpty ? 1 : counts.reduce((a, b) => a > b ? a : b)) + 1;

    return BarChart(
      BarChartData(
        maxY: maxY.toDouble(),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(days[index], style: const TextStyle(fontSize: 10)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          counts.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: counts[index].toDouble(),
                color: colorScheme.primary,
                width: 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletionChart extends StatelessWidget {
  const _CompletionChart({
    required this.stats,
    required this.colorScheme,
  });

  final StatsData stats;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final completed = stats.totalCompleted;
    final remaining = stats.totalActive;
    final total = completed + remaining;

    if (total == 0) {
      return Center(
        child: Text('No tasks yet', style: Theme.of(context).textTheme.bodySmall),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: completed.toDouble(),
                  color: colorScheme.primary,
                  radius: 56,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: remaining.toDouble(),
                  color: colorScheme.surfaceContainerHighest,
                  radius: 56,
                  showTitle: false,
                ),
              ],
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${(stats.completionRate * 100).toStringAsFixed(1)}%',
          style: Theme.of(context)
              .textTheme
              .displaySmall
              ?.copyWith(color: colorScheme.primary),
        ),
        const SizedBox(height: 4),
        Text(
          '$completed of $total tasks completed',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _PriorityBreakdown extends StatelessWidget {
  const _PriorityBreakdown({
    required this.stats,
    required this.colorScheme,
  });

  final StatsData stats;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final priorities = [
      ('High', stats.byPriority['high'] ?? 0, colorScheme.error),
      ('Medium', stats.byPriority['medium'] ?? 0, colorScheme.tertiaryContainer),
      ('Low', stats.byPriority['low'] ?? 0, colorScheme.secondaryContainer),
    ];

    final total =
        stats.byPriority.values.fold<int>(0, (acc, v) => acc + v);

    return Column(
      children: [
        for (final (label, count, color) in priorities) ...[
          Row(
            children: [
              // Colored dot
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              // Fixed-width label so the bar starts at a consistent offset
              SizedBox(
                width: 60,
                child: Text(label, style: Theme.of(context).textTheme.bodySmall),
              ),
              const SizedBox(width: 8),
              // Progress bar stretches to fill remaining Row space
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : count / total,
                    minHeight: 8,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Right-aligned count
              SizedBox(
                width: 28,
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _InsightsList extends StatelessWidget {
  const _InsightsList({
    required this.stats,
    required this.colorScheme,
  });

  final StatsData stats;
  final ColorScheme colorScheme;

  List<({IconData icon, String text})> _generateInsights() {
    final insights = <({IconData icon, String text})>[];

    insights.add((
      icon: Icons.check_circle_outline,
      text: 'You\'ve completed ${stats.totalCompleted} tasks total',
    ));

    if (stats.currentStreak > 0) {
      insights.add((
        icon: Icons.local_fire_department,
        text: 'Current streak: ${stats.currentStreak} day${stats.currentStreak == 1 ? '' : 's'}. Keep it up!',
      ));
    }

    if (stats.overdueCount > 0) {
      insights.add((
        icon: Icons.warning_outlined,
        text: '${stats.overdueCount} task${stats.overdueCount == 1 ? '' : 's'} overdue — let\'s clear them!',
      ));
    } else if (stats.totalActive > 0) {
      insights.add((
        icon: Icons.thumb_up_outlined,
        text: 'No overdue tasks. You\'re on track!',
      ));
    }

    if (stats.completionRate > 0.8) {
      insights.add((
        icon: Icons.star_outline,
        text:
            'Great work! ${(stats.completionRate * 100).toStringAsFixed(0)}% completion rate.',
      ));
    }

    return insights;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final insight in _generateInsights())
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(insight.icon, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        insight.text,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
