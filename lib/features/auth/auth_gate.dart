import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/onboarding_prefs.dart';
import '../../shared/widgets/main_layout.dart';
import 'welcome_screen.dart';

/// Widget gerbang di root navigasi. Logic:
/// - Kalau user udah login (dari awal, atau baru login di tengah jalan lewat
///   Settings) -> langsung MainLayout, gak pernah tampilin WelcomeScreen lagi.
/// - Kalau belum login TAPI udah pernah pilih Guest sebelumnya -> MainLayout.
/// - Kalau belum login DAN belum pernah pilih apa-apa -> WelcomeScreen.
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool? _hasChosenGuest;

  @override
  void initState() {
    super.initState();
    _checkGuestMode();
  }

  Future<void> _checkGuestMode() async {
    final chosen = await OnboardingPrefs.hasChosenGuestMode();
    if (mounted) setState(() => _hasChosenGuest = chosen);
  }

  @override
  Widget build(BuildContext context) {
    // Watch (bukan read) -- supaya begitu user login di tengah jalan lewat
    // Settings (dari mode guest), AuthGate ini otomatis rebuild dan pindah
    // ke MainLayout tanpa perlu restart app.
    final user = ref.watch(currentUserProvider);

    if (user != null) {
      return const MainLayout();
    }

    if (_hasChosenGuest == null) {
      // Masih ngecek shared_preferences, sebentar doang
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_hasChosenGuest == true) {
      return const MainLayout();
    }

    return WelcomeScreen(
      onContinueAsGuest: () {
        setState(() => _hasChosenGuest = true);
      },
    );
  }
}
