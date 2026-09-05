import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/localization/localization.dart';
import 'package:pos/riverpod/login-check.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/local-user.dart';
import 'package:pos/utils/secure-storage.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  final _secureStorage = SecureStorage();
  double _progress = 0.0;

  late final AnimationController _pulseController;
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _runInit());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _updateProgress(double value) {
    if (!mounted) return;
    setState(() => _progress = value);
  }

  Future<void> _runInit() async {
    final isDark = await _secureStorage.getTheme();
    ref
        .read(themeModeProvider.notifier)
        .setTheme(isDark ? ThemeMode.dark : ThemeMode.light);
    _updateProgress(0.2);

    final languageCode = await _secureStorage.getLanguageSetting();
    localization.translate(languageCode);
    _updateProgress(0.4);

    final isLogin = await _secureStorage.getLogin();
    if (!mounted) return;

    if (isLogin) {
      ref.read(checkLoginProvider.notifier).login();
      await addToUserLocalStateWidget(ref);
    } else {
      ref.read(checkLoginProvider.notifier).logout();
    }
    _updateProgress(0.85);

    await Future.delayed(const Duration(milliseconds: 350));
    _updateProgress(1.0);

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    if (isLogin) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final trackColor = (isDark ? Colors.white : Colors.black).withOpacity(0.08);

    const gradientColors = [
      Color.fromARGB(255, 120, 160, 197),
      Color.fromARGB(255, 129, 173, 191),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: FadeTransition(
        opacity: _fadeController,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ===== Logo + circular progress ring =====
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  // Reduced glow: subtle instead of strong
                  final glow = 0.05 + (_pulseController.value * 0.06);
                  return Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors.first.withOpacity(glow),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: SizedBox(
                  width: 148,
                  height: 148,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Track ring
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 4,
                          color: trackColor,
                        ),
                      ),
                      // Animated gradient progress ring
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: _progress),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return SizedBox.expand(
                            child: CustomPaint(
                              painter: _GradientRingPainter(
                                progress: value,
                                strokeWidth: 4,
                                colors: gradientColors,
                              ),
                            ),
                          );
                        },
                      ),
                      // Logo
                      ClipOval(
                        child: Container(
                          width: 108,
                          height: 108,
                          color: bgColor,
                          padding: const EdgeInsets.all(18),
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ===== Animated percent text =====
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: _progress),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: gradientColors,
                    ).createShader(bounds),
                    child: Text(
                      '${(value * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // masked by ShaderMask
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              Text(
                _statusLabel(_progress),
                style: TextStyle(
                  fontSize: 13,
                  color: subColor,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(double value) {
    if (value < 0.3) return 'Preparing...';
    if (value < 0.6) return 'Loading settings...';
    if (value < 0.95) return 'Signing you in...';
    return 'Almost there...';
  }
}

/// Paints a rounded, gradient progress ring that fills clockwise from the top.
class _GradientRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> colors;

  _GradientRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: colors,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
