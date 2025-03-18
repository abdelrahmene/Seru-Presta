import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../widgets/background_container.dart';
import '../services/auth_service.dart'; // Importez votre AuthService

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Instance de AuthService
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkFirebaseInitialization();
  }

  Future<void> _checkFirebaseInitialization() async {
    try {
      developer.log('Vérification de l\'initialisation Firebase...');
      await Future.delayed(const Duration(seconds: 1));

      final user = _authService.currentUser;
      developer.log('État de connexion: ${user != null ? 'Connecté (${user.email})' : 'Non connecté'}');
    } catch (e, stackTrace) {
      developer.log(
        'Erreur lors de la vérification Firebase',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _signInWithEmail() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      developer.log('Tentative de connexion email: ${_emailController.text}');

      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        developer.log('Validation: champs vides détectés');
        if (mounted) {
          Get.snackbar(
            "Erreur",
            "Veuillez remplir tous les champs",
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 3),
          );
        }
        return;
      }

      developer.log('Connexion à Firebase...');
      await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      developer.log('Connexion réussie');
      if (mounted) {
        Get.offAllNamed('/home');
      }
    } catch (e, stackTrace) {
      developer.log(
        'Erreur lors de la connexion email',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        Get.snackbar(
          "Erreur",
          "Une erreur est survenue lors de la connexion",
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      developer.log('Démarrage de la connexion Google...');
      final user = await _authService.signInWithGoogle();

      if (user != null) {
        developer.log('Connexion Google réussie: ${user.email}');
        if (mounted) {
          Get.offAllNamed('/home');
        }
      }
    } catch (e, stackTrace) {
      developer.log(
        'Erreur lors de la connexion Google',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        Get.snackbar(
          "Erreur",
          "Une erreur est survenue lors de la connexion avec Google",
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome Aboard!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.blue,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideY(duration: 500.ms),
                      const SizedBox(height: 20),

                      // Email
                      TextField(
                        controller: _emailController,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: "Email",
                          prefixIcon: const Icon(Icons.email, color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ).animate().fadeIn(duration: 500.ms).slideX(duration: 500.ms),
                      const SizedBox(height: 10),

                      // Mot de passe
                      TextField(
                        controller: _passwordController,
                        enabled: !_isLoading,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: "Mot de passe",
                          prefixIcon: const Icon(Icons.lock, color: Colors.white),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ).animate().fadeIn(duration: 500.ms).slideX(duration: 500.ms),
                      const SizedBox(height: 20),

                      // Boutons de connexion
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signInWithEmail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                "Se connecter",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signInWithGoogle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.blue,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              "Google",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 500.ms).slideY(duration: 500.ms),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}