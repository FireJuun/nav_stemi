import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:nav_stemi/src/features/auth/presentation/user_profile_dialog_controller.dart';

class UserProfileDialog extends StatefulWidget {
  const UserProfileDialog({
    required this.userData,
    this.onClose,
    super.key,
  });

  final FirebaseUserData userData;

  final VoidCallback? onClose;

  @override
  State<UserProfileDialog> createState() => _UserProfileDialogState();
}

class _UserProfileDialogState extends State<UserProfileDialog> {
  bool _isEditing = false;

  late final firstNameController =
      TextEditingController(text: widget.userData.firstName);
  late final lastNameController =
      TextEditingController(text: widget.userData.lastName);
  late final phoneNumberController =
      TextEditingController(text: widget.userData.phoneNumber);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(
        disabledColor: colorScheme.onSurface.withAlpha(250),
        inputDecorationTheme:
            const InputDecorationTheme(disabledBorder: InputBorder.none),
      ),
      child: AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isEditing ? 'Edit Account'.hardcoded : 'Account'.hardcoded,
            ),
            if (!_isEditing)
              Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                    onPressed: () {
                      ref.read(authRepositoryProvider).signOut();
                      Navigator.of(context).pop();
                      widget.onClose?.call();
                    },
                    child: Text('Sign Out'.hardcoded),
                  );
                },
              ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                style: TextStyle(
                  color: !_isEditing
                      ? colorScheme.onSurface.withOpacity(0.85)
                      : colorScheme.onSurface,
                ),
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  enabled: _isEditing,
                ),
                readOnly: !_isEditing,
              ),
              const SizedBox(height: 16),
              TextFormField(
                style: TextStyle(
                  color: !_isEditing
                      ? colorScheme.onSurface.withOpacity(0.85)
                      : colorScheme.onSurface,
                ),
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  enabled: _isEditing,
                ),
                readOnly: !_isEditing,
              ),
              const SizedBox(height: 16),
              TextFormField(
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.85),
                ),
                controller: phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  enabled: false,
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        actions: _isEditing
            ? [
                TextButton(
                  onPressed: () {
                    setState(() => _isEditing = false);
                  },
                  child: Text('Cancel'.hardcoded),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final userProfileState =
                        ref.watch(userProfileDialogControllerProvider);
                    return ElevatedButton(
                      onPressed: userProfileState.isLoading
                          ? null
                          : () async {
                              final success = await ref
                                  .read(
                                    userProfileDialogControllerProvider
                                        .notifier,
                                  )
                                  .updateUserData(
                                    appUser: widget.userData.appUser,
                                    firstName: firstNameController.text,
                                    lastName: lastNameController.text,
                                    phoneNumber: phoneNumberController.text,
                                  );
                              if (success) {
                                setState(() {
                                  _isEditing = false;
                                });
                              }
                            },
                      child: userProfileState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Save'),
                    );
                  },
                ),
              ]
            : [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  child: Text('Edit'.hardcoded),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onClose?.call();
                  },
                  child: Text('Close'.hardcoded),
                ),
              ],
      ),
    );
  }
}
