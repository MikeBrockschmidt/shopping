import 'package:flutter_test/flutter_test.dart';
import 'package:drei/src/features/shopping_list/data/shopping_item.dart';

void main() {
  group('ShoppingItem with Image Support', () {
    test('should create shopping item with icon', () {
      const item = ShoppingItem(
        id: 'test-id',
        name: 'Test Item',
        groupId: 'group-1',
        iconName: 'shopping_cart',
        hasCustomImage: false,
      );

      expect(item.iconName, 'shopping_cart');
      expect(item.imageUrl, isNull);
      expect(item.hasCustomImage, false);
    });

    test('should create shopping item with custom image', () {
      const item = ShoppingItem(
        id: 'test-id',
        name: 'Test Item with Image',
        groupId: 'group-1',
        imageUrl: 'https://example.com/image.jpg',
        hasCustomImage: true,
      );

      expect(item.iconName, isNull);
      expect(item.imageUrl, 'https://example.com/image.jpg');
      expect(item.hasCustomImage, true);
    });

    test('should serialize to map correctly with image', () {
      const item = ShoppingItem(
        id: 'test-id',
        name: 'Test Item',
        groupId: 'group-1',
        imageUrl: 'https://example.com/image.jpg',
        hasCustomImage: true,
      );

      final map = item.toMap();

      expect(map['imageUrl'], 'https://example.com/image.jpg');
      expect(map['hasCustomImage'], true);
      expect(map['iconName'], isNull);
    });

    test('should deserialize from map correctly with image', () {
      final map = {
        'name': 'Test Item',
        'isBought': false,
        'groupId': 'group-1',
        'imageUrl': 'https://example.com/image.jpg',
        'hasCustomImage': true,
      };

      final item = ShoppingItem.fromMap(map, 'test-id');

      expect(item.id, 'test-id');
      expect(item.imageUrl, 'https://example.com/image.jpg');
      expect(item.hasCustomImage, true);
      expect(item.iconName, isNull);
    });

    test('should copy with new image values', () {
      const originalItem = ShoppingItem(
        id: 'test-id',
        name: 'Test Item',
        groupId: 'group-1',
        iconName: 'shopping_cart',
        hasCustomImage: false,
      );

      final updatedItem = originalItem.copyWith(
        imageUrl: 'https://example.com/new-image.jpg',
        hasCustomImage: true,
        iconName: null,
      );

      expect(updatedItem.imageUrl, 'https://example.com/new-image.jpg');
      expect(updatedItem.hasCustomImage, true);
      expect(updatedItem.iconName, isNull);
      // Original should remain unchanged
      expect(originalItem.iconName, 'shopping_cart');
      expect(originalItem.hasCustomImage, false);
    });
  });
}