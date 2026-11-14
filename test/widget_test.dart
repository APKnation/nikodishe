import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kodisha/app.dart';

void main() {
  testWidgets('Kodisha app launch smoke test', (WidgetTester tester) async {
    // Jenga Kodisha app ndani ya ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Subiri animations na initial rendering
    await tester.pumpAndSettle();

    // Hakikisha app inaanza vizuri
    expect(find.byType(MyApp), findsOneWidget);
  });
}
