import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../state/auth_state.dart';

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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
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
      _passwordController.clear();
      _confirmController.clear();
      _emailController.clear();
    });
  }

  void _submit() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _error = AppStrings.authValidationPassword);
      return;
    }
    if (password.length < 4) {
      setState(() => _error = AppStrings.authValidationPasswordShort);
      return;
    }

    if (_isLogin) {
      if (username.isEmpty) {
        setState(() => _error = AppStrings.authValidationLoginIdentifier);
        return;
      }
      final user = widget.authState.login(identifier: username, password: password);
      if (user == null) {
        setState(() => _error = AppStrings.authLoginFailed);
        return;
      }
      widget.onAuthenticated();
      return;
    }

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

    final confirm = _confirmController.text;
    if (password != confirm) {
      setState(() => _error = AppStrings.authValidationPasswordMismatch);
      return;
    }
    if (widget.authState.usernameExists(username)) {
      setState(() => _error = AppStrings.authValidationUsernameTaken);
      return;
    }
    if (widget.authState.emailExists(email)) {
      setState(() => _error = AppStrings.authValidationEmailTaken);
      return;
    }
    final created = widget.authState.signup(
      username: username,
      email: email,
      password: password,
    );
    if (created == null) {
      setState(() => _error = AppStrings.authValidationUsernameTaken);
      return;
    }
    widget.onAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isLogin ? AppStrings.authLoginTab : AppStrings.authSignupTab;
    final button = _isLogin ? AppStrings.authLoginButton : AppStrings.authSignupButton;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 0,
                color: scheme.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: scheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.lock_person_rounded,
                        size: 58,
                        color: scheme.primary,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('auth_username_field'),
                        controller: _usernameController,
                        autocorrect: false,
                        decoration: InputDecoration(
                          hintText: _isLogin
                              ? AppStrings.authLoginIdentifierHint
                              : AppStrings.authUsernameHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      if (!_isLogin) ...[
                        const SizedBox(height: 12),
                        TextField(
                          key: const Key('auth_email_field'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            hintText: AppStrings.authEmailHint,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('auth_password_field'),
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: AppStrings.authPasswordHint,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (!_isLogin) ...[
                        const SizedBox(height: 12),
                        TextField(
                          key: const Key('auth_confirm_field'),
                          controller: _confirmController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: AppStrings.authConfirmPasswordHint,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                      const SizedBox(height: 16),
                      FilledButton(
                        key: const Key('auth_submit_button'),
                        onPressed: _submit,
                        child: Text(button),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          key: const Key('auth_toggle_mode_button'),
                          onPressed: () => _setMode(!_isLogin),
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
      ),
    );
  }
}
