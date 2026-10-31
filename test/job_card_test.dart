import 'package:aioconvert/l10n/generated/app_localizations.dart';
import 'package:aioconvert/media_tools.dart';
import 'package:aioconvert/models/media_job.dart';
import 'package:aioconvert/pages/converter/widgets/job_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const originalName = 'original.mp4';

  late MediaJob job;
  late List<String?> changes;

  setUp(() {
    job = MediaJob(
      id: 'job-1',
      path: '/input/$originalName',
      name: originalName,
      kind: MediaKind.video,
      hasAudio: true,
      sourceFormat: 'MP4',
      fileSize: 1024,
      duration: 10,
    );
    changes = [];
  });

  test('custom output names replace the default converted suffix', () {
    expect(job.outputFileName('webm'), 'original_converted.webm');

    job.outputName = 'custom-name.mov';

    expect(job.outputFileName('webm'), 'custom-name.webm');
    expect(job.name, originalName);
  });

  Future<void> pumpCard(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Column(
              children: [
                JobCard(
                  job: job,
                  isConverting: false,
                  onFormatChanged: (_) {},
                  onOutputNameChanged: (name) {
                    changes.add(name);
                    setState(() => job.outputName = name);
                  },
                  onCancel: () {},
                  onRemove: () {},
                ),
                const Text('Outside'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Enter saves a custom output name without renaming the source', (
    tester,
  ) async {
    await pumpCard(tester);

    await tester.tap(find.text(originalName));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'converted-name.mov');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(changes, ['converted-name.mov']);
    expect(job.outputName, 'converted-name.mov');
    expect(job.name, originalName);
    expect(job.path, '/input/$originalName');
    expect(find.text('converted-name.mov'), findsOneWidget);
  });

  testWidgets('Escape cancels edits and restores the current displayed name', (
    tester,
  ) async {
    await pumpCard(tester);

    await tester.tap(find.text(originalName));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'discard-this.mp4');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(changes, isEmpty);
    expect(job.outputName, isNull);
    expect(find.text(originalName), findsOneWidget);
  });

  testWidgets('unfocusing the editor saves the entered name', (tester) async {
    await pumpCard(tester);

    await tester.tap(find.text(originalName));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'saved-on-blur.mp4');
    await tester.tap(find.text('Outside'));
    await tester.pumpAndSettle();

    expect(changes, ['saved-on-blur.mp4']);
    expect(job.outputName, 'saved-on-blur.mp4');
  });

  testWidgets('restore action clears the custom output name', (tester) async {
    job.outputName = 'custom-name.mp4';
    await pumpCard(tester);

    await tester.tap(find.byTooltip('Restore original file name'));
    await tester.pump();

    expect(changes, [null]);
    expect(job.outputName, isNull);
    expect(find.text(originalName), findsOneWidget);
  });
}
