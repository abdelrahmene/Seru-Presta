import 'package:asgsa_app/services/service_bindings.dart';
import 'package:asgsa_app/views/home.dart';
import 'package:asgsa_app/views/invoice_page.dart';
import 'package:asgsa_app/views/login_page.dart';
import 'package:asgsa_app/views/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  try {
    developer.log('Initialisation de Flutter...');
    WidgetsFlutterBinding.ensureInitialized();

    developer.log('Initialisation de Firebase...');
    final FirebaseOptions options = DefaultFirebaseOptions.currentPlatform;
    developer.log('Options Firebase: ${options.projectId}');
    
    await Firebase.initializeApp(options: options);
    
    // Configuration de Firestore
    await _configureFirestore();
    
    developer.log('Firebase initialisé avec succès');
    
    runApp(const MyApp());
  } catch (e, stackTrace) {
    developer.log(
      'Erreur critique lors de l\'initialisation',
      error: e,
      stackTrace: stackTrace
    );
    
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Erreur de connexion',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Erreur: ${e.toString()}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

Future<void> _configureFirestore() async {
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Activer la persistance hors ligne
    await firestore.enablePersistence(const PersistenceSettings(
      synchronizeTabs: true,
    ));
    
    // Configuration du cache
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    
    developer.log('✅ Configuration Firestore réussie');
  } catch (e) {
    developer.log('⚠️ Erreur lors de la configuration Firestore', error: e);
    // On continue même si la configuration échoue
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ASGSA Ravitaillement',
      initialBinding: ServiceBindings(),
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: 'Roboto',
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/home', page: () => const HomeView(), binding: ServiceBindings()),
        GetPage(name: '/invoice', page: () => InvoicePage()),
      ],
    );
  }
}
