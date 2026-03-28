import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/infrastructure/database/catalog_seed.dart';
import 'package:mobile/infrastructure/database/catalog_seed_types.dart';

void main() {
  group('official catalog seed validation', () {
    test('accepts the bundled catalog seed', () {
      expect(buildOfficialCatalogSeed().hasUsableContent, isTrue);
    });

    test('rejects an empty catalog payload', () {
      const seed = OfficialCatalogSeed(
        version: 'empty',
        generatedAt: '2026-03-28T00:00:00Z',
        resources: [],
        promptDetails: [],
        skillDetails: [],
        mcpDetails: [],
        collections: [],
        collectionItems: [],
      );

      expect(seed.hasUsableContent, isFalse);
    });
  });
}
