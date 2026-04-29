import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mappingar/main.dart';

void main() {
  testWidgets('players can win a caro 3x3 match', (tester) async {
    await tester.pumpWidget(const CaroApp());

    expect(find.text('Luot cua nguoi choi X'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('cell-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cell-3')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cell-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cell-4')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cell-2')));
    await tester.pumpAndSettle();

    expect(find.text('Nguoi choi X thang!'), findsOneWidget);
  });
}
