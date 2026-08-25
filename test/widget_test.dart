import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foodgo/models/food_item.dart';
import 'package:foodgo/widgets/food_card.dart';

void main() {
  testWidgets('FoodCard displays name and price', (WidgetTester tester) async {
    final item = FoodItem(
      id: 1,
      name: 'Test Burger',
      description: 'A test burger',
      price: 9.99,
      categoryId: 1,
      image: '🍔',
      isVeg: false,
      rating: 4.5,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FoodCard(foodItem: item, onTap: () {}),
        ),
      ),
    );

    expect(find.text('Test Burger'), findsOneWidget);
    expect(find.text('\$9.99'), findsOneWidget);
  });
}
