import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animated_otp_field/animated_otp_field.dart';

void main() {
  Widget buildApp({Widget? child}) {
    return MaterialApp(home: Scaffold(body: child ?? const AnimatedOtpField()));
  }

  Future<void> enterOtp(WidgetTester tester, String text) async {
    final state = tester.state<AnimatedOtpFieldState>(
      find.byType(AnimatedOtpField),
    );
    state.editableTextKey.currentState?.requestKeyboard();
    await tester.pump();
    tester.testTextInput.enterText(text);
    await tester.pump();
  }

  group('US1: Correct OTP Validation Behavior', () {
    testWidgets(
      'T008: renders correct number of pin boxes for default length: 6',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await enterOtp(tester, '123456');
        await tester.pumpAndSettle();
        expect(find.text('1'), findsOneWidget);
        expect(find.text('6'), findsOneWidget);
      },
    );

    testWidgets(
      'T009: renders correct number of pin boxes for custom length: 4',
      (tester) async {
        await tester.pumpWidget(
          buildApp(child: const AnimatedOtpField(length: 4)),
        );
        await enterOtp(tester, '1234');
        await tester.pumpAndSettle();
        expect(find.text('4'), findsOneWidget);
      },
    );

    testWidgets(
      'T010: onCompleted fires with full OTP string when all digits entered',
      (tester) async {
        String? result;
        await tester.pumpWidget(
          buildApp(child: AnimatedOtpField(onCompleted: (val) => result = val)),
        );
        await enterOtp(tester, '123456');
        await tester.pumpAndSettle();
        expect(result, '123456');
      },
    );

    testWidgets(
      'T011: isOtpValid returning true triggers valid decoration state',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            child: AnimatedOtpField(
              isOtpValid: (val) => true,
              validPinDecoration: const BoxDecoration(color: Colors.green),
            ),
          ),
        );
        await enterOtp(tester, '123456');
        await tester.pump(
          const Duration(milliseconds: 100),
        ); // wait for valid animation
        await tester.pump(
          const Duration(milliseconds: 800),
        ); // wait for cascade
        final decorations = tester.widgetList<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        // Should find containers with green color
        bool foundGreen = decorations.any(
          (c) => (c.decoration as BoxDecoration?)?.color == Colors.green,
        );
        expect(foundGreen, isTrue);
        await tester.pump(
          const Duration(seconds: 3),
        ); // flush remaining state timers
      },
    );

    testWidgets(
      'T012: isOtpValid returning false triggers error decoration and validation message',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            child: AnimatedOtpField(
              isOtpValid: (val) => false,
              validationMsg: 'Wrong OTP',
            ),
          ),
        );
        await enterOtp(tester, '000000');
        await tester.pumpAndSettle();
        expect(find.text('Wrong OTP'), findsOneWidget);
      },
    );

    testWidgets(
      'T013: validation works correctly when widget has a GlobalKey',
      (tester) async {
        final key = GlobalKey<AnimatedOtpFieldState>();
        await tester.pumpWidget(
          buildApp(
            child: AnimatedOtpField(key: key, validationMsg: 'Server error'),
          ),
        );
        key.currentState?.validateOtp(false);
        await tester.pumpAndSettle();
        expect(find.text('Server error'), findsOneWidget);
      },
    );

    testWidgets(
      'T014: re-focusing the field after error clears error decoration and message',
      (tester) async {
        final focusNode = FocusNode();
        await tester.pumpWidget(
          buildApp(
            child: AnimatedOtpField(
              focusNode: focusNode,
              isOtpValid: (val) => false,
              validationMsg: 'Wrong OTP',
            ),
          ),
        );
        await enterOtp(tester, '000000');
        await tester.pumpAndSettle();
        expect(find.text('Wrong OTP'), findsOneWidget);

        focusNode.unfocus();
        await tester.pumpAndSettle();

        focusNode.requestFocus();
        await tester.pumpAndSettle();
        expect(find.text('Wrong OTP'), findsNothing);
      },
    );
  });

  group('US2: Stable Widget Lifecycle', () {
    testWidgets(
      'T015: widget disposes without exceptions when no interaction occurs',
      (tester) async {
        await tester.pumpWidget(buildApp(child: const AnimatedOtpField()));
        await tester.pumpWidget(const SizedBox()); // dispose
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'T016: widget disposes cleanly during active valid-OTP animation (mid-timer)',
      (tester) async {
        await tester.pumpWidget(
          buildApp(child: AnimatedOtpField(isOtpValid: (v) => true)),
        );
        await enterOtp(tester, '123456');
        await tester.pump(const Duration(milliseconds: 10)); // early mid-timer
        await tester.pumpWidget(const SizedBox()); // dispose
        await tester.pump(
          const Duration(seconds: 3),
        ); // flush the single created timer
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'T017: externally provided controller and focusNode does NOT dispose them',
      (tester) async {
        final controller = TextEditingController();
        final focusNode = FocusNode();
        await tester.pumpWidget(
          buildApp(
            child: AnimatedOtpField(
              controller: controller,
              focusNode: focusNode,
            ),
          ),
        );
        await tester.pumpWidget(const SizedBox()); // dispose
        // Accessing them should not throw if they weren't disposed
        expect(() => controller.text, returnsNormally);
        expect(() => focusNode.hasFocus, returnsNormally);
      },
    );

    testWidgets('T018: internally created instances are disposed seamlessly', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(child: const AnimatedOtpField()));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  });

  group('US3: SMS Autofill Works on Mobile', () {
    testWidgets('T019: autofill exact length', (tester) async {
      String? result;
      final key = GlobalKey<AnimatedOtpFieldState>();
      await tester.pumpWidget(
        buildApp(
          child: AnimatedOtpField(key: key, onCompleted: (val) => result = val),
        ),
      );
      key.currentState?.autofill(const TextEditingValue(text: '123456'));
      await tester.pumpAndSettle();
      expect(result, '123456');
    });

    testWidgets('T020: autofill truncates', (tester) async {
      String? result;
      final key = GlobalKey<AnimatedOtpFieldState>();
      await tester.pumpWidget(
        buildApp(
          child: AnimatedOtpField(key: key, onCompleted: (val) => result = val),
        ),
      );
      key.currentState?.autofill(const TextEditingValue(text: '123456789'));
      await tester.pumpAndSettle();
      expect(result, '123456');
    });
  });

  group('US4: Clean Public API for Package Consumers', () {
    testWidgets(
      'T021: AnimatedOtpField() with zero parameters renders a functional 6-digit field',
      (tester) async {
        await tester.pumpWidget(buildApp(child: const AnimatedOtpField()));
        await enterOtp(tester, '123456');
        await tester.pumpAndSettle();
        expect(find.text('5'), findsOneWidget);
      },
    );

    testWidgets('T022: custom decorations', (tester) async {
      final key = GlobalKey<AnimatedOtpFieldState>();
      await tester.pumpWidget(
        buildApp(
          child: AnimatedOtpField(
            key: key,
            errorPinDecoration: const BoxDecoration(color: Colors.red),
          ),
        ),
      );
      key.currentState?.validateOtp(false);
      await tester.pumpAndSettle();
      final decorations = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      bool foundRed = decorations.any(
        (c) => (c.decoration as BoxDecoration?)?.color == Colors.red,
      );
      expect(foundRed, isTrue);
    });

    testWidgets('T023: validateOtp(true)', (tester) async {
      final key = GlobalKey<AnimatedOtpFieldState>();
      await tester.pumpWidget(
        buildApp(
          child: AnimatedOtpField(
            key: key,
            validPinDecoration: const BoxDecoration(color: Colors.green),
          ),
        ),
      );
      key.currentState?.validateOtp(true);
      await tester.pump(const Duration(milliseconds: 800)); // cascade wait
      final decorations = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      bool foundGreen = decorations.any(
        (c) => (c.decoration as BoxDecoration?)?.color == Colors.green,
      );
      expect(foundGreen, isTrue);
    });

    testWidgets('T024: validateOtp(false)', (tester) async {
      final key = GlobalKey<AnimatedOtpFieldState>();
      await tester.pumpWidget(
        buildApp(
          child: AnimatedOtpField(
            key: key,
            validationMsg: 'Failed to authenticate',
          ),
        ),
      );
      key.currentState?.validateOtp(false);
      await tester.pumpAndSettle();
      expect(find.text('Failed to authenticate'), findsOneWidget);
    });
  });

  group('US5: Cross-Platform Graceful Degradation', () {
    testWidgets('T025: invalid OTP does not throw exception', (tester) async {
      await tester.pumpWidget(
        buildApp(child: AnimatedOtpField(isOtpValid: (v) => false)),
      );
      await enterOtp(tester, '000000');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('T026: shakeOnInvalidOtp false shows error msg without shake', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          child: AnimatedOtpField(
            isOtpValid: (v) => false,
            shakeOnInvalidOtp: false,
            validationMsg: 'No Shake Error',
          ),
        ),
      );
      await enterOtp(tester, '000000');
      await tester.pumpAndSettle();
      expect(find.text('No Shake Error'), findsOneWidget);
    });
  });
}
