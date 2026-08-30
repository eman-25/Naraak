// This is a basic Flutter widget test for the Naraak app.
//
// It verifies the required Splash -> Logo Animation -> Welcome -> eKey path.

import 'package:flutter_test/flutter_test.dart';

import 'package:naraak/main.dart';

void main() {
  testWidgets('App launches through welcome and opens eKey login',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NaraakApp());
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text('Primary Healthcare, Closer to You'), findsOneWidget);
    expect(find.text('Login with eKey'), findsOneWidget);

    await tester.ensureVisible(find.text('Login with eKey'));
    await tester.tap(find.text('Login with eKey'));
    await tester.pumpAndSettle();

    expect(find.text('eKey Authentication'), findsOneWidget);
    expect(find.text('Password'), findsNothing);
    expect(find.text('CPR Number'), findsOneWidget);
  });
}
