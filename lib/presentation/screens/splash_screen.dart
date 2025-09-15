import 'package:flutter/material.dart';

import '../../shared/constants/app_colors.dart';
import '../screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _fadeController.forward();
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.music_note,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App Title
                  const Text(
                    'Hymnes',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // App Subtitle
                  Text(
                    'Hymnes et Louanges Adventistes',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // App version
                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 1,
                    ),
                  ),

                  // Loading indicator
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
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
