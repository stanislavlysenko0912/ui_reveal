import 'package:flutter/material.dart';
import 'package:ui_reveal/ui_reveal.dart';

/// Example page with theme toggle in app bar and static content.
class RealWorldPage extends StatelessWidget {
  const RealWorldPage({
    required this.isDark,
    required this.onToggleTheme,
    super.key,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Example', style: theme.textTheme.headlineMedium),
        actions: [
          Builder(
            builder: (btnContext) {
              return IconButton(
                onPressed: () {
                  btnContext.startReveal(
                    direction: isDark
                        ? RevealDirection.reveal
                        : RevealDirection.conceal,
                    effect: RevealEffects.circular(),
                    onSwitch: () async => onToggleTheme(),
                  );
                },
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          _buildUserProfile(theme, colorScheme),
          const SizedBox(height: 16),
          _buildStatsRow(theme, colorScheme),
          const SizedBox(height: 16),
          _buildRecentActivity(theme, colorScheme),
          const SizedBox(height: 16),
          _buildQuickActions(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildUserProfile(ThemeData theme, ColorScheme colorScheme) {
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.person_rounded,
                size: 28,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alex Morgan', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    'Flutter Developer · San Francisco',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        _buildStatCard(theme, colorScheme, Icons.star_rounded, '4.9', 'Rating'),
        const SizedBox(width: 12),
        _buildStatCard(
          theme,
          colorScheme,
          Icons.code_rounded,
          '128',
          'Projects',
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          theme,
          colorScheme,
          Icons.people_rounded,
          '1.2k',
          'Followers',
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    String value,
    String label,
  ) {
    return Expanded(
      child: Card.filled(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: colorScheme.primary, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(ThemeData theme, ColorScheme colorScheme) {
    const activities = <(IconData, String, String)>[
      (Icons.commit_rounded, 'Pushed 3 commits', '2 hours ago'),
      (Icons.merge_rounded, 'Merged pull request #42', '5 hours ago'),
      (Icons.bug_report_rounded, 'Closed issue #17', 'Yesterday'),
      (Icons.rocket_launch_rounded, 'Released v2.1.0', '3 days ago'),
    ];

    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Activity', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ...activities.map(
              (a) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        a.$1,
                        size: 18,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.$2, style: theme.textTheme.bodyMedium),
                          Text(
                            a.$3,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme, ColorScheme colorScheme) {
    const actions = <(IconData, String, Color?)>[
      (Icons.add_circle_outline_rounded, 'New Project', null),
      (Icons.upload_file_rounded, 'Import', null),
      (Icons.share_rounded, 'Share Profile', null),
      (Icons.settings_rounded, 'Settings', null),
    ];

    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Actions', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: actions.map((a) {
                return Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(a.$1, size: 20, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(a.$2, style: theme.textTheme.labelLarge),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
