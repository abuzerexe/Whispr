import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../state/auth_state.dart';
import '../widgets/app_surface_card.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.authState,
    required this.onAuthenticated,
  });

  final AuthState authState;
  final VoidCallback onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _setMode(bool login) {
    setState(() {
      _isLogin = login;
      _error = null;
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmController.clear();
    });
  }

  Future<void> _submit() async {
    final password = _passwordController.text;

    if (_isLogin) {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        setState(() => _error = AppStrings.authValidationEmail);
        return;
      }
      if (!AuthState.isValidEmailFormat(email)) {
        setState(() => _error = AppStrings.authValidationEmailInvalid);
        return;
      }
      if (password.isEmpty) {
        setState(() => _error = AppStrings.authValidationPassword);
        return;
      }

      setState(() {
        _loading = true;
        _error = null;
      });
      try {
        final err = await widget.authState.login(
          email: email,
          password: password,
        );
        if (!mounted) return;
        if (err != null) {
          setState(() {
            _loading = false;
            _error = err;
          });
          return;
        }
        if (widget.authState.currentUser == null) {
          setState(() {
            _loading = false;
            _error = AppStrings.authProfileLoadFailed;
          });
          return;
        }
        setState(() => _loading = false);
        widget.onAuthenticated();
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = AppStrings.authUnexpectedError;
        });
      }
      return;
    }

    // ── Sign-up ──────────────────────────────────────────────────────────────
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() => _error = AppStrings.authValidationUsername);
      return;
    }

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = AppStrings.authValidationEmail);
      return;
    }
    if (!AuthState.isValidEmailFormat(email)) {
      setState(() => _error = AppStrings.authValidationEmailInvalid);
      return;
    }

    if (password.isEmpty) {
      setState(() => _error = AppStrings.authValidationPassword);
      return;
    }
    if (password.length < 6) {
      setState(() => _error = AppStrings.authValidationPasswordShort);
      return;
    }

    final confirm = _confirmController.text;
    if (password != confirm) {
      setState(() => _error = AppStrings.authValidationPasswordMismatch);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final err = await widget.authState.signup(
        username: username,
        email: email,
        password: password,
      );
      if (!mounted) return;
      if (err != null) {
        setState(() {
          _loading = false;
          _error = err;
        });
        return;
      }
      if (widget.authState.currentUser == null) {
        setState(() {
          _loading = false;
          _error = AppStrings.authProfileLoadFailed;
        });
        return;
      }
      setState(() => _loading = false);
      widget.onAuthenticated();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppStrings.authUnexpectedError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isLogin ? AppStrings.authLoginTab : AppStrings.authSignupTab;
    final button =
        _isLogin ? AppStrings.authLoginButton : AppStrings.authSignupButton;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AppSurfaceCard(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: scheme.primaryContainer,
                        child: Icon(
                          Icons.lock_person_rounded,
                          size: 40,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Username — signup only
                    if (!_isLogin) ...[
                      TextField(
                        key: const Key('auth_username_field'),
                        controller: _usernameController,
                        autocorrect: false,
                        enabled: !_loading,
                        decoration: const InputDecoration(
                          hintText: AppStrings.authUsernameHint,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Email — always shown
                    TextField(
                      key: const Key('auth_email_field'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enabled: !_loading,
                      decoration: const InputDecoration(
                        hintText: AppStrings.authEmailHint,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      key: const Key('auth_password_field'),
                      controller: _passwordController,
                      obscureText: true,
                      enabled: !_loading,
                      decoration: const InputDecoration(
                        hintText: AppStrings.authPasswordHint,
                      ),
                    ),

                    if (!_isLogin) ...[
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('auth_confirm_field'),
                        controller: _confirmController,
                        obscureText: true,
                        enabled: !_loading,
                        decoration: const InputDecoration(
                          hintText: AppStrings.authConfirmPasswordHint,
                        ),
                      ),
                    ],

                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: scheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      key: const Key('auth_submit_button'),
                      onPressed: _loading ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(button),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        key: const Key('auth_toggle_mode_button'),
                        onPressed: _loading ? null : () => _setMode(!_isLogin),
                        child: Text(
                          _isLogin
                              ? AppStrings.authSwitchToSignup
                              : AppStrings.authSwitchToLogin,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
