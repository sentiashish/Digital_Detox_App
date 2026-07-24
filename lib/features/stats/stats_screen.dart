import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/app_models.dart';
import '../../core/providers.dart';
import '../../core/widgets/section_card.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final weeklyMinutes = _weeklyTrend(settings.focusedMinutesThisWeek);
    final appMinutes = _appUsageBreakdown(settings);
    final badges = _milestoneBadges(settings.currentStreakDays);

    return CustomScrollView(
      slivers: [
        const SliverAppBar(pinned: true, title: Text('Stats')),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('This week', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text('Your focus trend and saved time stay local to the device.'),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                getTitlesWidget: (value, meta) {
                                  const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                  final index = value.toInt();
                                  if (index < 0 || index >= labels.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(labels[index]),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              barWidth: 4,
                              color: Theme.of(context).colorScheme.primary,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                              ),
                              spots: List.generate(
                                weeklyMinutes.length,
                                (index) => FlSpot(index.toDouble(), weeklyMinutes[index]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SummaryTile(title: 'Saved this week', value: '${settings.timeSavedMinutesThisWeek} min'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryTile(title: 'Sessions', value: '${settings.totalSessionsCompleted}'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SummaryTile(title: 'Current streak', value: '${settings.currentStreakDays} days'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryTile(title: 'Schedules', value: '${settings.scheduledWindows.length}'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Per-app usage', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 240,
                      child: BarChart(
                        BarChartData(
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          alignment: BarChartAlignment.spaceAround,
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= appMinutes.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(appMinutes[index].$1, overflow: TextOverflow.ellipsis),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: [
                            for (var i = 0; i < appMinutes.length; i++)
                              BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: appMinutes[i].$2,
                                    width: 18,
                                    borderRadius: BorderRadius.circular(8),
                                    color: i.isEven ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Milestones', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    if (badges.isEmpty)
                      const Text('Keep going. Your first milestone badge will appear soon.')
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: badges
                            .map(
                              (badge) => Chip(
                                avatar: const Icon(Icons.workspace_premium_rounded, size: 18),
                                label: Text(badge),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  List<double> _weeklyTrend(int focusedMinutesThisWeek) {
    final baseline = [58.0, 62.0, 45.0, 70.0, 84.0, 90.0, 76.0];
    final adjustment = focusedMinutesThisWeek / 40.0;
    return List<double>.generate(baseline.length, (index) => baseline[index] + adjustment);
  }

  List<(String, double)> _appUsageBreakdown(AppSettings settings) {
    final blockedImpact = (settings.blockedApps.length * 18).toDouble();
    final allowedBase = [
      ('WhatsApp', 28.0),
      ('Maps', 12.0),
      ('Email', 15.0),
    ];
    return [
      ('Instagram', 95.0 - blockedImpact),
      ('YouTube', 120.0 - blockedImpact),
      ...allowedBase,
    ].map((entry) => (entry.$1, entry.$2.clamp(0, 180))).toList();
  }

  List<String> _milestoneBadges(int streakDays) {
    final badges = <String>[];
    if (streakDays >= 3) badges.add('3-day streak');
    if (streakDays >= 7) badges.add('7-day streak');
    if (streakDays >= 30) badges.add('30-day streak');
    return badges;
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
