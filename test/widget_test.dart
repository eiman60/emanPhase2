import 'package:flutter_test/flutter_test.dart';

import 'package:personal_hajj_e_guide/main.dart';

void main() {
  testWidgets('renders redesigned home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NusukApp());

    expect(find.text('ahmed'), findsOneWidget);
    expect(find.text('Fajr 5:25 AM'), findsOneWidget);
    expect(find.text('اكتشف المزيد'), findsOneWidget);
    expect(find.text('Try Nusuk AI'), findsOneWidget);
  });
}
