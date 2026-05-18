import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_strings.dart';
import 'controllers/analytics_controller.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/story_home_page.dart';
import 'state/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Web often hits WebChannel/firewall issues → `unavailable`; long-polling is
  // much more reliable on shared / campus networks.
  if (kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      webExperimentalForceLongPolling: true,
    );
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => AnalyticsController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthState _authState = AuthState();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    // Wait for both the splash animation and the Firebase auth check.
    Future.wait<void>([
      _authState.loadCurrentUser(),
      Future<void>.delayed(const Duration(milliseconds: 1800)),
    ]).then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
    });
  }

  void _handleAuthenticated() => setState(() {});

  void _handleLogout() {
    // Fire-and-forget: signOut clears the session, then rebuild.
    _authState.logout().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    const scaffoldWarm = Color(0xFFF3F1EC);
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2A6B45),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: scaffoldWarm,
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 2,
          backgroundColor: scheme.inversePrimary,
          surfaceTintColor: Colors.transparent,
          foregroundColor: scheme.onSurface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: scheme.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: scheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: scheme.error, width: 1.5),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: scheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          clipBehavior: Clip.antiAlias,
        ),
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (!_ready) return const SplashScreen();

    if (_authState.currentUser == null) {
      return AuthScreen(
        authState: _authState,
        onAuthenticated: _handleAuthenticated,
      );
    }

    return StoryHomePage(
      authState: _authState,
      currentUser: _authState.currentUser!,
      onLogout: _handleLogout,
    );
  }
}
