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
  final double radius, opacity, driftX, driftY, phaseOffset;

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
  _Blob(color: Color(0xFF2979FF), xFrac: 0.18, yFrac: 0.20, radius: 220, opacity: 0.50, driftX: 40, driftY: 30, phaseOffset: 0.0),
  _Blob(color: Color(0xFF7C3AED), xFrac: 0.80, yFrac: 0.15, radius: 185, opacity: 0.42, driftX: 28, driftY: 48, phaseOffset: 1.4),
  _Blob(color: Color(0xFF059669), xFrac: 0.50, yFrac: 0.06, radius: 160, opacity: 0.35, driftX: 52, driftY: 22, phaseOffset: 2.8),
  _Blob(color: Color(0xFF4A9EFF), xFrac: 0.90, yFrac: 0.58, radius: 195, opacity: 0.28, driftX: 20, driftY: 52, phaseOffset: 4.2),
  _Blob(color: Color(0xFF6D28D9), xFrac: 0.06, yFrac: 0.75, radius: 168, opacity: 0.26, driftX: 36, driftY: 36, phaseOffset: 5.0),
];

class _AuroraPainter extends CustomPainter {
  final double t;
  _AuroraPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in _blobs) {
      final a = t * 2 * math.pi + b.phaseOffset;
      final cx = b.xFrac * size.width + math.sin(a) * b.driftX;
      final cy = b.yFrac * size.height + math.cos(a) * b.driftY;
      final c = Offset(cx, cy);
      canvas.drawCircle(
        c,
        b.radius,
        Paint()
          ..shader = RadialGradient(
            colors: [b.color.withOpacity(b.opacity), b.color.withOpacity(0)],
          ).createShader(Rect.fromCircle(center: c, radius: b.radius)),
      );
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
  _OrbData(icon: Icons.checkroom_rounded,     glowColor: Color(0xFFDB2777), xFrac: 0.08, size: 68, speed: 7,  phase: 0.05, spinSpeed: 1.3),
  _OrbData(icon: Icons.devices_rounded,        glowColor: Color(0xFF0284C7), xFrac: 0.80, size: 80, speed: 9,  phase: 0.2,  spinSpeed: 0.8),
  _OrbData(icon: Icons.menu_book_rounded,      glowColor: Color(0xFF7C3AED), xFrac: 0.25, size: 58, speed: 6,  phase: 0.4,  spinSpeed: 1.7),
  _OrbData(icon: Icons.home_rounded,           glowColor: Color(0xFF059669), xFrac: 0.62, size: 72, speed: 8,  phase: 0.55, spinSpeed: 1.1),
  _OrbData(icon: Icons.sports_soccer_rounded,  glowColor: Color(0xFFDC2626), xFrac: 0.44, size: 62, speed: 5,  phase: 0.72, spinSpeed: 1.9),
  _OrbData(icon: Icons.inventory_2_rounded,    glowColor: Color(0xFFD97706), xFrac: 0.14, size: 52, speed: 10, phase: 0.88, spinSpeed: 1.2),
  _OrbData(icon: Icons.credit_card_rounded,    glowColor: Color(0xFF4A9EFF), xFrac: 0.88, size: 64, speed: 7,  phase: 0.3,  spinSpeed: 0.9),
  _OrbData(icon: Icons.location_on_rounded,    glowColor: Color(0xFFE11D48), xFrac: 0.35, size: 76, speed: 8,  phase: 0.65, spinSpeed: 1.4),
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
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.80, end: 1.0).animate(
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
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF2979FF)
                    .withOpacity(0.22 * _pulse.value),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2979FF)
                      .withOpacity(0.22 * _pulse.value),
                  blurRadius: 30 * _pulse.value,
                  spreadRadius: 6 * _pulse.value,
                ),
              ],
            ),
          ),
          // Inner ring
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF2979FF)
                    .withOpacity(0.36 * _pulse.value),
                width: 1,
              ),
            ),
          ),
          // Icon container
          Container(
            width: 64,
            height: 64,
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
            child: const Icon(Icons.person_add_rounded,
                color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Signup Screen
// ─────────────────────────────────────────────────────────────────────────────

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with TickerProviderStateMixin {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passCtrl;
  late TextEditingController _confirmCtrl;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreed = false;
  bool _loading = false;

  late AnimationController _auroraCtrl;
  late AnimationController _formCtrl;
  late Animation<Offset> _formSlide;
  late Animation<double> _formFade;
  late AnimationController _staggerCtrl;
  late List<Animation<double>> _fieldFades;
  late List<Animation<Offset>> _fieldSlides;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _passCtrl = TextEditingController();
    _confirmCtrl = TextEditingController();

    _auroraCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _formCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formCtrl, curve: Curves.easeOutCubic));
    _formFade = CurvedAnimation(parent: _formCtrl, curve: Curves.easeOut);

    // Staggered field entrance — 6 items: name, email, pass, confirm, terms, button
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    const fieldCount = 6;
    _fieldFades = [];
    _fieldSlides = [];
    for (int i = 0; i < fieldCount; i++) {
      final start = i * 0.12;
      final end = (start + 0.45).clamp(0.0, 1.0);
      final interval = CurvedAnimation(
        parent: _staggerCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
      _fieldFades.add(interval);
      _fieldSlides.add(
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
            .animate(interval),
      );
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _formCtrl.forward();
        Future.delayed(const Duration(milliseconds: 280), () {
          if (mounted) _staggerCtrl.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _auroraCtrl.dispose();
    _formCtrl.dispose();
    _staggerCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty ||
        _confirmCtrl.text.isEmpty) {
      _snack('Please fill in all fields');
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      _snack('Passwords do not match');
      return;
    }
    if (!_agreed) {
      _snack('Please agree to the Terms & Conditions');
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await ref.read(signUpProvider({
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
        'displayName': _nameCtrl.text.trim(),
      }).future);
      if (result != null && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else if (mounted) {
        _snack('Signup failed. Please try again.');
      }
    } catch (e) {
      if (mounted) _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

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
                    Color(0xFF07101E),
                    Color(0xFF0C1630),
                    Color(0xFF080D22),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [0.0, 0.5, 1.0],
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
                  height: sh * 0.25,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _PulsingLogo(),
                      const SizedBox(height: 12),
                      Text(
                        'Create Account',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Join QuickSell today',
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
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F8FF),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(36),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding:
                              const EdgeInsets.fromLTRB(28, 20, 28, 32),
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
                              const SizedBox(height: 20),

                              // Full Name
                              _staggered(
                                0,
                                _field(
                                  controller: _nameCtrl,
                                  hint: 'Full Name',
                                  icon: Icons.person_outline_rounded,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Email
                              _staggered(
                                1,
                                _field(
                                  controller: _emailCtrl,
                                  hint: 'Email address',
                                  icon: Icons.email_outlined,
                                  keyboard: TextInputType.emailAddress,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Password
                              _staggered(
                                2,
                                _field(
                                  controller: _passCtrl,
                                  hint: 'Password',
                                  icon: Icons.lock_outline_rounded,
                                  obscure: _obscurePass,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscurePass
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF667085),
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscurePass = !_obscurePass),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Confirm Password
                              _staggered(
                                3,
                                _field(
                                  controller: _confirmCtrl,
                                  hint: 'Confirm password',
                                  icon: Icons.lock_outline_rounded,
                                  obscure: _obscureConfirm,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscureConfirm
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF667085),
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscureConfirm = !_obscureConfirm),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Terms checkbox
                              _staggered(
                                4,
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _agreed = !_agreed),
                                  child: Row(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 200),
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: _agreed
                                              ? const Color(0xFF2979FF)
                                              : Colors.white,
                                          border: Border.all(
                                            color: _agreed
                                                ? const Color(0xFF2979FF)
                                                : const Color(0xFFE4EAF3),
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: _agreed
                                            ? const Icon(
                                                Icons.check_rounded,
                                                color: Colors.white,
                                                size: 14,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'I agree to the Terms & Conditions',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: const Color(0xFF667085),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Create Account button
                              _staggered(
                                5,
                                SizedBox(
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed:
                                        _loading ? null : _handleSignUp,
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
                                            'Create Account',
                                            style: GoogleFonts.outfit(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Sign In link
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: const Color(0xFF667085),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Text(
                                      'Sign In',
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

  Widget _staggered(int i, Widget child) {
    if (i >= _fieldFades.length) return child;
    return FadeTransition(
      opacity: _fieldFades[i],
      child: SlideTransition(position: _fieldSlides[i], child: child),
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
