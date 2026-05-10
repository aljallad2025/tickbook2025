import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:evento_app/features/common/ui/widgets/network_app_logo.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _introController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late AnimationController _twinkleController;
  late AnimationController _motionController;
  late DateTime _lastTick;
  late Random _rnd;
  late List<_Star> _stars;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.05,
    ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_introController);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.easeIn)).animate(_introController);

    _twinkleController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    )..repeat(reverse: true);

    _motionController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    _rnd = Random(500);
    _lastTick = DateTime.now();

    _introController.forward();

    _stars = _generateStars(count: 80);
    _motionController.addListener(_onMotionTick);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().tryLoadSession();
      Timer(const Duration(seconds: 2), () {
        Get.offAllNamed(AppRoutes.bottomNav);
      });
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _twinkleController.dispose();
    _motionController.removeListener(_onMotionTick);
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryColor,
                  AppColors.secondaryColor,
                  Color(0xFF02030A),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          CustomPaint(
            painter: _StarFieldPainter(
              stars: _stars,
              tTwinkle: _twinkleController.value,
              repaint: Listenable.merge([
                _twinkleController,
                _motionController,
              ]),
            ),
          ),

          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _LogoWithGlow(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_Star> _generateStars({required int count}) {
    return List.generate(count, (i) {
      final x = _rnd.nextDouble();
      final y = _rnd.nextDouble();
      final size = 0.6 + _rnd.nextDouble() * 1.8;
      final phase = _rnd.nextDouble() * 2 * pi;
      final twinkle = 0.6 + _rnd.nextDouble() * 1.2;
      final vy = 0.12 + _rnd.nextDouble() * 0.28;
      final vx = (_rnd.nextDouble() - 0.5) * 0.04;
      return _Star(
        x: x,
        y: y,
        size: size,
        phase: phase,
        twinkle: twinkle,
        vy: vy,
        vx: vx,
      );
    });
  }

  void _onMotionTick() {
    final now = DateTime.now();
    final dt = now.difference(_lastTick).inMicroseconds / 1e6;
    _lastTick = now;
    for (var s in _stars) {
      s.y += s.vy * dt;
      s.x += s.vx * dt;
      if (s.x < -0.05) s.x += 1.10;
      if (s.x > 1.05) s.x -= 1.10;
      if (s.y > 1.05) {
        s.y = -0.05;
        s.x = _rnd.nextDouble();
        s.size = 0.6 + _rnd.nextDouble() * 1.8;
        s.phase = _rnd.nextDouble() * 2 * pi;
        s.twinkle = 0.6 + _rnd.nextDouble() * 1.2;
        s.vy = 0.12 + _rnd.nextDouble() * 0.28;
        s.vx = (_rnd.nextDouble() - 0.5) * 0.04;
      }
    }
  }
}

class _LogoWithGlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      // decoration: BoxDecoration(
      //   color: Colors.white.withValues(alpha: 0.0),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.white.withValues(alpha: 0.12),
      //       blurRadius: 40,
      //       spreadRadius: 2,
      //     ),
      //   ],
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Image.asset('assets/images/logo_black.png', height: 150, fit: BoxFit.contain)],
          ),

          Spacer(),
          SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _Star {
  double x;
  double y;
  double size;
  double phase;
  double twinkle;
  double vy;
  double vx;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.twinkle,
    required this.vy,
    required this.vx,
  });
}

class _StarFieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double tTwinkle;
  _StarFieldPainter({
    required this.stars,
    required this.tTwinkle,
    super.repaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final s in stars) {
      final offset = Offset(s.x * size.width, s.y * size.height);
      final tw = (sin((tTwinkle * 2 * pi * s.twinkle) + s.phase) + 1) / 2;
      final alpha = (80 + tw * 120).clamp(0, 200).toInt();
      paint.color = Colors.white.withAlpha(alpha);
      canvas.drawCircle(offset, s.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) {
    return oldDelegate.tTwinkle != tTwinkle || oldDelegate.stars != stars;
  }
}
