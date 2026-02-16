import 'package:flutter/material.dart';

import '../demo_data.dart';

/// Preview section that switches between list and grid layouts.
class PreviewPanel extends StatelessWidget {
  const PreviewPanel({required this.isGridLayout, super.key});

  final bool isGridLayout;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      child: isGridLayout ? const _GridPreview() : const _ListPreview(),
    );
  }
}

class _ListPreview extends StatelessWidget {
  const _ListPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      key: const ValueKey<String>('list-preview'),
      children: List.generate(mockContacts.length, (index) {
        final contact = mockContacts[index];
        return Card.outlined(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                contact.initials,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            title: Text(
              contact.name,
              style: TextStyle(color: colorScheme.onSurface),
            ),
            subtitle: Text(
              contact.role,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }),
    );
  }
}

class _GridPreview extends StatelessWidget {
  const _GridPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return GridView.builder(
      key: const ValueKey<String>('grid-preview'),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: mockGridItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final item = mockGridItems[index];
        return Card.filled(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    size: 22,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                const Spacer(),
                Text(
                  item.value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
