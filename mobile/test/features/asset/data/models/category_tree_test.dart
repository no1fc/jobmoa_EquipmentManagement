import 'package:flutter_test/flutter_test.dart';
import 'package:equipment_management/features/asset/data/models/category_tree.dart';

void main() {
  group('CategoryTree', () {
    test('fromJson parses tree with children', () {
      final json = {
        'categoryId': 1,
        'categoryName': 'IT장비',
        'categoryLevel': 1,
        'description': 'IT 관련 장비',
        'children': [
          {
            'categoryId': 2,
            'categoryName': '컴퓨터',
            'categoryLevel': 2,
            'children': [
              {
                'categoryId': 5,
                'categoryName': '노트북',
                'categoryLevel': 3,
                'children': [],
              },
            ],
          },
        ],
      };

      final tree = CategoryTree.fromJson(json);

      expect(tree.categoryId, 1);
      expect(tree.categoryName, 'IT장비');
      expect(tree.categoryLevel, 1);
      expect(tree.description, 'IT 관련 장비');
      expect(tree.children, hasLength(1));
      expect(tree.children[0].categoryName, '컴퓨터');
      expect(tree.children[0].children, hasLength(1));
      expect(tree.children[0].children[0].categoryName, '노트북');
      expect(tree.children[0].children[0].children, isEmpty);
    });

    test('fromJson handles null children', () {
      final json = {
        'categoryId': 10,
        'categoryName': '소모품',
        'categoryLevel': 3,
      };

      final tree = CategoryTree.fromJson(json);
      expect(tree.children, isEmpty);
      expect(tree.description, isNull);
    });
  });
}
