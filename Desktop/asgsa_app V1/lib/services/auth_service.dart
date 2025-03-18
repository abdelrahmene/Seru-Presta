import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 🔹 Récupérer l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // 🔹 Connexion avec Google
  Future<User?> signInWithGoogle() async {
    try {
      developer.log('🚀 Début de la connexion Google');

      if (kIsWeb) {
        developer.log('🌐 Connexion Google sur le Web');
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
        developer.log('✅ Connexion Google Web réussie');
        developer.log('👤 ID Utilisateur: ${userCredential.user?.uid}');
        return userCredential.user;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        developer.log('❌ Connexion Google annulée par l\'utilisateur');
        return null;
      }

      developer.log('🔑 Obtention des informations d\'authentification Google');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      developer.log('🔄 Connexion à Firebase avec les identifiants Google');
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        developer.log('⚠️ Utilisateur null après la connexion Google');
        return null;
      }

      developer.log('🆔 ID Firebase généré: ${userCredential.user?.uid}');
      developer.log('📧 Email: ${userCredential.user?.email}');
      developer.log('👤 Nom: ${userCredential.user?.displayName}');
      developer.log('✅ Connexion Google réussie');

      return userCredential.user;
    } on FirebaseAuthException catch (e, stackTrace) {
      developer.log(
        'Erreur FirebaseAuth lors de la connexion Google',
        error: e,
        stackTrace: stackTrace
      );
      rethrow;
    } catch (e, stackTrace) {
      developer.log(
        'Erreur inattendue lors de la connexion Google',
        error: e,
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  // 🔹 Connexion avec Email/Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      developer.log('Tentative de connexion avec email: $email');

      if (!_auth.isSignInWithEmailLink(email)) {
        developer.log('Vérification du format de l\'email');
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );

      developer.log('Connexion email réussie pour: $email');
      return userCredential.user;
    } on FirebaseAuthException catch (e, stackTrace) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Aucun utilisateur trouvé avec cet email.';
          break;
        case 'wrong-password':
          message = 'Mot de passe incorrect.';
          break;
        case 'user-disabled':
          message = 'Ce compte a été désactivé.';
          break;
        case 'invalid-email':
          message = 'Format d\'email invalide.';
          break;
        default:
          message = 'Erreur d\'authentification: ${e.message}';
      }

      developer.log(
        'Erreur FirebaseAuth lors de la connexion email',
        error: '$message (${e.code})',
        stackTrace: stackTrace
      );
      rethrow;
    } catch (e, stackTrace) {
      developer.log(
        'Erreur inattendue lors de la connexion email',
        error: e,
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  // 🔹 Inscription avec Email/Password
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      developer.log('Tentative d\'inscription avec email: $email');

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );

      developer.log('Inscription réussie pour: $email');
      return userCredential.user;
    } on FirebaseAuthException catch (e, stackTrace) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Un compte existe déjà avec cet email.';
          break;
        case 'invalid-email':
          message = 'Format d\'email invalide.';
          break;
        case 'operation-not-allowed':
          message = 'L\'inscription par email est désactivée.';
          break;
        case 'weak-password':
          message = 'Le mot de passe est trop faible.';
          break;
        default:
          message = 'Erreur d\'inscription: ${e.message}';
      }

      developer.log(
        'Erreur FirebaseAuth lors de l\'inscription',
        error: '$message (${e.code})',
        stackTrace: stackTrace
      );
      rethrow;
    } catch (e, stackTrace) {
      developer.log(
        'Erreur inattendue lors de l\'inscription',
        error: e,
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  // 🔹 Déconnexion
  Future<void> signOut() async {
    try {
      developer.log('Début de la déconnexion');

      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();

      developer.log('Déconnexion réussie');
    } catch (e, stackTrace) {
      developer.log(
        'Erreur lors de la déconnexion',
        error: e,
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  // 🔹 Écouteur pour l'état de connexion
  Stream<User?> get userStream => _auth.authStateChanges();
}
