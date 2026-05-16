import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/widgets/orbita_forui.dart';
import 'package:orbita/widgets/orbita_select_field.dart';

Future<TimeOfDay?> pickBackupAutoTime(
  BuildContext context,
  TimeOfDay initialTime,
) {
  final l10n = AppLocalizations.of(context)!;
  final material = MaterialLocalizations.of(context);
  var hour = initialTime.hour;
  var minute = initialTime.minute;
  final hours = List<int>.generate(24, (index) => index);
  final minutes = List<int>.generate(60, (index) => index);
  String twoDigits(int value) => value.toString().padLeft(2, '0');

  return showOrbitaDialog<TimeOfDay>(
    context: context,
    builder: (context, animation) => StatefulBuilder(
      builder: (context, setState) => OrbitaDialog(
        animation: animation,
        title: l10n.backupAutoTime,
        actions: [
          OrbitaDialogAction(
            label: l10n.commonCancel,
            variant: FButtonVariant.outline,
            onPress: () => Navigator.of(context).pop(),
          ),
          OrbitaDialogAction(
            label: l10n.commonConfirm,
            onPress: () =>
                Navigator.of(context).pop(TimeOfDay(hour: hour, minute: minute)),
          ),
        ],
        child: Row(
          children: [
            Expanded(
              child: OrbitaSelectField<int>(
                label: material.timePickerHourLabel,
                value: hour,
                options: hours,
                labelBuilder: twoDigits,
                onChanged: (value) => setState(() => hour = value),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OrbitaSelectField<int>(
                label: material.timePickerMinuteLabel,
                value: minute,
                options: minutes,
                labelBuilder: twoDigits,
                onChanged: (value) => setState(() => minute = value),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
