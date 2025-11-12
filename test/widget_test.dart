// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:random_image/main.dart';
import 'package:random_image/widgets/another_image_button.dart';

void main() {
  testWidgets('Image fetcher app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MainApp());

    // Verify that the "Another" button exists
    expect(find.text(AnotherImageButton.buttonText), findsOneWidget);

    // Verify that we have a loading indicator or image placeholder
    // The app starts by fetching an image, so we should see some loading state
    await tester.pump();

    // The test should find either a CircularProgressIndicator or the "Another" button
    expect(
      find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
          find.text(AnotherImageButton.buttonText).evaluate().isNotEmpty,
      isTrue,
    );
  });

  testWidgets('App handles landscape orientation without overflow', (
    WidgetTester tester,
  ) async {
    // Set up a landscape viewport
    tester.view.physicalSize = const Size(800, 400);
    tester.view.devicePixelRatio = 1.0;

    // Build our app
    await tester.pumpWidget(const MainApp());

    // Let the app settle
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // There should be no overflow errors
    // The test framework will automatically fail if there are overflow errors

    // Verify the button is still visible
    expect(find.text(AnotherImageButton.buttonText), findsOneWidget);

    // Reset the view
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('App handles portrait orientation without overflow', (
    WidgetTester tester,
  ) async {
    // Set up a portrait viewport
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;

    // Build our app
    await tester.pumpWidget(const MainApp());

    // Let the app settle
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // There should be no overflow errors
    // The test framework will automatically fail if there are overflow errors

    // Verify the button is still visible
    expect(find.text(AnotherImageButton.buttonText), findsOneWidget);

    // Reset the view
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
