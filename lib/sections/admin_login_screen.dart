import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signIn(_email.text.trim(), _password.text.trim());
      if (mounted) Navigator.pop(context);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Authentication Failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = ref.watch(backendOfflineProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'PORTFOLIO CONTROL SYSTEM',
          style: GoogleFonts.interTight(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: AppColors.textMuted,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Meta Badge
                Row(
                  children: [
                    Container(width: 6, height: 6, color: AppColors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'SECURE ADMIN ACCESS',
                      style: GoogleFonts.interTight(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: AppColors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Extended Heading
                Text(
                  'SIGN IN',
                  style: GoogleFonts.unbounded(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter master credentials to enable live inline canvas editing.',
                  style: GoogleFonts.interTight(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Backend Offline Warning Notice
                if (isOffline) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.amber),
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_off, size: 16, color: AppColors.amber),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'BACKEND OFFLINE: Supabase may be paused. Edits cannot be saved until Supabase is active.',
                            style: GoogleFonts.interTight(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.amber,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Email Field
                TextField(
                  controller: _email,
                  style: GoogleFonts.interTight(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'ADMIN EMAIL',
                    labelStyle: GoogleFonts.interTight(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1.2),
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textMuted, size: 18),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: _password,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.interTight(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'SECRET PASSWORD',
                    labelStyle: GoogleFonts.interTight(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1.2),
                    prefixIcon: const Icon(Icons.key_outlined, color: AppColors.textMuted, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Sign In Button
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.amber))
                    : InkWell(
                        onTap: _login,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.amber,
                            borderRadius: BorderRadius.circular(AppTheme.radius),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'AUTHENTICATE & ENTER',
                                style: GoogleFonts.interTight(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 14, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
