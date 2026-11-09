import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/main.dart';
import 'package:video_clipper_app/features/project_manager/views/project_manager_screen.dart';

void main() {
  testWidgets('QuickClip Pro App Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(ProjectManagerScreen), findsOneWidget);
    expect(find.text('QuickClip Pro'), findsOneWidget);
    expect(find.text('Proyek Baru'), findsOneWidget);
  });
}
