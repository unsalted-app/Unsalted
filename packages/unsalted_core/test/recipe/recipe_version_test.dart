import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:unsalted_core/src/recipe/recipe_version.dart';

void main() {
  group('RecipeVersion', () {
    test('Konstruktion als Draft', () {
      final version = RecipeVersion(
        id: 'v1',
        recipeId: 'r1',
        parentVersionId: null,
        versionIndex: 1,
        label: 'mit Vorteig',
        state: VersionState.draft,
        servings: 10,
        bakingLossPercent: Decimal.zero,
        finalWeightOverrideG: null,
        notes: null,
        snapshottedAt: null,
      );

      expect(version.state, VersionState.draft);
      expect(version.versionIndex, 1);
      expect(version.servings, 10);
      expect(version.snapshottedAt, isNull);
    });

    test('Konstruktion als Snapshot mit snapshottedAt', () {
      final snapshottedAt = DateTime.utc(2026, 9, 19, 12);
      final version = RecipeVersion(
        id: 'v2',
        recipeId: 'r1',
        parentVersionId: 'v1',
        versionIndex: 2,
        label: null,
        state: VersionState.snapshot,
        servings: null,
        bakingLossPercent: Decimal.parse('12.5'),
        finalWeightOverrideG: Decimal.parse('900'),
        notes: null,
        snapshottedAt: snapshottedAt,
      );

      expect(version.state, VersionState.snapshot);
      expect(version.snapshottedAt, snapshottedAt);
      expect(version.finalWeightOverrideG, Decimal.parse('900'));
    });

    test('copyWith ändert nur die angegebenen Felder', () {
      final original = RecipeVersion(
        id: 'v1',
        recipeId: 'r1',
        parentVersionId: null,
        versionIndex: 1,
        label: null,
        state: VersionState.draft,
        servings: null,
        bakingLossPercent: Decimal.zero,
        finalWeightOverrideG: null,
        notes: null,
        snapshottedAt: null,
      );

      final updated = original.copyWith(
        state: VersionState.snapshot,
        snapshottedAt: DateTime.utc(2026, 9, 19),
      );

      expect(updated.id, original.id);
      expect(updated.state, VersionState.snapshot);
      expect(updated.snapshottedAt, DateTime.utc(2026, 9, 19));
    });
  });
}