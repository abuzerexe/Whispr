import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/user.dart';
import '../state/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.authState,
    required this.onProfileChanged,
    required this.onLogout,
  });

  final User user;
  final AuthState authState;
  final VoidCallback onProfileChanged;
  final VoidCallback onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _usernameController;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _usernameController.text = widget.user.username;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _saveUsername() {
    final err = widget.authState.updateUsernameForCurrentUser(_usernameController.text);
    if (err != null) {
      _snack(err);
      return;
    }
    widget.onProfileChanged();
    _snack(AppStrings.profileSaved);
  }

  void _changePassword() {
    final err = widget.authState.changePasswordForCurrentUser(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
    if (err != null) {
      _snack(err);
      return;
    }
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    widget.onProfileChanged();
    _snack(AppStrings.profileSaved);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        Text(
          AppStrings.profileAccountSection,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('profile_username_field'),
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: AppStrings.profileCurrentUsername,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _saveUsername,
          child: const Text(AppStrings.profileSaveUsername),
        ),
        const SizedBox(height: 28),
        Text(
          AppStrings.profileDetailsSection,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.profileReadOnlyNote,
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Card(
          color: scheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.profileReadOnlyEmailLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  key: const Key('profile_email_display'),
                  widget.user.email,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.profileReadOnlyHandleLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  key: const Key('profile_handle_display'),
                  widget.user.anonymousHandle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          AppStrings.profileSecuritySection,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('profile_current_password_field'),
          controller: _currentPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: AppStrings.profileCurrentPassword,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('profile_new_password_field'),
          controller: _newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: AppStrings.profileNewPassword,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('profile_confirm_password_field'),
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: AppStrings.profileConfirmNewPassword,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _changePassword,
          child: const Text(AppStrings.profileChangePassword),
        ),
        const SizedBox(height: 32),
        TextButton.icon(
          onPressed: widget.onLogout,
          icon: const Icon(Icons.logout),
          label: const Text(AppStrings.authLogoutTooltip),
        ),
      ],
    );
  }
}
