import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _shipAnimation;
  bool _isLottieLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _preloadLottie();
    _checkAuthAndNavigate();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _shipAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
    ));
  }

  Future<void> _preloadLottie() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _isLottieLoaded = true);
        _controller.forward();
      }
    } catch (e) {
      developer.log('Erreur lors du chargement de l\'animation: $e');
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      developer.log('Vérification de l\'état d\'authentification...');
      await Future.delayed(const Duration(seconds: 5)); // Augmenté pour un affichage plus long
      final user = FirebaseAuth.instance.currentUser;
      if (!mounted) return;
      Get.offAllNamed(user != null ? '/home' : '/login');
    } catch (e) {
      developer.log('Erreur d\'authentification', error: e);
      if (mounted) Get.offAllNamed('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE4B5), // Fond blond
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLottieLoaded)
                  SlideTransition(
                    position: _shipAnimation,
                    child: Lottie.asset(
                      'assets/animations/ship.json',
                      width: MediaQuery.of(context).size.width * 0.7, // Légèrement dézoomé
                      fit: BoxFit.contain,
                    ),
                  ),
                const SizedBox(height: 30),
                const Text(
                  'Air Sea and Good Service Algeria',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    shadows: [
                      Shadow(color: Colors.white, blurRadius: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}