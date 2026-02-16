import 'package:flutter/material.dart';

/// Interactive card that triggers a reveal transition.
class DemoActionCard extends StatelessWidget {
  const DemoActionCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.onRun,
    super.key,
  });

  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final void Function(BuildContext triggerContext) onRun;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card.outlined(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onRun(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: badgeTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Builder(
                builder: (btnContext) {
                  return IconButton.filled(
                    onPressed: () => onRun(btnContext),
                    icon: const Icon(Icons.play_arrow_rounded),
                    tooltip: 'Run transition',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
