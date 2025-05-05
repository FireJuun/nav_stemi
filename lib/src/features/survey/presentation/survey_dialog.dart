import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// Shows a dialog with a survey after navigation is completed
class SurveyDialog extends ConsumerStatefulWidget {
  const SurveyDialog({super.key});

  /// Shows the survey dialog and returns true if user completed the survey,
  /// false if they skipped it
  static Future<bool> show(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => const SurveyDialog(),
        ) ??
        false;
  }

  @override
  ConsumerState<SurveyDialog> createState() => _SurveyDialogState();
}

class _SurveyDialogState extends ConsumerState<SurveyDialog> {
  int? _appHelpfulness;
  int? _appDifficulty;
  final _improvementController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showValidationErrors = false;

  @override
  void dispose() {
    _improvementController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _showValidationErrors = true;
    });

    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final controller = ref.read(surveyControllerProvider.notifier);
    final success = await controller.submitSurvey(
      appHelpfulness: _appHelpfulness!,
      appDifficulty: _appDifficulty!,
      improvementSuggestion: _improvementController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for providing feedback.'.hardcoded),
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to submit feedback. Please try again.'.hardcoded),
          ),
        );
      }
    }
  }

  void _skip() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      surveyControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final theme = Theme.of(context);
    final state = ref.watch(surveyControllerProvider);
    final isSubmitting = state is AsyncLoading;

    return AlertDialog(
      title: Text('Navigation Feedback'.hardcoded),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          autovalidateMode: _showValidationErrors
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please help us improve the app by answering a few questions.'
                      .hardcoded,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 24),

                // Question 1
                FormField<int>(
                  initialValue: _appHelpfulness,
                  validator: (value) {
                    if (value == null) {
                      return 'Please answer this question'.hardcoded;
                    }
                    return null;
                  },
                  builder: (FormFieldState<int> field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1. How helpful was the app in managing this case?'
                              .hardcoded,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildLikertScale(
                          value: _appHelpfulness,
                          onChanged: (val) {
                            setState(() => _appHelpfulness = val);
                            field.didChange(val);
                          },
                          labels: const [
                            'Not helpful at all',
                            'Mildly helpful',
                            'Moderately helpful',
                            'Very helpful',
                          ],
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 12),
                            child: Text(
                              field.errorText!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Question 2
                FormField<int>(
                  initialValue: _appDifficulty,
                  validator: (value) {
                    if (value == null) {
                      return 'Please answer this question'.hardcoded;
                    }
                    return null;
                  },
                  builder: (FormFieldState<int> field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '2. How difficult was it to use the app?'.hardcoded,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildLikertScale(
                          value: _appDifficulty,
                          onChanged: (val) {
                            setState(() => _appDifficulty = val);
                            field.didChange(val);
                          },
                          labels: const [
                            'Very easy',
                            'Mostly easy',
                            'Somewhat difficult',
                            'Very difficult',
                          ],
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 12),
                            child: Text(
                              field.errorText!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Question 3
                Text(
                  "3. What's one thing you would improve or change about the app?"
                      .hardcoded,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _improvementController,
                  decoration: InputDecoration(
                    hintText: 'Your feedback...'.hardcoded,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : _skip,
          child: Text('Skip'.hardcoded),
        ),
        FilledButton(
          onPressed: isSubmitting ? null : _submit,
          child: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text('Submit'.hardcoded),
        ),
      ],
    );
  }

  Widget _buildLikertScale({
    required int? value,
    required void Function(int?) onChanged,
    required List<String> labels,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            labels.length,
            (index) => Expanded(
              child: Radio<int>(
                value: index + 1,
                toggleable: true,
                groupValue: value,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: labels
              .map(
                (label) => Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
