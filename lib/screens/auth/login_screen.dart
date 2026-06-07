import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';
import '../../providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Aurora blob data
// ─────────────────────────────────────────────────────────────────────────────

class _Blob {
  final Color color;
  final double xFrac, yFrac;
  final double radius;
  final double opacity;
  final double driftX, driftY;
  final double phaseOffset;

  const _Blob({
    required this.color,
    required this.xFrac,
    required this.yFrac,
    required this.radius,
    required this.opacity,
    required this.driftX,
    required this.driftY,
    required this.phaseOffset,
  });
}

const _blobs = [
  _Blob(color: Color(0xFF2979FF), xFrac: 0.15, yFrac: 0.22, radius: 230, opacity: 0.55, driftX: 45, driftY: 35, phaseOffset: 0.0),
  _Blob(color: Color(0xFF7C3AED), xFrac: 0.82, yFrac: 0.18, radius: 190, opacity: 0.45, driftX: 30, driftY: 50, phaseOffset: 1.2),
  _Blob(color: Color(0xFF0284C7), xFrac: 0.50, yFrac: 0.08, radius: 170, opacity: 0.38, driftX: 55, driftY: 25, phaseOffset: 2.4),
  _Blob(color: Color(0xFF4A9EFF), xFrac: 0.92, yFrac: 0.55, radius: 200, opacity: 0.30, driftX: 22, driftY: 55, phaseOffset: 3.6),
  _Blob(color: Color(0xFF5B21B6), xFrac: 0.08, yFrac: 0.72, radius: 175, opacity: 0.28, driftX: 38, driftY: 38, phaseOffset: 4.8),
];

class _AuroraPainter extends CustomPainter {
  final double t;
  _AuroraPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in _blobs) {
      final angle = t * 2 * math.pi + b.phaseOffset;
      final cx = b.xFrac * size.width + math.sin(angle) * b.driftX;
      final cy = b.yFrac * size.height + math.cos(angle) * b.driftY;
      final center = Offset(cx, cy);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [b.color.withOpacity(b.opacity), b.color.withOpacity(0)],
        ).createShader(Rect.fromCircle(center: center, radius: b.radius));
      canvas.drawCircle(center, b.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// Hexagonal grid overlay  (replaces dot grid)
// ─────────────────────────────────────────────────────────────────────────────

class _HexGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const r = 22.0;
    final h = r * math.sqrt(3);
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (double row = -r; row < size.height + r; row += h) {
      for (double col = -r; col < size.width + r; col += r * 3) {
        _hex(canvas, paint, Offset(col, row), r);
        _hex(canvas, paint, Offset(col + r * 1.5, row + h / 2), r);
      }
    }
  }

  void _hex(Canvas canvas, Paint paint, Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      final p = Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HexGridPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Spinning arc painter
// ─────────────────────────────────────────────────────────────────────────────

class _SpinningArcPainter extends CustomPainter {
  final Color color;
  final double progress;
  const _SpinningArcPainter(this.color, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1.5;

    // Dim track circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Bright rotating arc (120 degrees)
    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: [
          color.withOpacity(0),
          color.withOpacity(0.9),
          color.withOpacity(0.4),
          color.withOpacity(0),
        ],
        stops: const [0.0, 0.25, 0.5, 1.0],
        transform: GradientRotation(progress * 2 * math.pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      progress * 2 * math.pi - math.pi / 2,
      2 * math.pi / 3, // 120-degree arc
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_SpinningArcPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Orbital orb data
// ─────────────────────────────────────────────────────────────────────────────

class _OrbData {
  final IconData icon;
  final Color glowColor;
  final double xFrac;
  final double size;
  final double speed;
  final double phase;
  final double spinSpeed;

  const _OrbData({
    required this.icon,
    required this.glowColor,
    required this.xFrac,
    required this.size,
    required this.speed,
    required this.phase,
    this.spinSpeed = 1.0,
  });
}

const _orbs = [
  _OrbData(icon: Icons.phone_android_rounded,  glowColor: Color(0xFF7C3AED), xFrac: 0.07, size: 72, speed: 7,  phase: 0.0,  spinSpeed: 1.4),
  _OrbData(icon: Icons.laptop_rounded,          glowColor: Color(0xFF0284C7), xFrac: 0.82, size: 84, speed: 9,  phase: 0.15, spinSpeed: 0.8),
  _OrbData(icon: Icons.shopping_bag_rounded,    glowColor: Color(0xFF2979FF), xFrac: 0.22, size: 60, speed: 6,  phase: 0.35, spinSpeed: 1.6),
  _OrbData(icon: Icons.chair_rounded,           glowColor: Color(0xFFD97706), xFrac: 0.65, size: 78, speed: 8,  phase: 0.5,  spinSpeed: 1.0),
  _OrbData(icon: Icons.camera_alt_rounded,      glowColor: Color(0xFF059669), xFrac: 0.44, size: 64, speed: 5,  phase: 0.7,  spinSpeed: 1.8),
  _OrbData(icon: Icons.headphones_rounded,      glowColor: Color(0xFFDB2777), xFrac: 0.14, size: 52, speed: 11, phase: 0.85, spinSpeed: 1.2),
  _OrbData(icon: Icons.watch_rounded,           glowColor: Color(0xFF4A9EFF), xFrac: 0.90, size: 68, speed: 7,  phase: 0.2,  spinSpeed: 0.9),
  _OrbData(icon: Icons.sell_rounded,            glowColor: Color(0xFF10B981), xFrac: 0.36, size: 56, speed: 8,  phase: 0.6,  spinSpeed: 1.5),
];

// ─────────────────────────────────────────────────────────────────────────────
// Floating orb widget
// ─────────────────────────────────────────────────────────────────────────────

class _FloatingOrb extends StatefulWidget {
  final _OrbData data;
  const _FloatingOrb({required this.data});

  @override
  State<_FloatingOrb> createState() => _FloatingOrbState();
}

class _FloatingOrbState extends State<_FloatingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.data.speed * 1000).round()),
    );
    _ctrl.value = widget.data.phase;
    _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final s = widget.data.size;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final progress = _ctrl.value;
        final y = sh * 1.08 - progress * (sh * 1.3);
        final x = widget.data.xFrac * sw +
            math.sin(progress * 2 * math.pi + widget.data.phase * math.pi) * 18;
        final tilt =
            math.sin(progress * math.pi * 2.2 + widget.data.phase) * 0.10;
        final arcProgress = (progress * widget.data.spinSpeed) % 1.0;

        return Positioned(
          left: x - (s + 28) / 2,
          top: y - 14,
          child: Transform.rotate(
            angle: tilt,
            child: Opacity(
              opacity: 0.88,
              child: SizedBox(
                width: s + 28,
                height: s + 28,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Spinning arc
                    CustomPaint(
                      size: Size(s + 24, s + 24),
                      painter: _SpinningArcPainter(
                          widget.data.glowColor, arcProgress),
                    ),
                    // Glow halo
                    Container(
                      width: s + 4,
                      height: s + 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.data.glowColor.withOpacity(0.40),
                            blurRadius: s * 0.5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    // Orb body
                    Container(
                      width: s,
                      height: s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            widget.data.glowColor.withOpacity(0.28),
                            widget.data.glowColor.withOpacity(0.07),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                        border: Border.all(
                          color: widget.data.glowColor.withOpacity(0.35),
                          width: 1.0,
                        ),
                      ),
                      child: Icon(
                        widget.data.icon,
                        color: widget.data.glowColor,
                        size: s * 0.44,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pulsing logo
// ─────────────────────────────────────────────────────────────────────────────

class _PulsingLogo extends StatefulWidget {
  const _PulsingLogo();

  @override
  State<_PulsingLogo> createState() => _PulsingLogoState();
}

class _PulsingLogoState extends State<_PulsingLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      const Color(0xFF2979FF).withOpacity(0.25 * _pulse.value),
                  blurRadius: 32 * _pulse.value,
                  spreadRadius: 8 * _pulse.value,
                ),
              ],
              border: Border.all(
                color: const Color(0xFF2979FF)
                    .withOpacity(0.25 * _pulse.value),
                width: 1.5,
              ),
            ),
          ),
          // Inner ring
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF2979FF)
                    .withOpacity(0.40 * _pulse.value),
                width: 1,
              ),
            ),
          ),
          // Icon container
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2979FF), Color(0xFF4A9EFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2979FF).withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.shopping_bag_rounded,
                color: Colors.white, size: 36),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Login Screen
// ─────────────────────────────────────────────────────────────────────────────

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late TextEditingController _emailCtrl;
  late TextEditingController _passCtrl;
  bool _obscure = true;
  bool _loading = false;

  late AnimationController _auroraCtrl;
  late AnimationController _formCtrl;
  late Animation<Offset> _formSlide;
  late Animation<double> _formFade;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController();
    _passCtrl = TextEditingController();

    _auroraCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _formCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formCtrl, curve: Curves.easeOutCubic));
    _formFade = CurvedAnimation(parent: _formCtrl, curve: Curves.easeOut);

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _formCtrl.forward();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _auroraCtrl.dispose();
    _formCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      _snack('Please fill in all fields');
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await ref
          .read(loginProvider({'email': email, 'password': pass}).future);
      if (result != null && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else if (mounted) {
        _snack('Login failed. Check your credentials.');
      }
    } catch (e) {
      if (mounted) _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. Base dark gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF070B1A),
                    Color(0xFF0E1535),
                    Color(0xFF0A0F28),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // 2. Aurora blobs
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _auroraCtrl,
              builder: (_, __) => CustomPaint(
                painter: _AuroraPainter(_auroraCtrl.value),
              ),
            ),
          ),

          // 3. Hexagonal grid overlay
          Positioned.fill(
            child: CustomPaint(painter: _HexGridPainter()),
          ),

          // 4. Floating orbital orbs
          ..._orbs.map((d) => _FloatingOrb(data: d)),

          // 5. Logo + form
          SafeArea(
            child: Column(
              children: [
                // Logo area
                SizedBox(
                  height: sh * 0.30,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _PulsingLogo(),
                      const SizedBox(height: 16),
                      Text(
                        'QuickSell',
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your Local Marketplace',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form card (slides up)
                Expanded(
                  child: SlideTransition(
                    position: _formSlide,
                    child: FadeTransition(
                      opacity: _formFade,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F8FF),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(36),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding:
                              const EdgeInsets.fromLTRB(28, 32, 28, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Handle bar
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Welcome back',
                                style: GoogleFonts.outfit(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF101828),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sign in to continue',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF667085),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Email field
                              _field(
                                controller: _emailCtrl,
                                hint: 'Email address',
                                icon: Icons.email_outlined,
                                keyboard: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 14),

                              // Password field
                              _field(
                                controller: _passCtrl,
                                hint: 'Password',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscure,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF667085),
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Sign In button
                              SizedBox(
                                height: 54,
                                child: ElevatedButton(
                                  onPressed:
                                      _loading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF2979FF),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Sign In',
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Sign Up link
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: const Color(0xFF667085),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                        context, AppRoutes.signup),
                                    child: Text(
                                      'Sign Up',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF2979FF),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF101828)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF)),
        prefixIcon: Icon(icon, color: const Color(0xFF667085), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFEAF1FF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFE4EAF3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFF2979FF), width: 2),
        ),
      ),
    );
  }
}
