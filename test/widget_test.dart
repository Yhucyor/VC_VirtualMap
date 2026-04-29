import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mappingar/app.dart';

void main() {
  testWidgets('login opens open day map home', (tester) async {
    await tester.pumpWidget(const UteNavigationApp());

    expect(find.text('UTE AR Navigation'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('login-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('destination-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('gps-toggle-button')), findsOneWidget);
  });
}
