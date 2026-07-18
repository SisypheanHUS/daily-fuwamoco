import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_ruffian/features/collection/data/collection_item.dart';
import 'package:daily_ruffian/features/collection/data/collection_repository.dart';
import 'package:daily_ruffian/features/collection/logic/collection_providers.dart';

void main() {
  group('isCollectionItemUnlocked', () {
    const milestone = CollectionItem(
      id: 'milestone_7',
      name: 'First Spark',
      group: 'milestones',
      colorKey: 'yellow',
      threshold: 7,
    );

    test('locked below its threshold', () {
      expect(isCollectionItemUnlocked(milestone, 6), isFalse);
    });

    test('unlocked exactly at its threshold', () {
      expect(isCollectionItemUnlocked(milestone, 7), isTrue);
    });

    test('stays unlocked well past its threshold', () {
      expect(isCollectionItemUnlocked(milestone, 200), isTrue);
    });

    test('items with no threshold (seasonal/everyday) never unlock', () {
      const seasonal = CollectionItem(
        id: 'seasonal_spring',
        name: 'Spring Bloom',
        group: 'seasonal',
        colorKey: 'pink',
      );
      expect(isCollectionItemUnlocked(seasonal, 999), isFalse);
    });
  });

  group('CollectionRepository', () {
    testWidgets('loads the bundled manifest with all three groups present',
        (tester) async {
      final items = await const CollectionRepository().loadAll();
      expect(items, isNotEmpty);
      final groups = items.map((i) => i.group).toSet();
      expect(groups, {'milestones', 'seasonal', 'everyday'});
    });

    test('missing asset fails soft to an empty list', () async {
      final items =
          await CollectionRepository(bundle: _EmptyBundle()).loadAll();
      expect(items, isEmpty);
    });
  });
}

class _EmptyBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) => throw Exception('not found');
}
