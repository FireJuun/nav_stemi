import 'package:flutter/material.dart';

class PatientEntryText extends StatefulWidget {
  const PatientEntryText({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.prefixIcon,
    this.hint,
    this.keyboardType,
    this.readOnly = false,
    super.key,
  });

  final String label;
  final String? initialValue;
  final FormFieldSetter<String>? onChanged;
  final Widget? prefixIcon;
  final String? hint;
  final TextInputType? keyboardType;
  final bool readOnly;

  @override
  State<PatientEntryText> createState() => _PatientEntryTextState();
}

class _PatientEntryTextState extends State<PatientEntryText> {
  late final TextEditingController _textEditingController =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _textEditingController,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon,
        filled: !widget.readOnly,
        hintText: widget.hint,
        label: Text(widget.label, textAlign: TextAlign.center),
      ),
      readOnly: widget.readOnly,
      onTapOutside: (PointerDownEvent event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}
