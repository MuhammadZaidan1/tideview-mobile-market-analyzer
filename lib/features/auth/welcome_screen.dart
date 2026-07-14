import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/onboarding_prefs.dart';
import '../../core/services/supabase_service.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onContinueAsGuest;

  const WelcomeScreen({super.key, required this.onContinueAsGuest});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;

  Future<void> _handleGuestMode() async {
    setState(() => _isLoading = true);
    await OnboardingPrefs.setChosenGuestMode();
    widget.onContinueAsGuest();
  }

  Future<void> _handleLogin(Future<void> Function() loginFn) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      await loginFn();
      // Setelah ini, AuthGate yang watch currentUserProvider bakal otomatis
      // navigasi ke MainLayout begitu sesi login berhasil ke-set.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.loginFailed}: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Icon(
                Icons.show_chart_rounded,
                size: 72,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.welcomeTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.welcomeSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const Spacer(flex: 3),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: CircularProgressIndicator(),
                )
              else ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _handleGuestMode,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l10n.continueAsGuest,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleLogin(signInWithGoogle),
                    icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                    label: Text(l10n.continueWithGoogle),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleLogin(signInWithGithub),
                    icon: const Icon(Icons.code_rounded, size: 22),
                    label: Text(l10n.continueWithGithub),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
