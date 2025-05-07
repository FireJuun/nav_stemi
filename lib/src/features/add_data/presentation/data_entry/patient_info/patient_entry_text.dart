import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PatientEntryText extends StatefulWidget {
  const PatientEntryText({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.prefixIcon,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.readOnly = false,
    super.key,
  });

  final String label;
  final String? initialValue;
  final FormFieldSetter<String>? onChanged;
  final Widget? prefixIcon;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool readOnly;

  @override
  State<PatientEntryText> createState() => _PatientEntryTextState();
}

class _PatientEntryTextState extends State<PatientEntryText> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(PatientEntryText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only update the controller if the initialValue has changed
    if (widget.initialValue != oldWidget.initialValue) {
      // Schedule the update for the next frame to avoid
      // updating during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check if the widget is still mounted before updating
        if (mounted && _textEditingController.text != widget.initialValue) {
          _textEditingController.text = widget.initialValue ?? '';
        }
      });
    }
  }

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
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      readOnly: widget.readOnly,
      onTapOutside: (PointerDownEvent event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}
