// This is a basic widget test for the current app shell.

import 'package:flutter_test/flutter_test.dart';

import 'package:lockgrid/main.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BlockerzApp());

    expect(find.text('BLOCKERZ'), findsOneWidget);
    expect(find.text('NEW GAME'), findsOneWidget);
  });
}

