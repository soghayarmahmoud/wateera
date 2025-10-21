import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wateera/screens/main_screen.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _circlesOpacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _barWidthAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _circlesOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );

    _barWidthAnimation = Tween<double>(begin: 0.0, end: 220.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 4200), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FadeTransition(
              opacity: _circlesOpacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                            color: theme.primaryColor, shape: BoxShape.circle)),
                    Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            shape: BoxShape.circle)),
                    Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary,
                            shape: BoxShape.circle)),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _textOpacityAnimation,
                  child: Text(
                    'WATEERA',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _barWidthAnimation,
                  builder: (context, child) {
                    return Container(
                      height: 4,
                      width: _barWidthAnimation.value,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor,
                            theme.colorScheme.secondary,
                            theme.colorScheme.tertiary,
                            theme.colorScheme.primary,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}