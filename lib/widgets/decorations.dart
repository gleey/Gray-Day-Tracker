import 'dart:math';
import 'package:flutter/material.dart';

class DecorativeBackground extends StatelessWidget {
  final Widget child;

  const DecorativeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ornamen background
        Positioned(
          top: -100,
          right: -50,
          child: _Blob(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.05),
            size: 300,
          ),
        ),
        Positioned(
          bottom: 100,
          left: -100,
          child: _Blob(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.05),
            size: 250,
          ),
        ),
        Positioned(
          top: 300,
          right: -80,
          child: _Blob(
            color: const Color(0xFF1DD1A1).withValues(alpha: 0.05),
            size: 150,
          ),
        ),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;

  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        // Blob shape dengan blur agar menyatu dengan background
        boxShadow: [
          BoxShadow(color: color, blurRadius: size / 2, spreadRadius: size / 4),
        ],
      ),
    );
  }
}

class PeekingMascot extends StatefulWidget {
  const PeekingMascot({super.key});

  @override
  State<PeekingMascot> createState() => _PeekingMascotState();
}

class _PeekingMascotState extends State<PeekingMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(1.2, 0),
          end: const Offset(0.2, 0), // Mengintip sedikit
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.elasticOut,
            reverseCurve: Curves.easeInBack,
          ),
        );

    _startRandomPeeking();
  }

  void _startRandomPeeking() async {
    while (mounted) {
      // Tunggu antara 5 - 15 detik sebelum mengintip
      final waitTime = Random().nextInt(10) + 5;
      await Future.delayed(Duration(seconds: waitTime));

      if (!mounted) break;

      // Muncul
      await _controller.forward();

      // Diam di sana selama 2-3 detik
      await Future.delayed(
        Duration(milliseconds: 2000 + Random().nextInt(1000)),
      );

      if (!mounted) break;

      // Sembunyi lagi
      await _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      bottom: 120, // Posisi di atas FAB (jika di HomeScreen)
      child: SlideTransition(
        position: _slideAnimation,
        child: IgnorePointer(
          // Agar tidak menghalangi tap di bawahnya
          child: Image.asset('assets/intip.png', width: 80, height: 80),
        ),
      ),
    );
  }
}
