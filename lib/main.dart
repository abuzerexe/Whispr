import 'dart:async';

import 'package:flutter/material.dart';

import 'constants/app_strings.dart';
import 'data/seed_users.dart';
import 'screens/auth_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/story_home_page.dart';
import 'state/auth_state.dart';

void main() {
  runApp(const MyApp(seedDemoData: true));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    this.seedDemoData = false,
    this.skipSplash = false,
    this.skipAuth = false,
  });

  final bool seedDemoData;
  final bool skipSplash;
  final bool skipAuth;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthState _authState;
  bool _showSplash = true;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _authState = AuthState(seededUsers: buildSeedUsers());
    _showSplash = !widget.skipSplash;
    if (widget.skipAuth) {
      _authState.currentUser = _authState.users.first;
    }
    if (_showSplash) {
      _splashTimer = Timer(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        setState(() => _showSplash = false);
      });
    }
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  void _handleAuthenticated() {
    setState(() {});
  }

  void _handleLogout() {
    _authState.logout();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2A6B45),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F1EC),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
        ),
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_showSplash) {
      return const SplashScreen();
    }

    if (_authState.currentUser == null) {
      return AuthScreen(
        authState: _authState,
        onAuthenticated: _handleAuthenticated,
      );
    }

    return StoryHomePage(
      authState: _authState,
      currentUser: _authState.currentUser!,
      seedDemoData: widget.seedDemoData,
      onLogout: _handleLogout,
    );
  }
}
