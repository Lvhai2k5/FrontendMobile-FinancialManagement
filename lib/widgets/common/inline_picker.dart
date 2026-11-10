import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// Opens in the layout so fields below the picker move out of the way.
class InlinePicker<T> extends StatefulWidget {
  const InlinePicker({
    super.key,
    required this.placeholder,
    required this.options,
    required this.value,
    required this.onChanged,
    this.prominent = false,
  });

  final String placeholder;
  final Map<T, String> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final bool prominent;

  @override
  State<InlinePicker<T>> createState() => _InlinePickerState<T>();
}

class _InlinePickerState<T> extends State<InlinePicker<T>> {
  final _controller = ExpansibleController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: widget.prominent
          ? const BorderSide(color: AppColors.secondary, width: 1.25)
          : BorderSide(color: AppColors.pastelBlush.withValues(alpha: 0.6)),
    );
    return ExpansionTile(
      controller: _controller,
      enabled: widget.onChanged != null,
      shape: shape,
      collapsedShape: shape,
      backgroundColor: widget.prominent
          ? AppColors.surfaceContainerLowest
          : AppColors.surfaceContainerLow,
      collapsedBackgroundColor: widget.prominent
          ? AppColors.secondaryContainer
          : AppColors.surfaceContainerLow,
      iconColor: widget.prominent ? AppColors.secondary : null,
      collapsedIconColor: widget.prominent ? AppColors.secondary : null,
      title: Text(widget.options[widget.value] ?? widget.placeholder,
          style: widget.prominent
              ? AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)
              : AppTypography.bodyMd),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: ListView(
            padding: EdgeInsets.zero,
            primary: false,
            shrinkWrap: true,
            children: [
              for (final option in widget.options.entries)
                ListTile(
                  title: Text(option.value, style: AppTypography.bodyMd),
                  selected: option.key == widget.value,
                  selectedTileColor: widget.prominent
                      ? AppColors.secondaryContainer.withValues(alpha: 0.5)
                      : null,
                  trailing: option.key == widget.value
                      ? const Icon(Icons.check)
                      : null,
                  onTap: widget.onChanged == null
                      ? null
                      : () {
                          _controller.collapse();
                          widget.onChanged?.call(option.key);
                        },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
