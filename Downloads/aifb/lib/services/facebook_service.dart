import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'facebook_ads_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoResponse {
  final String id;
  final String trigger;
  final String response;
  final bool isActive;
  final String type; // 'comment' ou 'message'

  AutoResponse({
    required this.id,
    required this.trigger,
    required this.response,
    required this.isActive,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'trigger': trigger,
    'response': response,
    'isActive': isActive,
    'type': type,
  };

  factory AutoResponse.fromJson(Map<String, dynamic> json) => AutoResponse(
    id: json['id'],
    trigger: json['trigger'],
    response: json['response'],
    isActive: json['isActive'],
    type: json['type'],
  );
}

class FacebookService extends GetxService {
  final _isLoggedIn = false.obs;
  final _user = Rxn<Map<String, dynamic>>();
  final _pages = <Map<String, dynamic>>[].obs;
  final _selectedPage = Rxn<Map<String, dynamic>>();
  final _autoResponses = <AutoResponse>[].obs;
  final _isAutomationEnabled = true.obs;
  final _accessToken = ''.obs;
  final _notificationSettings =
      {
        'enabled': true,
        'emailNotifications': true,
        'frequency': 'immediate',
      }.obs;

  static const String _kAccessTokenKey = 'facebook_access_token';
  static const String _kIsLoggedInKey = 'facebook_is_logged_in';

  bool get isLoggedIn => _isLoggedIn.value;
  Map<String, dynamic>? get user => _user.value;
  List<Map<String, dynamic>> get pages => _pages;
  Rxn<Map<String, dynamic>> get selectedPage => _selectedPage;
  List<AutoResponse> get autoResponses => _autoResponses;
  bool get isAutomationEnabled => _isAutomationEnabled.value;
  void setAutomationEnabled(bool value) {
    _isAutomationEnabled.value = value;
  }

  String get accessToken => _accessToken.value;
  Map<String, dynamic> get notificationSettings => _notificationSettings;

  Future<void> login() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: [
          'public_profile',
          'email',
          'pages_show_list',
          'pages_read_engagement',
          'pages_manage_posts',
          'pages_manage_metadata',
          'ads_management',
          'ads_read',
          'business_management',
        ],
      );

      if (result.status == LoginStatus.success) {
        _accessToken.value = result.accessToken?.token ?? '';
        _isLoggedIn.value = true;

        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kAccessTokenKey, _accessToken.value);
        await prefs.setBool(_kIsLoggedInKey, true);

        // Fetch user data
        final userData = await FacebookAuth.instance.getUserData();
        _user.value = userData;

        // Initialize other services
        await Get.find<FacebookAdsService>().init(_accessToken.value);
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      rethrow;
    }
  }

  Future<void> checkAndRestoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_kAccessTokenKey);
      final isLoggedIn = prefs.getBool(_kIsLoggedInKey) ?? false;

      if (isLoggedIn && savedToken != null && savedToken.isNotEmpty) {
        _accessToken.value = savedToken;
        _isLoggedIn.value = true;

        // Initialize other services with the saved token
        await Get.find<FacebookAdsService>().init(savedToken);
      }
    } catch (e) {
      debugPrint('Error restoring session: $e');
    }
  }

  Future<void> fetchPages() async {
    try {
      debugPrint('=== Début de la récupération des pages ===');

      final token = await FacebookAuth.instance.accessToken;
      if (token == null) {
        debugPrint('Aucun token d\'access disponible');
        return;
      }

      final response = await http.get(
        Uri.parse(
          'https://graph.facebook.com/v17.0/me/accounts'
          '?fields=id,name,access_token,picture{url}'
          '&access_token=${token.token}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _pages.value = List<Map<String, dynamic>>.from(data['data'] ?? []);
        debugPrint('Pages récupérées: ${_pages.length}');
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des pages: $e');
      throw Exception('Erreur: $e');
    }
  }

  Future<void> addAutoResponse(AutoResponse response) async {
    try {
      // TODO: Implémenter la sauvegarde dans une base de données
      _autoResponses.add(response);
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout de la réponse automatique: $e');
      throw Exception('Erreur: $e');
    }
  }

  Future<void> toggleAutoResponse(String responseId) async {
    try {
      final index = _autoResponses.indexWhere((r) => r.id == responseId);
      if (index != -1) {
        final response = _autoResponses[index];
        _autoResponses[index] = AutoResponse(
          id: response.id,
          trigger: response.trigger,
          response: response.response,
          isActive: !response.isActive,
          type: response.type,
        );
      }
    } catch (e) {
      debugPrint(
        'Erreur lors de la modification de la réponse automatique: $e',
      );
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteAutoResponse(String responseId) async {
    try {
      _autoResponses.removeWhere((r) => r.id == responseId);
    } catch (e) {
      debugPrint('Erreur lors de la suppression de la réponse automatique: $e');
      throw Exception('Erreur: $e');
    }
  }

  Future<void> toggleAutomation(bool enabled) async {
    try {
      _isAutomationEnabled.value = enabled;
      // TODO: Sauvegarder la préférence
    } catch (e) {
      debugPrint('Erreur lors de la modification de l\'automatisation: $e');
      throw Exception('Erreur: $e');
    }
  }

  Future<void> updateNotificationSettings(Map<String, dynamic> settings) async {
    try {
      _notificationSettings.value = {..._notificationSettings, ...settings};
      // TODO: Sauvegarder les préférences
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour des notifications: $e');
      throw Exception('Erreur: $e');
    }
  }

  Future<String?> getPageAccessToken(String pageId) async {
    try {
      final token = await FacebookAuth.instance.accessToken;
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(
          'https://graph.facebook.com/v17.0/$pageId'
          '?fields=access_token'
          '&access_token=${token.token}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      }
      return null;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du token de la page: $e');
      return null;
    }
  }

  void selectPage(Map<String, dynamic> page) {
    debugPrint('Sélection de la page: ${page['name']} (ID: ${page['id']})');
    _selectedPage.value = page;
  }

  Future<List<Map<String, dynamic>>> fetchPagePosts() async {
    try {
      if (_selectedPage.value == null) {
        throw Exception('Aucune page sélectionnée');
      }

      final pageId = _selectedPage.value!['id'];
      final pageAccessToken = await getPageAccessToken(pageId);

      if (pageAccessToken == null) {
        throw Exception('Impossible de récupérer le token de la page');
      }

      final response = await http.get(
        Uri.parse(
          'https://graph.facebook.com/v17.0/$pageId/posts'
          '?fields=id,message,created_time,attachments,'
          'likes.summary(true),comments.summary(true)'
          '&access_token=$pageAccessToken',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des posts: $e');
      throw Exception('Erreur: $e');
    }
  }

  Future<void> logout() async {
    try {
      await FacebookAuth.instance.logOut();
      _accessToken.value = '';
      _isLoggedIn.value = false;
      _user.value = null;

      // Clear from shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kAccessTokenKey);
      await prefs.remove(_kIsLoggedInKey);
    } catch (e) {
      debugPrint('Error during logout: $e');
      rethrow;
    }
  }
}
