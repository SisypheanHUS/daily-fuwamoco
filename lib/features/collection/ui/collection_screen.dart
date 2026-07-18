import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/companion_mascot.dart';
import '../../../shared/widgets/fanart_background.dart';
import '../../../shared/widgets/fuwa_card.dart';
import '../../../shared/widgets/glass_surface.dart';
import '../../../shared/widgets/section_label.dart';
import '../../habits/data/habit_colors.dart';
import '../../streak/logic/streak_service.dart';
import '../data/collection_item.dart';
import '../logic/collection_providers.dart';

class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(collectionCatalogProvider);
    final streak = ref.watch(streakProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Collection')),
      body: FanArtBackground(
        assetPath: 'assets/fanart/twins-profile.jpg',
        child: catalog.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const _EmptyState(),
          data: (items) {
            if (items.isEmpty) return const _EmptyState();
            return _CollectionGrid(items: items, streak: streak);
          },
        ),
      ),
    );
  }
}

class _CollectionGrid extends StatelessWidget {
  const _CollectionGrid({required this.items, required this.streak});

  final List<CollectionItem> items;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<CollectionItem>>{};
    for (final item in items) {
      groups.putIfAbsent(item.group, () => []).add(item);
    }
    const order = ['milestones', 'seasonal', 'everyday'];
    const titles = {
      'milestones': 'Milestones',
      'seasonal': 'Seasonal',
      'everyday': 'Everyday',
    };

    return ListView(
      padding: const EdgeInsets.all(Gap.md),
      children: [
        for (final group in order)
          if (groups[group] case final groupItems?) ...[
            SectionLabel(titles[group] ?? group),
            const SizedBox(height: Gap.sm),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: Gap.sm,
              crossAxisSpacing: Gap.sm,
              childAspectRatio: 0.82,
              children: [
                for (final item in groupItems)
                  _CollectionTile(
                    item: item,
                    unlocked: isCollectionItemUnlocked(item, streak),
                  ),
              ],
            ),
            const SizedBox(height: Gap.lg),
          ],
      ],
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({required this.item, required this.unlocked});

  final CollectionItem item;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassSurface(
      radius: Corners.md,
      padding: const EdgeInsets.all(Gap.sm),
      borderColor: unlocked ? AppTheme.yellowDeep : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CompanionMascot(
                size: 44,
                color: unlocked ? habitColor(item.colorKey) : AppTheme.inkFaint,
                animate: false,
              ),
              if (!unlocked)
                Icon(
                  Icons.lock_rounded,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
            ],
          ),
          const SizedBox(height: Gap.xs),
          Text(
            item.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: unlocked ? null : AppTheme.inkFaint,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
        child: FuwaCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CompanionMascot(
                size: 88,
                color: AppTheme.blueDeep,
                sleepy: true,
                animate: false,
              ),
              const SizedBox(height: Gap.md),
              Text(
                'Nothing here yet',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: Gap.sm),
              Text(
                'Keep your streak going — charms will start showing up here.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.inkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
