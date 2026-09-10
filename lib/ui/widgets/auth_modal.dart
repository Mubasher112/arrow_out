import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import '../../services/auth_service.dart';
import '../../services/sync_service.dart';
import '../theme/app_theme.dart';

class AuthModal extends StatefulWidget {
  final AuthService authService;
  final SyncService syncService;
  final AudioService audioService;
  final VoidCallback? onAuthSuccess;

  const AuthModal({
    super.key,
    required this.authService,
    required this.syncService,
    required this.audioService,
    this.onAuthSuccess,
  });

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  bool _isLoading = false;

  Future<void> _handleSignIn(Future<void> Function() authAction) async {
    setState(() => _isLoading = true);
    widget.audioService.playSound(SoundType.buttonClick);

    try {
      await authAction();
      await widget.syncService.sync();
      if (mounted) {
        Navigator.of(context).pop();
        widget.onAuthSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: AppTheme.accent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: AppTheme.bgLight,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cloud Save Account',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 20),
            const Text(
              'Create an account to backup your levels, stars, and coins across devices.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              )
            else ...[
              // Google Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 28, color: Colors.red),
                  label: const Text('Sign in with Google', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _handleSignIn(() => widget.authService.signInWithGoogle()),
                ),
              ),

              const SizedBox(height: 10),

              // Apple Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.apple_rounded, size: 24),
                  label: const Text('Sign in with Apple', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _handleSignIn(() => widget.authService.signInWithApple()),
                ),
              ),

              const SizedBox(height: 10),

              // Facebook Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.facebook_rounded, size: 24),
                  label: const Text('Sign in with Facebook', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _handleSignIn(() => widget.authService.signInWithFacebook()),
                ),
              ),

              const SizedBox(height: 12),

              // Guest Option
              TextButton(
                child: const Text('Continue as Guest', style: TextStyle(color: Colors.white60)),
                onPressed: () => _handleSignIn(() => widget.authService.playAsGuest()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
