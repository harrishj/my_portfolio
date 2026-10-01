import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/theme/app_theme.dart';
import 'package:portfolio/widgets/nav_bar.dart';
import 'package:portfolio/sections/hero_section.dart';
import 'package:portfolio/sections/about_section.dart';
import 'package:portfolio/sections/tech_stack_section.dart';
import 'package:portfolio/sections/experience_section.dart';
import 'package:portfolio/sections/projects_section.dart';
import 'package:portfolio/sections/contact_section.dart';
import 'package:portfolio/sections/footer_section.dart';
import 'package:portfolio/widgets/app_loading_screen.dart';
import 'package:portfolio/providers/app_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    // ignore: deprecated_member_use
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const ProviderScope(child: PortfolioApp()));
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harrish | Full Stack Flutter Engineer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const PortfolioHome(),
    );
  }
}

class PortfolioHome extends ConsumerStatefulWidget {
  const PortfolioHome({super.key});

  @override
  ConsumerState<PortfolioHome> createState() => _PortfolioHomeState();
}

class _PortfolioHomeState extends ConsumerState<PortfolioHome> {
  final ScrollController _scrollController = ScrollController();
  static const double _navbarHeight = 64.0;

  final List<GlobalKey> _sectionKeys = List.generate(6, (_) => GlobalKey());

  final List<String> _sectionNames = [
    'Home',
    'About',
    'Stack',
    'Journey',
    'Work',
    'Contact',
  ];

  int _currentIndex = 0;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _scrollToSection(int index) {
    if (index < 0 || index >= _sectionKeys.length) return;
    final context = _sectionKeys[index].currentContext;
    if (context != null) {
      _isScrolling = true;
      setState(() => _currentIndex = index);

      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final position = renderBox.localToGlobal(Offset.zero);
        final currentOffset = _scrollController.offset;
        final targetOffset = (currentOffset + position.dy - (_navbarHeight + 16.0)).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );

        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        ).then((_) {
          _isScrolling = false;
          if (mounted) {
            setState(() => _currentIndex = index);
          }
        });
      }
    }
  }

  void _onScroll() {
    if (_isScrolling) return;
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentOffset = _scrollController.offset;

    if (currentOffset >= maxScroll - 40) {
      final lastIndex = _sectionKeys.length - 1;
      if (_currentIndex != lastIndex && mounted) {
        setState(() => _currentIndex = lastIndex);
      }
      return;
    }

    const spyLine = _navbarHeight + 110.0;
    int detectedIndex = -1;
    double minDistanceToSpyLine = double.infinity;

    for (int i = 0; i < _sectionKeys.length; i++) {
      final context = _sectionKeys[i].currentContext;
      if (context == null) continue;

      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) continue;

      final position = renderBox.localToGlobal(Offset.zero);
      final top = position.dy;
      final bottom = top + renderBox.size.height;

      if (top <= spyLine && bottom > spyLine) {
        detectedIndex = i;
        break;
      }

      final distance = (top - spyLine).abs();
      if (distance < minDistanceToSpyLine) {
        minDistanceToSpyLine = distance;
        detectedIndex = i;
      }
    }

    if (detectedIndex != -1 && detectedIndex != _currentIndex && mounted) {
      setState(() {
        _currentIndex = detectedIndex;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSection({required Widget child, required int index}) {
    return Container(
      key: _sectionKeys[index],
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    final isOffline = ref.watch(backendOfflineProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Scrollable Portfolio Canvas (Clean deep charcoal, no particles or galaxies)
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: _navbarHeight),

                  // Admin Backend Offline Persistent Warning Banner
                  if (isAdmin && isOffline)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      color: AppColors.amber,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off, size: 16, color: Colors.black),
                          const SizedBox(width: 8),
                          Text(
                            'BACKEND OFFLINE — Running on bundled snapshot. Edits cannot be saved until Supabase wakes up.',
                            style: GoogleFonts.interTight(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 0. Hero Section
                  _buildSection(
                    index: 0,
                    child: HeroSection(
                      onViewProjects: () => _scrollToSection(4),
                      onContactMe: () => _scrollToSection(5),
                    ),
                  ),

                  // 1. About & Philosophy (01 / ABOUT)
                  _buildSection(
                    index: 1,
                    child: const AboutSection(),
                  ),

                  // 2. Tech Stack & Skills (02 / STACK)
                  _buildSection(
                    index: 2,
                    child: const TechStackSection(),
                  ),

                  // 3. Experience & Credentials (03 / EXPERIENCE)
                  _buildSection(
                    index: 3,
                    child: const ExperienceSection(),
                  ),

                  // 4. Projects Showcase (04 / WORK)
                  _buildSection(
                    index: 4,
                    child: const ProjectsSection(),
                  ),

                  // 5. Contact Section (05 / CONTACT - Inverted Sand Band)
                  _buildSection(
                    index: 5,
                    child: const ContactSection(),
                  ),

                  // 6. Minimal Footer
                  FooterSection(
                    onScrollToTop: () => _scrollToSection(0),
                  ),
                ],
              ),
            ),
          ),

          // Thin Top Navigation Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NavBar(
              sections: _sectionNames,
              currentIndex: _currentIndex,
              onSectionTap: _scrollToSection,
            ),
          ),

          // Architectural Loading & Initialization Overlay
          const Positioned.fill(
            child: AppLoadingScreen(),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
              icon: const Icon(Icons.check, color: Colors.black),
              label: Text(
                'EXIT EDIT MODE',
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              onPressed: () => ref.read(authServiceProvider).signOut(),
            )
          : null,
    );
  }
}
