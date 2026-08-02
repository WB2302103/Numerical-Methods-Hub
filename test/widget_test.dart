import 'package:flutter_test/flutter_test.dart';
import 'package:complex_lu_solver/main.dart';

void main() {
  testWidgets('Home screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the Home screen title is present.
    expect(find.text('Linear System Solver'), findsOneWidget);

    // Verify that methods are listed.
    expect(find.text('Gaussian Elimination'), findsOneWidget);
    expect(find.text('LU Decomposition'), findsOneWidget);
    expect(find.text('Jacobi Iterative'), findsOneWidget);
  });
}
