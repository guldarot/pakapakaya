import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pakapakaya_flutter/app/app.dart';

void main() {
  testWidgets('shows login gate when unauthenticated', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PakaPakayaApp()));
    await tester.pumpAndSettle();

    expect(find.text('PakaPakaya'), findsOneWidget);
    expect(find.text('Continue with demo OTP'), findsOneWidget);
  });
}
