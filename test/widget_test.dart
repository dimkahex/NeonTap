import 'package:flutter_test/flutter_test.dart';

import 'package:neon_pulse_online/src/app.dart';

void main() {
  testWidgets('NeonPulseApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(const NeonPulseApp());
  });
}
