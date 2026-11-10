import 'package:flutter/material.dart';

/// Keeps Flutter's calendar mode inside a centered, bounded dialog.
Widget compactDateRangeDialog(BuildContext context, Widget? child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440, maxHeight: 540),
          child: DatePickerTheme(
            data: DatePickerTheme.of(context).copyWith(
              rangePickerShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: child!,
          ),
        ),
      ),
    );
