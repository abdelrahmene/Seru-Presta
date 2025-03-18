import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

// 📌 Fonction pour récupérer les données Firestore et les stocker en cache
Future<void> fetchAndCacheData() async {
  try {
    // ⚡ Vérifier la connectivité Internet avant d'interroger Firestore
    if (!(await _isConnected())) {
      print("⚠️ Pas de connexion Internet. Chargement des données en cache.");
      return;
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 🔄 Récupérer les catégories depuis Firestore
    QuerySnapshot categorySnapshot =
    await firestore.collection('categories').get();
    List<Map<String, dynamic>> categories = categorySnapshot.docs.map((doc) {
      return {
        "id": doc.id,
        "nom": doc["nom"],
        "image": doc["image"],
      };
    }).toList();

    // 📝 Stocker les catégories en cache
    await prefs.setString("categories", jsonEncode(categories));
    print("✅ Catégories mises en cache: ${categories.length}");

    // 🔄 Récupérer les produits depuis Firestore
    QuerySnapshot productSnapshot = await firestore
        .collection('produits')
        .orderBy("dateAjout", descending: true)
        .get(); // Suppression de la limite pour avoir tous les produits

    List<Map<String, dynamic>> produits = productSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        "id": doc.id,
        "nom": data["nom"] ?? "",
        "description": data["description"] ?? "",
        "unite": data["unite"] ?? "",
        "dateAjout": data["dateAjout"]?.toDate()?.toString() ?? DateTime.now().toString(),
        "prix": data["prix"] ?? 0.0,
        "categoryId": data["categoryId"] ?? "",
        "image": data["image"] ?? "",
      };
    }).toList();

    // 📝 Stocker les produits en cache
    await prefs.setString("produits", jsonEncode(produits));
    print("✅ Produits mis en cache: ${produits.length}");

  } catch (e) {
    print("❌ Erreur lors de la récupération des données Firestore : $e");
    rethrow; // Propager l'erreur pour la gérer dans le widget
  }
}

// 📌 Vérifie si l'appareil a une connexion Internet
Future<bool> _isConnected() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (e) {
    return false;
  }
}

// 📌 Fonction pour récupérer les catégories stockées en cache
Future<List<Map<String, dynamic>>> getCachedCategories() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? data = prefs.getString("categories");
  if (data != null) {
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }
  return [];
}

// 📌 Fonction pour récupérer les produits stockés en cache
Future<List<Map<String, dynamic>>> getCachedProduits() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? data = prefs.getString("produits");
  if (data != null) {
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }
  return [];
}
