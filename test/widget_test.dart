import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hotel_reservation/app/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders the commercial navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Oteller'), findsWidgets);
    expect(find.text('Rezervasyon'), findsOneWidget);
    expect(find.text('Rezervasyonlar'), findsOneWidget);
    expect(find.text('Liman Işığı Oteli'), findsOneWidget);
  });

  testWidgets('booking screen is empty before hotel selection',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rezervasyon').last);
    await tester.pumpAndSettle();

    expect(find.text('Seçili tesis yok'), findsOneWidget);
  });

  testWidgets('hotel tap opens hotel specific booking flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Boğaz Sarayı'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Boğaz Sarayı'));
    await tester.pumpAndSettle();

    expect(find.text('Saray Süiti'), findsOneWidget);
    expect(find.text('Deniz Delüks'), findsWidgets);
    expect(find.text('Boğaz Süiti'), findsWidgets);
    expect(find.text('Rezervasyonu tamamla'), findsOneWidget);
    expect(find.textContaining('Kahvaltı'), findsWidgets);
  });

  testWidgets('shows validation on empty booking form',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Liman Işığı Oteli'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Liman Işığı Oteli'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rezervasyon').last);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Rezervasyonu tamamla'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Rezervasyonu tamamla'));
    await tester.pump();

    expect(find.text('Eksik alanları doldurun.'), findsOneWidget);
  });

  testWidgets('opens reservations menu', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rezervasyonlar'));
    await tester.pumpAndSettle();

    expect(find.text('Yaklaşan'), findsOneWidget);
    expect(find.text('Geçmiş'), findsOneWidget);
  });

  testWidgets('filters hotels by selected feature',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filtreler'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'Spa'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Uygula'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uygula'));
    await tester.pumpAndSettle();

    expect(find.text('Liman Işığı Oteli'), findsOneWidget);
    expect(find.text('Boğaz Sarayı'), findsNothing);
  });
}
