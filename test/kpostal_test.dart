import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kpostal/kpostal.dart';

void main() {
  Widget createWidgetForTesting({Widget? child}) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('Create Kpostal', (WidgetTester tester) async {
    await tester
        .pumpWidget(createWidgetForTesting(child: KpostalView(title: 'title')));

    final titleFinder = find.text('title');
    expect(titleFinder, findsOneWidget);
  });
}
