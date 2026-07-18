class CollectionItem {
  const CollectionItem({
    required this.id,
    required this.name,
    required this.group,
    required this.colorKey,
    this.threshold,
  });

  final String id;
  final String name;
  final String group;
  final String colorKey;

  /// Streak length that unlocks this item — only set for `group: "milestones"`.
  /// Other groups have no live unlock rule yet, so they render locked-only.
  final int? threshold;
}
