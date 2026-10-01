import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/theme/app_theme.dart';

class NavBar extends StatelessWidget {
  final List<String> sections;
  final Function(int) onSectionTap;
  final int currentIndex;

  const NavBar({
    super.key,
    required this.sections,
    required this.onSectionTap,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 64,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 48,
          ),
          decoration: const BoxDecoration(
            color: Color(0xEE141312),
            border: Border(
              bottom: BorderSide(
                color: AppColors.hairline,
                width: 1,
              ),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1360),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand Wordmark in Unbounded
                  GestureDetector(
                    onTap: () => onSectionTap(0),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'HARRISH',
                            style: GoogleFonts.unbounded(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 4, top: 4),
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppColors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Desktop Links or Mobile Trigger
                  if (!isMobile)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(
                          sections.length,
                          (i) => _DesktopNavLink(
                            label: sections[i].toUpperCase(),
                            indexPrefix: '0${i + 1}',
                            isActive: i == currentIndex,
                            onTap: () => onSectionTap(i),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Minimalist Contact CTA
                        _NikiContactCta(
                          onTap: () => onSectionTap(sections.length - 1),
                        ),
                      ],
                    )
                  else
                    // Mobile Hamburger Trigger
                    _MobileMenuTrigger(
                      sections: sections,
                      currentIndex: currentIndex,
                      onSectionTap: onSectionTap,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopNavLink extends StatefulWidget {
  final String label;
  final String indexPrefix;
  final bool isActive;
  final VoidCallback onTap;

  const _DesktopNavLink({
    required this.label,
    required this.indexPrefix,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_DesktopNavLink> createState() => _DesktopNavLinkState();
}

class _DesktopNavLinkState extends State<_DesktopNavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;
    final color = active
        ? AppColors.amber
        : (_hovered ? AppColors.textPrimary : AppColors.textSecondary);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.interTight(
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                      letterSpacing: 1.4,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 1.5,
                width: active ? 16 : (_hovered ? 12 : 0),
                color: AppColors.amber,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NikiContactCta extends StatefulWidget {
  final VoidCallback onTap;

  const _NikiContactCta({required this.onTap});

  @override
  State<_NikiContactCta> createState() => _NikiContactCtaState();
}

class _NikiContactCtaState extends State<_NikiContactCta> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.amber : Colors.transparent,
            border: Border.all(
              color: AppColors.amber,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "LET'S TALK",
                style: GoogleFonts.interTight(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: _hovered ? Colors.black : AppColors.amber,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward,
                size: 12,
                color: _hovered ? Colors.black : AppColors.amber,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileMenuTrigger extends StatelessWidget {
  final List<String> sections;
  final int currentIndex;
  final Function(int) onSectionTap;

  const _MobileMenuTrigger({
    required this.sections,
    required this.currentIndex,
    required this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary, size: 24),
      onPressed: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: true,
            pageBuilder: (ctx, anim, secAnim) {
              return _FullScreenMobileMenu(
                sections: sections,
                currentIndex: currentIndex,
                onSectionTap: onSectionTap,
              );
            },
            transitionsBuilder: (ctx, anim, secAnim, child) {
              return FadeTransition(opacity: anim, child: child);
            },
          ),
        );
      },
    );
  }
}

class _FullScreenMobileMenu extends StatelessWidget {
  final List<String> sections;
  final int currentIndex;
  final Function(int) onSectionTap;

  const _FullScreenMobileMenu({
    required this.sections,
    required this.currentIndex,
    required this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'HARRISH.',
                    style: GoogleFonts.unbounded(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Giant display links in Unbounded
              Expanded(
                child: ListView.separated(
                  itemCount: sections.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: AppColors.hairline,
                    height: 32,
                  ),
                  itemBuilder: (ctx, i) {
                    final isActive = i == currentIndex;
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        onSectionTap(i);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                sections[i].toUpperCase(),
                                style: GoogleFonts.unbounded(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: isActive ? AppColors.amber : AppColors.textPrimary,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '0${i + 1}',
                            style: GoogleFonts.interTight(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isActive ? AppColors.amber : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom footer note in overlay
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  'ENGINEERED WITH FLUTTER & SUPABASE',
                  style: GoogleFonts.interTight(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
