import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator/main.dart';

void main() {
  Future<void> press(WidgetTester tester, List<String> keys) async {
    for (final key in keys) {
      await tester.tap(find.byKey(ValueKey('key-$key')));
      await tester.pump();
    }
  }

  String display(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const ValueKey('display'))).data!;

  testWidgets('2 + 2 equals 4', (tester) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['2', '+', '2', '=']);
    expect(display(tester), '4');
  });

  testWidgets('9 - 5 equals 4', (tester) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['9', '−', '5', '=']);
    expect(display(tester), '4');
  });

  testWidgets('3 × 4 equals 12', (tester) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['3', '×', '4', '=']);
    expect(display(tester), '12');
  });

  testWidgets('8 ÷ 2 equals 4', (tester) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['8', '÷', '2', '=']);
    expect(display(tester), '4');
  });

  testWidgets('1.5 + 2.5 equals 4', (tester) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['1', '.', '5', '+', '2', '.', '5', '=']);
    expect(display(tester), '4');
  });

  testWidgets('Basic arithmetic and sequential operations', (tester) async {
    await tester.pumpWidget(const MyApp());
    for (final entry in {'+': '10', '−': '6', '×': '16', '÷': '4'}.entries) {
      await press(tester, ['AC', '8', entry.key, '2', '=']);
      expect(display(tester), entry.value);
    }
    await press(tester, ['AC', '2', '+', '3', '×', '4', '=']);
    expect(display(tester), '20');
  });

  testWidgets('Decimals, editing, sign and fresh entry', (tester) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['0', '.', '1', '.', '+', '0', '.', '2', '=']);
    expect(display(tester), '0.3');
    await press(tester, ['9', '8', '⌫', '+/−']);
    expect(display(tester), '-9');
    await press(tester, ['AC', '5', '+', '+/−', '2', '=']);
    expect(display(tester), '3');
  });

  testWidgets('Operator replacement and zero division recovery', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['8', '+', '÷', '2', '=']);
    expect(display(tester), '4');
    await press(tester, ['÷', '0', '=']);
    expect(display(tester), 'Error');
    await press(tester, ['7']);
    expect(display(tester), '7');
  });

  testWidgets('Fits a small iPhone screen', (tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    expect(tester.takeException(), isNull);
    await press(tester, ['1', '+', '2', '=']);
    expect(display(tester), '3');
  });
}
