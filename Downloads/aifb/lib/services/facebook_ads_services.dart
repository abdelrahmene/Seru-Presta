import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FacebookAdsService extends GetxService {
  static const String apiVersion = 'v22.0';

  // Observable variables
  final _businessAccounts = <Map<String, dynamic>>[].obs;
  final _adAccounts = <Map<String, dynamic>>[].obs;
  final _ads = <Map<String, dynamic>>[].obs;
  final _pages = <Map<String, dynamic>>[].obs;

  final _selectedBusinessId = ''.obs;
  final _selectedAdAccountId = ''.obs;
  final _totalAdsCount = 0.obs;
  final _activeAdsCount = 0.obs;

  // Getters
  List<Map<String, dynamic>> get businessAccounts => _businessAccounts;
  List<Map<String, dynamic>> get adAccounts => _adAccounts;
  List<Map<String, dynamic>> get ads => _ads;
  List<Map<String, dynamic>> get pages => _pages;

  String get selectedBusinessId => _selectedBusinessId.value;
  String get selectedAdAccountId => _selectedAdAccountId.value;
  int get totalAdsCount => _totalAdsCount.value;
  int get activeAdsCount => _activeAdsCount.value;

  // Initialisation du service
  Future<void> init(String accessToken) async {
    debugPrint(
      'FacebookAdsService - Initialisation avec accessToken: $accessToken',
    );

    try {
      await fetchBusinessAccounts(accessToken);

      if (_businessAccounts.isNotEmpty) {
        debugPrint(
          'FacebookAdsService - Sélection du premier Business Manager: ${_businessAccounts[0]}',
        );
        selectBusinessAccount(_businessAccounts[0]['id']);
        await fetchAdAccounts(_selectedBusinessId.value, accessToken);
        await fetchPages(_selectedBusinessId.value, accessToken);

        if (_adAccounts.isNotEmpty) {
          debugPrint(
            'FacebookAdsService - Sélection du premier compte publicitaire: ${_adAccounts[0]}',
          );
          selectAdAccount(_adAccounts[0]['id']);
          await Future.wait([
            fetchAds(_selectedAdAccountId.value, accessToken),
            fetchTotalAdsCount(_selectedAdAccountId.value, accessToken),
            fetchActiveAdsCount(_selectedAdAccountId.value, accessToken),
          ]);
        }
      }
    } catch (e) {
      debugPrint('FacebookAdsService - Erreur lors de l\'initialisation: $e');
      rethrow;
    }
  }

  // 1. Récupérer tous les business accounts de l'utilisateur
  Future<void> fetchBusinessAccounts(String accessToken) async {
    debugPrint('FacebookAdsService - Récupération des Business Managers');

    try {
      final response = await http.get(
        Uri.parse(
          'https://graph.facebook.com/$apiVersion/me/businesses?access_token=$accessToken',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint(
          'FacebookAdsService - Business Managers récupérés: ${data['data'].length}',
        );
        _businessAccounts.assignAll(
          List<Map<String, dynamic>>.from(data['data']),
        );
      } else {
        debugPrint(
          'FacebookAdsService - Échec de la récupération des Business Managers: ${response.statusCode}',
        );
        throw Exception('Échec de la récupération des Business Managers');
      }
    } catch (e) {
      debugPrint(
        'FacebookAdsService - Erreur lors de la récupération des Business Managers: $e',
      );
      rethrow;
    }
  }

  // 2. Récupérer les pages associées au business manager
  Future<void> fetchPages(String businessId, String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://graph.facebook.com/v22.0/me/accounts?access_token=$accessToken',
        ),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _pages.value = List<Map<String, dynamic>>.from(data['data']);
        print('FacebookAdsService - Pages récupérées: ${_pages.length}');
      } else {
        print(
          'FacebookAdsService - Erreur lors de la récupération des pages: ${response.statusCode}',
        );
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print(
        'FacebookAdsService - Erreur lors de la récupération des pages: $e',
      );
    }
  }

  // 3. Récupérer les comptes publicitaires associés au business manager
  Future<void> fetchAdAccounts(String businessId, String accessToken) async {
    debugPrint(
      'FacebookAdsService - Récupération des comptes publicitaires pour businessId: $businessId',
    );

    try {
      final response = await http.get(
        Uri.parse(
          'https://graph.facebook.com/$apiVersion/$businessId/owned_ad_accounts?access_token=$accessToken',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint(
          'FacebookAdsService - Comptes publicitaires récupérés: ${data['data'].length}',
        );
        _adAccounts.assignAll(List<Map<String, dynamic>>.from(data['data']));
      } else {
        debugPrint(
          'FacebookAdsService - Échec de la récupération des comptes publicitaires: ${response.statusCode}',
        );
        throw Exception('Échec de la récupération des comptes publicitaires');
      }
    } catch (e) {
      debugPrint(
        'FacebookAdsService - Erreur lors de la récupération des comptes publicitaires: $e',
      );
      rethrow;
    }
  }

  // 4. Récupérer les publicités
  Future<void> fetchAds(String adAccountId, String accessToken) async {
    debugPrint(
      'FacebookAdsService - Récupération des publicités pour adAccountId: $adAccountId',
    );

    try {
      final response = await http.get(
        Uri.parse(
          'https://graph.facebook.com/$apiVersion/$adAccountId/ads?fields=id,name,status,created_time&access_token=$accessToken',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint(
          'FacebookAdsService - Publicités récupérées: ${data['data'].length}',
        );
        _ads.assignAll(List<Map<String, dynamic>>.from(data['data']));
      } else {
        debugPrint(
          'FacebookAdsService - Échec de la récupération des publicités: ${response.statusCode}',
        );
        throw Exception('Échec de la récupération des publicités');
      }
    } catch (e) {
      debugPrint(
        'FacebookAdsService - Erreur lors de la récupération des publicités: $e',
      );
      rethrow;
    }
  }

  // 5. Récupérer le nombre total de publicités
  Future<void> fetchTotalAdsCount(
    String adAccountId,
    String accessToken,
  ) async {
    debugPrint(
      'FacebookAdsService - Récupération du nombre total de publicités pour adAccountId: $adAccountId',
    );

    try {
      final response = await http.get(
        Uri.parse(
          'https://graph.facebook.com/$apiVersion/$adAccountId/ads?summary=total_count&access_token=$accessToken',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint(
          'FacebookAdsService - Nombre total de publicités: ${data['summary']['total_count']}',
        );
        _totalAdsCount.value = data['summary']['total_count'];
      } else {
        debugPrint(
          'FacebookAdsService - Échec de la récupération du nombre total de publicités: ${response.statusCode}',
        );
        throw Exception(
          'Échec de la récupération du nombre total de publicités',
        );
      }
    } catch (e) {
      debugPrint(
        'FacebookAdsService - Erreur lors de la récupération du nombre total de publicités: $e',
      );
      rethrow;
    }
  }

  // 6. Récupérer uniquement les publicités actives
  Future<void> fetchActiveAdsCount(
    String adAccountId,
    String accessToken,
  ) async {
    debugPrint(
      'FacebookAdsService - Récupération du nombre de publicités actives pour adAccountId: $adAccountId',
    );

    try {
      final response = await http.get(
        Uri.parse(
          'https://graph.facebook.com/$apiVersion/$adAccountId/ads?filtering=[{"field":"ad.effective_status","operator":"IN","value":["ACTIVE"]}]&summary=total_count&access_token=$accessToken',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint(
          'FacebookAdsService - Nombre de publicités actives: ${data['summary']['total_count']}',
        );
        _activeAdsCount.value = data['summary']['total_count'];
      } else {
        debugPrint(
          'FacebookAdsService - Échec de la récupération du nombre de publicités actives: ${response.statusCode}',
        );
        throw Exception(
          'Échec de la récupération du nombre de publicités actives',
        );
      }
    } catch (e) {
      debugPrint(
        'FacebookAdsService - Erreur lors de la récupération du nombre de publicités actives: $e',
      );
      rethrow;
    }
  }

  // Sélecteurs
  void selectBusinessAccount(String id) {
    debugPrint('FacebookAdsService - Sélection du Business Manager: $id');
    _selectedBusinessId.value = id;
    _adAccounts.clear();
    _selectedAdAccountId.value = '';
    _ads.clear();
    _pages.clear();
    update();
  }

  void selectAdAccount(String id) {
    debugPrint('FacebookAdsService - Sélection du compte publicitaire: $id');
    _selectedAdAccountId.value = id;
    _ads.clear();
    update();
  }

  void update() {
    // Rien à faire, GetX gère automatiquement la notification des observateurs
  }
}
