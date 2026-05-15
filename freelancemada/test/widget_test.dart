import 'package:flutter_test/flutter_test.dart';
import 'package:freelancemada/main.dart';
import 'package:provider/provider.dart';
import 'package:freelancemada/providers/auth_provider.dart';
import 'package:freelancemada/providers/mission_provider.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => MissionProvider()),
        ],
        child: const FreeLanceMadaApp(),
      ),
    );
    expect(find.byType(FreeLanceMadaApp), findsOneWidget);
  });
}
