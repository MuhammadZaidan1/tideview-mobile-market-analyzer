import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideview/shared/widgets/favorite_button.dart';

void main() {
  testWidgets('toggles optimistically and reverts on failed callback', (
    tester,
  ) async {
    final completer = Completer<void>();
    bool? latestValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FavoriteButton(
            initialValue: false,
            successMessage: 'Added to favorites',
            errorMessage: 'Could not update favorites',
            onToggle: (nextValue) async {
              latestValue = nextValue;
              return completer.future;
            },
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);

    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(latestValue, isTrue);

    completer.complete(false);
    await tester.pump();

    expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
  });
}
