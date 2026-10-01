import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/theme/app_theme.dart';
import 'package:portfolio/providers/app_providers.dart';

/// A sleek, architectural loading screen matching the NIKI Studio minimalist aesthetic.
/// Plays a smooth telemetry animation and gracefully dissolves once Supabase data is loaded.
class AppLoadingScreen extends ConsumerStatefulWidget {
  final VoidCallback? onLoaded;

  const AppLoadingScreen({super.key, this.onLoaded});

  @override
  ConsumerState<AppLoadingScreen> createState() => _AppLoadingScreenState();
}

class _AppLoadingScreenState extends ConsumerState<AppLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Timer? _statusTicker;
  Timer? _safetyTimeout;
  int _statusIndex = 0;
  bool _isExiting = false;
  bool _isRemoved = false;
  final Stopwatch _stopwatch = Stopwatch();

  static const List<String> _statusMessages = [
    'CONNECTING TO SUPABASE ENGINE...',
    'HYDRATING ARCHITECTURAL STATE...',
    'SYNCHRONIZING PRODUCTION CATALOG...',
    'COMPILING RESPONSIVE INTERFACES...',
    'SYSTEM READY',
  ];

  @override
  void initState() {
    super.initState();
    _stopwatch.start();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic),
    );

    // Dynamic telemetry status ticker
    _statusTicker = Timer.periodic(const Duration(milliseconds: 320), (timer) {
      if (!mounted) return;
      if (_statusIndex < _statusMessages.length - 2) {
        setState(() => _statusIndex++);
      }
    });

    // Safety fallback: Never keep the visitor waiting longer than 2.8s
    _safetyTimeout = Timer(const Duration(milliseconds: 2800), () {
      if (mounted && !_isExiting) {
        _triggerExit();
      }
    });
  }

  @override
  void dispose() {
    _statusTicker?.cancel();
    _safetyTimeout?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _triggerExit() {
    if (_isExiting) return;
    _isExiting = true;
    _statusTicker?.cancel();
    _safetyTimeout?.cancel();

    if (mounted) {
      setState(() {
        _statusIndex = _statusMessages.length - 1;
      });
    }

    // Minimum display threshold (e.g. 550ms) to ensure elegant entrance without flicker
    final elapsed = _stopwatch.elapsedMilliseconds;
    final remainingDelay = elapsed < 550 ? (550 - elapsed) : 80;

    Future.delayed(Duration(milliseconds: remainingDelay), () {
      if (!mounted) return;
      _animController.forward().then((_) {
        if (mounted) {
          setState(() => _isRemoved = true);
          widget.onLoaded?.call();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isRemoved) {
      return const SizedBox.shrink();
    }

    // Listen to data readiness
    final isReady = ref.watch(isAppInitializedProvider);
    if (isReady && !_isExiting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerExit();
      });
    }

    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return IgnorePointer(
      ignoring: _isExiting,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final opacity = (1.0 - _fadeAnimation.value).clamp(0.0, 1.0);
          final scale = _scaleAnimation.value;

          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.bgDark,
          child: Stack(
            children: [
              // Architectural Corner Markers (+)
              _buildCornerMarker(top: 24, left: 24),
              _buildCornerMarker(top: 24, right: 24),
              _buildCornerMarker(bottom: 24, left: 24),
              _buildCornerMarker(bottom: 24, right: 24),

              // Central Brand & Telemetry Card
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 32 : 48),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Wordmark with Pulsing Amber Dot
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'HARRISH',
                              style: GoogleFonts.unbounded(
                                fontSize: isMobile ? 26 : 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            _PulsingDot(),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          'FULL STACK FLUTTER ARCHITECT',
                          style: GoogleFonts.interTight(
                            fontSize: isMobile ? 11 : 12.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.2,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 36),

                        // Sleek Progress Line
                        ClipRRect(
                          borderRadius: BorderRadius.circular(1),
                          child: Container(
                            height: 2,
                            width: double.infinity,
                            color: AppColors.hairline,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _AnimatedProgressBar(isExiting: _isExiting),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Telemetry Status Readout & Version
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _statusMessages[_statusIndex],
                                style: GoogleFonts.interTight(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: AppColors.amber,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '2026 // v2.6',
                              style: GoogleFonts.interTight(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCornerMarker({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Text(
        '+',
        style: GoogleFonts.interTight(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: AppColors.textMuted.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

/// Subtle pulsing dot next to brand name
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, _) {
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: AppColors.amber.withValues(alpha: _glowAnimation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.amber.withValues(alpha: _glowAnimation.value * 0.6),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Smooth progress line that fills up as loading progresses
class _AnimatedProgressBar extends StatefulWidget {
  final bool isExiting;

  const _AnimatedProgressBar({required this.isExiting});

  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExiting && !oldWidget.isExiting) {
      _controller.animateTo(
        1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = widget.isExiting ? 1.0 : (_controller.value * 0.85);
        return FractionallySizedBox(
          widthFactor: progress.clamp(0.05, 1.0),
          child: Container(
            color: AppColors.amber,
          ),
        );
      },
    );
  }
}
