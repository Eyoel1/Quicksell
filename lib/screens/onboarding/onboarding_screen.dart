import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_done') ?? false;
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  late AnimationController _iconCtrl;
  late Animation<double> _iconScale;

  static const _pages = [
    _OnboardingPage(
      gradient: [Color(0xFF1A237E), Color(0xFF2979FF)],
      icon: Icons.storefront_rounded,
      title: 'Your local\nmarketplace',
      subtitle:
          'Browse thousands of items listed by people in your community. Great deals, just around the corner.',
    ),
    _OnboardingPage(
      gradient: [Color(0xFF4A148C), Color(0xFF7C3AED)],
      icon: Icons.sell_rounded,
      title: 'Sell anything\nin seconds',
      subtitle:
          'Snap a photo, set a price, and post your listing in under a minute. Turn clutter into cash.',
    ),
    _OnboardingPage(
      gradient: [Color(0xFF004D40), Color(0xFF059669)],
      icon: Icons.chat_bubble_rounded,
      title: 'Chat safely\nwith buyers',
      subtitle:
          'Message sellers, negotiate prices, and arrange meetups — all inside the app.',
    ),
    _OnboardingPage(
      gradient: [Color(0xFF0D47A1), Color(0xFF0284C7)],
      icon: Icons.local_offer_rounded,
      title: 'Get exclusive\ndeals',
      subtitle:
          'Sellers send special discounts directly to you. Save on items you love before they\'re gone.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _iconScale = CurvedAnimation(parent: _iconCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _iconCtrl.reset();
    _iconCtrl.forward();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await OnboardingScreen.markSeen();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: page.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.outfit(
                        color: Colors.white60,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (_, index) {
                    final p = _pages[index];
                    final isActive = index == _currentPage;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated icon
                          if (isActive)
                            ScaleTransition(
                              scale: _iconScale,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  p.icon,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(p.icon, size: 60, color: Colors.white),
                            ),
                          const SizedBox(height: 48),
                          Text(
                            p.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            p.subtitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white70,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Dots + button
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
                child: Column(
                  children: [
                    // Page dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final active = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.white
                                : Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                    // Next / Get Started button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: page.gradient.last,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isLast ? 'Get Started' : 'Next',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final List<Color> gradient;
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
