import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/user.dart';
import '../state/auth_state.dart';
import '../widgets/app_surface_card.dart';

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
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _savingUsername = false;
  bool _changingPassword = false;

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.user.username);
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

  void _snack(String text) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(text)));

  Future<void> _saveUsername() async {
    setState(() => _savingUsername = true);
    final err = await widget.authState
        .updateUsernameForCurrentUser(_usernameController.text);
    if (!mounted) return;
    setState(() => _savingUsername = false);
    if (err != null) {
      _snack(err);
      return;
    }
    widget.onProfileChanged();
    _snack(AppStrings.profileSaved);
  }

  Future<void> _changePassword() async {
    setState(() => _changingPassword = true);
    final err = await widget.authState.changePasswordForCurrentUser(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
    if (!mounted) return;
    setState(() => _changingPassword = false);
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

    Widget sectionTitle(String text) => Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        sectionTitle(AppStrings.profileAccountSection),
        AppSurfaceCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('profile_username_field'),
                controller: _usernameController,
                enabled: !_savingUsername,
                decoration: const InputDecoration(
                  labelText: AppStrings.profileCurrentUsername,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: _savingUsername ? null : _saveUsername,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _savingUsername
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(AppStrings.profileSaveUsername),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        sectionTitle(AppStrings.profileDetailsSection),
        Text(
          AppStrings.profileReadOnlyNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        AppSurfaceCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.profileReadOnlyEmailLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              SelectableText(
                key: const Key('profile_email_display'),
                widget.user.email,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Divider(
                  height: 1,
                  color:
                      scheme.outlineVariant.withValues(alpha: 0.6)),
              const SizedBox(height: 18),
              Text(
                AppStrings.profileReadOnlyHandleLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
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
        const SizedBox(height: 24),
        sectionTitle(AppStrings.profileSecuritySection),
        AppSurfaceCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('profile_current_password_field'),
                controller: _currentPasswordController,
                obscureText: true,
                enabled: !_changingPassword,
                decoration: const InputDecoration(
                  labelText: AppStrings.profileCurrentPassword,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('profile_new_password_field'),
                controller: _newPasswordController,
                obscureText: true,
                enabled: !_changingPassword,
                decoration: const InputDecoration(
                  labelText: AppStrings.profileNewPassword,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('profile_confirm_password_field'),
                controller: _confirmPasswordController,
                obscureText: true,
                enabled: !_changingPassword,
                decoration: const InputDecoration(
                  labelText: AppStrings.profileConfirmNewPassword,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _changingPassword ? null : _changePassword,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _changingPassword
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(AppStrings.profileChangePassword),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          onPressed: widget.onLogout,
          icon: const Icon(Icons.logout_rounded),
          label: const Text(AppStrings.authLogoutTooltip),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}
