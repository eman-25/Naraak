// This is a basic Flutter widget test for the Naraak app.
//
// It verifies that the app launches and shows the login screen first,
// since NaraakApp starts at initialRoute: '/login'.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:naraak/main.dart';

void main() {
  testWidgets('App launches and shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NaraakApp());

    // The login screen should show the app name and a CPR field.
    expect(find.text('Naraak'), findsWidgets);
    expect(find.text('Log in with eKey (Demo)'), findsOneWidget);
  });
}