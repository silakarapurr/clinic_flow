import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_flow/shared/widgets/app_button.dart';

void main() {
  group('AppButton Widget Tests', () {
    testWidgets('renders button text correctly and triggers onTap', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Kaydet',
              onPressed: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Kaydet'), findsOneWidget);

      await tester.tap(find.text('Kaydet'));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('shows loading indicator when isLoading is true and ignores taps', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Giriş Yap',
              isLoading: true,
              onPressed: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Giriş Yap'), findsNothing);

      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(wasTapped, isFalse);
    });
  });
}
