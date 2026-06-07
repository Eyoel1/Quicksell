import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme/app_theme.dart';

/// Pulsing Sell Orb - Custom FAB with pulsing animation
class PulsingSellOrb extends StatefulWidget {
  final VoidCallback onPressed;

  const PulsingSellOrb({Key? key, required this.onPressed}) : super(key: key);

  @override
  State<PulsingSellOrb> createState() => _PulsingSellOrbState();
}

class _PulsingSellOrbState extends State<PulsingSellOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: SizedBox(
        width: 70,
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing ring wave
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _PulseRingPainter(animationValue: _controller.value),
                  size: const Size(70, 70),
                );
              },
            ),
            // Main orb button
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseRingPainter extends CustomPainter {
  final double animationValue;

  _PulseRingPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.3 * (1 - animationValue))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * (0.8 + 0.4 * animationValue);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_PulseRingPainter oldDelegate) => true;
}

/// Orbit Bottom Navigation with Spring Animation
class OrbitBottomNav extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final Widget? floatingActionButton;

  const OrbitBottomNav({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  State<OrbitBottomNav> createState() => _OrbitBottomNavState();
}

class _OrbitBottomNavState extends State<OrbitBottomNav> {
  final List<_NavItem> _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.explore_rounded, label: 'Explore'),
    _NavItem(icon: Icons.favorite_rounded, label: 'Saved'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Active indicator pill with spring animation
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.elasticOut,
            left: _getIndicatorPosition(context),
            top: 16,
            child: Container(
              width: 60,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          // Nav items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              if (index == 2 && widget.floatingActionButton != null) {
                return const SizedBox(width: 70);
              }
              return _buildNavItem(index);
            }),
          ),
          // Floating action button in center
          if (widget.floatingActionButton != null)
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 35,
              top: 5,
              child: widget.floatingActionButton!,
            ),
        ],
      ),
    );
  }

  double _getIndicatorPosition(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / 4;
    int adjustedIndex = widget.selectedIndex;
    if (adjustedIndex >= 2) adjustedIndex++; // Account for FAB space
    return (itemWidth * adjustedIndex) + (itemWidth / 2) - 30;
  }

  Widget _buildNavItem(int index) {
    final isSelected = widget.selectedIndex == index;
    final item = _items[index];

    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 26,
              color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}

/// 3D Tilt Card with Shimmer Effect
class TiltCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final Color? categoryTintColor;

  const TiltCard({
    Key? key,
    required this.child,
    this.onTap,
    this.width = double.infinity,
    this.height = 280,
    this.categoryTintColor,
  }) : super(key: key);

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard>
    with SingleTickerProviderStateMixin {
  Offset? _tapPosition;
  bool _isPressed = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerController.forward();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          _tapPosition = details.localPosition;
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        Future.delayed(const Duration(milliseconds: 150), () {
          if (widget.onTap != null) widget.onTap!();
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: _isPressed ? _getTiltTransform() : Matrix4.identity(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isPressed ? AppTheme.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Category tint overlay
                if (widget.categoryTintColor != null)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.categoryTintColor!.withOpacity(0.1),
                            widget.categoryTintColor!.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Main content
                widget.child,
                // Shimmer sweep effect
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [
                            _shimmerController.value - 0.3,
                            _shimmerController.value,
                            _shimmerController.value + 0.3,
                          ].map((e) => e.clamp(0.0, 1.0)).toList(),
                          colors: const [
                            Colors.transparent,
                            Colors.white24,
                            Colors.transparent,
                          ],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.white],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Matrix4 _getTiltTransform() {
    if (_tapPosition == null) return Matrix4.identity();

    final dx = (_tapPosition!.dx - widget.width / 2) / (widget.width / 2);
    final dy = (_tapPosition!.dy - widget.height / 2) / (widget.height / 2);

    return Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(-dy * 0.1)
      ..rotateY(dx * 0.1);
  }
}

/// Staggered Grid Animation Wrapper
class StaggeredGridItem extends StatelessWidget {
  final Widget child;
  final int index;
  final int delay;

  const StaggeredGridItem({
    Key? key,
    required this.child,
    required this.index,
    this.delay = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(
          duration: const Duration(milliseconds: 400),
          delay: Duration(milliseconds: index * delay),
        )
        .slideY(
          begin: 0.1,
          end: 0,
          duration: const Duration(milliseconds: 400),
          delay: Duration(milliseconds: index * delay),
          curve: Curves.easeOutCubic,
        );
  }
}

/// Glassmorphic Container
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;

  const GlassmorphicContainer({
    Key? key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.2,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(opacity),
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        ),
        child: child,
      ),
    );
  }
}

/// Category Chip with Ambient Tint
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? tintColor;

  const CategoryChip({
    Key? key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.tintColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : (tintColor ?? AppTheme.chipBackgroundColor),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// Animated Search Bar
class AnimatedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onTap;
  final Function(String)? onChanged;

  const AnimatedSearchBar({
    Key? key,
    required this.controller,
    this.hintText = 'Search...',
    this.onTap,
    this.onChanged,
  }) : super(key: key);

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppTheme.inputFillColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused ? AppTheme.primaryColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: widget.controller,
        onTap: () {
          setState(() => _isFocused = true);
          if (widget.onTap != null) widget.onTap!();
        },
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _isFocused
                ? AppTheme.primaryColor
                : AppTheme.textSecondaryColor,
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    widget.controller.clear();
                    if (widget.onChanged != null) widget.onChanged!('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onTapOutside: (_) {
          setState(() => _isFocused = false);
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }
}

/// Price Badge with Glow
class PriceBadge extends StatelessWidget {
  final String price;
  final bool isNegotiable;

  const PriceBadge({Key? key, required this.price, this.isNegotiable = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          if (isNegotiable) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'OBO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Premium animated marketplace background for auth screens.
class AetherMarketplaceBackground extends StatefulWidget {
  final bool reverse;

  const AetherMarketplaceBackground({Key? key, this.reverse = false})
    : super(key: key);

  @override
  State<AetherMarketplaceBackground> createState() =>
      _AetherMarketplaceBackgroundState();
}

class _AetherMarketplaceBackgroundState
    extends State<AetherMarketplaceBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<_FloatingMarketToken> _tokens = [
    _FloatingMarketToken(Icons.shopping_bag_rounded, 0.12, 0.11, 0.0, 44),
    _FloatingMarketToken(Icons.local_offer_rounded, 0.78, 0.16, 1.1, 38),
    _FloatingMarketToken(Icons.chat_bubble_rounded, 0.16, 0.46, 2.0, 40),
    _FloatingMarketToken(Icons.location_on_rounded, 0.82, 0.52, 2.8, 36),
    _FloatingMarketToken(Icons.favorite_rounded, 0.22, 0.82, 3.7, 34),
    _FloatingMarketToken(Icons.inventory_2_rounded, 0.74, 0.84, 4.6, 42),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final value = widget.reverse
                ? 1 - _controller.value
                : _controller.value;

            return Stack(
              children: [
                CustomPaint(
                  painter: _AetherBackgroundPainter(value),
                  size: Size.infinite,
                ),
                ..._tokens.map((token) => _buildFloatingToken(token, value)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFloatingToken(_FloatingMarketToken token, double value) {
    final phase = (value * math.pi * 2) + token.phase;
    final offset = Offset(math.cos(phase) * 10, math.sin(phase) * 14);
    final turn = math.sin(phase) * 0.05;

    return Positioned.fill(
      child: FractionalTranslation(
        translation: Offset(token.x - 0.5, token.y - 0.5),
        child: Center(
          child: Transform.translate(
            offset: offset,
            child: Transform.rotate(
              angle: turn,
              child: Container(
                width: token.size,
                height: token.size,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor.withOpacity(0.58),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.65)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Icon(
                  token.icon,
                  color: AppTheme.primaryColor.withOpacity(0.28),
                  size: token.size * 0.48,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingMarketToken {
  final IconData icon;
  final double x;
  final double y;
  final double phase;
  final double size;

  const _FloatingMarketToken(this.icon, this.x, this.y, this.phase, this.size);
}

class _AetherBackgroundPainter extends CustomPainter {
  final double progress;

  _AetherBackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.backgroundColor,
          AppTheme.inputFillColor,
          AppTheme.backgroundColor,
        ],
      ).createShader(rect);

    canvas.drawRect(rect, paint);

    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppTheme.primaryColor.withOpacity(0.045);

    for (var i = 0; i < 4; i++) {
      final phase = progress * math.pi * 2 + i;
      final center = Offset(
        size.width * (0.2 + 0.22 * i) + math.sin(phase) * 8,
        size.height * (0.18 + 0.18 * i) + math.cos(phase) * 8,
      );
      canvas.drawCircle(center, 80 + (i * 18), orbitPaint);
    }

    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppTheme.secondaryColor.withOpacity(0.045);
    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 0.08),
      100,
      glowPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.05, size.height * 0.9),
      130,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AetherBackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
