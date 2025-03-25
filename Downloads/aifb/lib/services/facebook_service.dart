import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FacebookService extends GetxService {
  final _isLoggedIn = false.obs;
  final _user = Rxn<Map<String, dynamic>>();
  final _pages = <Map<String, dynamic>>[].obs;
  final _selectedPage = Rxn<Map<String, dynamic>>();
  final _businessManagerId = Rxn<String>();
  final _imageCache = DefaultCacheManager();

  bool get isLoggedIn => _isLoggedIn.value;
  Map<String, dynamic>? get user => _user.value;
  List<Map<String, dynamic>> get pages => _pages;
  Map<String, dynamic>? get selectedPage => _selectedPage.value;
  String? get businessManagerId => _businessManagerId.value;

  Future<void> login() async {
    try {
      debugPrint('=== Début de la connexion Facebook ===');

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: [
          'public_profile',
          'email',
          'pages_show_list',
          'pages_read_engagement',
          'pages_manage_metadata',
          'pages_read_user_content',
          'pages_manage_ads',
          'pages_manage_posts',
          'pages_manage_engagement',
        ],
      );

      debugPrint('Résultat de la connexion: ${result.status}');

      if (result.status == LoginStatus.success) {
        debugPrint('Connexion réussie, récupération des données utilisateur');

        final userData = await FacebookAuth.instance.getUserData();
        debugPrint('Données utilisateur: $userData');

        _user.value = userData;
        _isLoggedIn.value = true;

        // Récupérer les Business Managers
        debugPrint('Récupération des Business Managers...');
        final businessManagerData = await _fetchBusinessManagers();
        debugPrint('Données Business Manager: $businessManagerData');

        if (businessManagerData['data'] != null &&
            businessManagerData['data'].isNotEmpty) {
          final businessManager = businessManagerData['data'].first;
          _businessManagerId.value = businessManager['id'];
          debugPrint('Business Manager ID: ${_businessManagerId.value}');
        }

        // Récupérer les pages dès la connexion
        debugPrint('Récupération des pages...');
        await fetchPages();

        Get.snackbar('Succès', 'Connexion réussie');
      } else {
        debugPrint('Erreur de connexion: ${result.status}');
        Get.snackbar('Erreur', 'Échec de la connexion');
      }
    } catch (e, stack) {
      debugPrint('Erreur lors de la connexion: $e');
      debugPrint('Stack trace: $stack');
      Get.snackbar('Erreur', 'Une erreur est survenue lors de la connexion');
    }
  }

  Future<Map<String, dynamic>> _fetchBusinessManagers() async {
    try {
      debugPrint('=== Début de la récupération des Business Managers ===');

      final token = await FacebookAuth.instance.accessToken;
      if (token == null) {
        debugPrint('Erreur: Token non disponible');
        return {'data': []};
      }

      debugPrint(
        'Token d\'access disponible. Récupération des Business Managers...',
      );
      debugPrint('Token: ${token.token}');

      final response = await http.get(
        Uri.parse(
          'https://graph.facebook.com/v22.0/me/business_managers?'
          'fields=id,name&'
          'access_token=${token.token}',
        ),
      );

      debugPrint('Statut de la réponse: ${response.statusCode}');
      debugPrint('Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Données Business Managers: $data');
        return data;
      } else {
        debugPrint('Erreur API: ${response.statusCode} - ${response.body}');
        return {'data': []};
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des Business Managers: $e');
      return {'data': []};
    }
  }

  Future<void> fetchPages() async {
    try {
      debugPrint('=== Début de la récupération des pages ===');

      if (!_isLoggedIn.value) {
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté pour accéder aux pages',
        );
        debugPrint('Utilisateur non connecté');
        return;
      }

      debugPrint('Utilisateur connecté, vérification du token...');
      final token = await FacebookAuth.instance.accessToken;

      if (token == null) {
        debugPrint('Erreur: Token non disponible');
        Get.snackbar('Erreur', 'Token d\'access non disponible');
        return;
      }

      debugPrint('Token d\'access disponible. Vérification des permissions...');

      // Récupérer les permissions depuis l'API Facebook
      final permissionsResponse = await http.get(
        Uri.parse(
          'https://graph.facebook.com/v17.0/me/permissions?'
          'access_token=${token.token}',
        ),
      );

      if (permissionsResponse.statusCode == 200) {
        final permissionsData = json.decode(permissionsResponse.body);
        debugPrint('Permissions disponibles: $permissionsData');
      } else {
        debugPrint(
          'Erreur lors de la récupération des permissions: ${permissionsResponse.statusCode}',
        );
      }

      // Récupérer les pages avec tous les champs nécessaires
      final fields =
          'id,name,access_token,picture{url},about,category,description,'
          'emails,website,phone,location{city,country,latitude,longitude,street,zip},'
          'fan_count,talking_about_count,checkins,was_here_count,can_post,'
          'is_verified,is_published,link,username';

      debugPrint(
        'Requête API: https://graph.facebook.com/v17.0/me/accounts?fields=$fields',
      );
      debugPrint('Token d\'access: ${token.token}');

      // D'abord récupérer les pages de base
      final response = await http.get(
        Uri.parse(
          'https://graph.facebook.com/v17.0/me/accounts?'
          'fields=$fields&'
          'access_token=${token.token}',
        ),
      );

      debugPrint('Statut de la réponse: ${response.statusCode}');
      debugPrint('Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Données brutes: $data');

        if (data['data'] != null) {
          debugPrint('Nombre initial de pages: ${data['data'].length}');

          final List<Map<String, dynamic>>
          pages = List<Map<String, dynamic>>.from(
            data['data'].map((page) {
              debugPrint('Page trouvée: ${page['name']} (ID: ${page['id']})');

              if (page['picture'] != null &&
                  page['picture']['data'] != null &&
                  page['picture']['data']['url'] != null) {
                page['picture']['data']['url'] =
                    page['picture']['data']['url'] + '?height=500&width=500';
              }
              return page;
            }).toList(),
          );

          // Vérifier si il y a plus de pages (pagination)
          if (data['paging'] != null && data['paging']['next'] != null) {
            debugPrint('Pages supplémentaires à récupérer');
            debugPrint('URL de pagination: ${data['paging']['next']}');
            await _fetchAdditionalPages(data['paging']['next'], pages);
          }

          _pages.value = pages;
          debugPrint('Nombre total de pages trouvées: ${pages.length}');
          debugPrint('Pages finales: $pages');
        } else {
          debugPrint('Aucune page trouvée dans la réponse');
          _pages.clear();
          Get.snackbar('Info', 'Aucune page trouvée');
        }
      } else {
        debugPrint('Erreur API: ${response.statusCode} - ${response.body}');
        Get.snackbar('Erreur', 'Erreur lors de la récupération des pages');
      }
    } catch (e, stack) {
      debugPrint('Erreur lors de la récupération des pages: $e');
      debugPrint('Stack trace: $stack');
      Get.snackbar('Erreur', 'Une erreur est survenue: $e');
    }
  }

  Future<void> _fetchAdditionalPages(
    String nextPageUrl,
    List<Map<String, dynamic>> pages,
  ) async {
    try {
      debugPrint('Récupération de pages supplémentaires...');
      debugPrint('URL de pagination: $nextPageUrl');

      final response = await http.get(Uri.parse(nextPageUrl));
      debugPrint('Statut de la réponse: ${response.statusCode}');
      debugPrint('Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Données brutes: $data');

        if (data['data'] != null) {
          debugPrint(
            'Nombre de pages supplémentaires trouvées: ${data['data'].length}',
          );

          final newPages = List<Map<String, dynamic>>.from(
            data['data'].map((page) {
              debugPrint(
                'Page supplémentaire trouvée: ${page['name']} (ID: ${page['id']})',
              );

              if (page['picture'] != null &&
                  page['picture']['data'] != null &&
                  page['picture']['data']['url'] != null) {
                page['picture']['data']['url'] =
                    page['picture']['data']['url'] + '?height=500&width=500';
              }
              return page;
            }).toList(),
          );

          pages.addAll(newPages);
          debugPrint('Nombre total de pages après pagination: ${pages.length}');

          // Vérifier s'il y a encore plus de pages
          if (data['paging'] != null && data['paging']['next'] != null) {
            debugPrint('Pages supplémentaires à récupérer');
            debugPrint('URL de pagination: ${data['paging']['next']}');
            await _fetchAdditionalPages(data['paging']['next'], pages);
          }
        }
      }
    } catch (e) {
      debugPrint(
        'Erreur lors de la récupération des pages supplémentaires: $e',
      );
    }
  }

  Future<void> refreshPages() async {
    try {
      if (!_isLoggedIn.value) {
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté pour accéder aux pages',
        );
        return;
      }

      debugPrint('Début du rafraîchissement des pages');

      final token = await FacebookAuth.instance.accessToken;
      if (token == null) {
        debugPrint('Token non disponible');
        return;
      }

      // Récupérer les pages avec tous les champs nécessaires
      final fields =
          'id,name,access_token,picture{url},about,category,description,'
          'emails,website,phone,location{city,country,latitude,longitude,street,zip},'
          'fan_count,talking_about_count,checkins,was_here_count,can_post,'
          'is_verified,is_published,link,username';

      final response = await http.get(
        Uri.parse(
          'https://graph.facebook.com/v17.0/${_businessManagerId.value}/owned_pages?'
          'fields=$fields&'
          'access_token=${token.token}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Données des pages: $data');

        if (data['data'] != null) {
          final List<Map<String, dynamic>> pages =
              List<Map<String, dynamic>>.from(
                data['data'].map((page) {
                  if (page['picture'] != null &&
                      page['picture']['data'] != null &&
                      page['picture']['data']['url'] != null) {
                    page['picture']['data']['url'] =
                        page['picture']['data']['url'] +
                        '?height=500&width=500';
                  }
                  return page;
                }).toList(),
              );
          _pages.value = pages;
          debugPrint('Nombre de pages trouvées: ${pages.length}');
          Get.snackbar('Succès', 'Pages rafraîchies avec succès');
        } else {
          debugPrint('Aucune page trouvée');
          _pages.clear();
          Get.snackbar('Info', 'Aucune page trouvée');
        }
      } else {
        debugPrint('Erreur API: ${response.statusCode} - ${response.body}');
        Get.snackbar('Erreur', 'Erreur lors du rafraîchissement des pages');
      }
    } catch (e, stack) {
      debugPrint('Erreur lors du rafraîchissement des pages: $e');
      debugPrint('Stack trace: $stack');
      Get.snackbar('Erreur', 'Une erreur est survenue: $e');
    }
  }

  void setSelectedPage(Map<String, dynamic>? page) {
    debugPrint('Page sélectionnée: ${page?['name']}');
    _selectedPage.value = page;
  }

  Future<void> logout() async {
    try {
      await FacebookAuth.instance.logOut();
      _isLoggedIn.value = false;
      _user.value = null;
      _pages.clear();
      _selectedPage.value = null;
      _businessManagerId.value = null;
      Get.snackbar('Succès', 'Déconnexion réussie');
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
      Get.snackbar('Erreur', 'Une erreur est survenue lors de la déconnexion');
    }
  }

  Future<ImageProvider> getCachedPageImage(String imageUrl) async {
    try {
      debugPrint('Récupération de l\'image depuis le cache: $imageUrl');

      // Ajouter le token d\'accès à l\'URL de l\'image
      final token = await FacebookAuth.instance.accessToken;
      if (token != null) {
        // Vérifier si l'URL est une URL Facebook
        if (imageUrl.startsWith('https://scontent.') &&
            imageUrl.contains('fbcdn.net')) {
          // Extraire l'ID de l'image de l'URL
          final uri = Uri.parse(imageUrl);
          final idMatch = RegExp(r'_(\d+)_').firstMatch(uri.path);
          if (idMatch != null) {
            final imageId = idMatch.group(1);

            // Construire l'URL avec l'ID et le token
            final urlWithToken =
                'https://graph.facebook.com/v22.0/$imageId/picture?'
                'access_token=${token.token}';

            debugPrint('URL avec token: $urlWithToken');

            // Vérifier dans le cache
            final file = await _imageCache.getSingleFile(urlWithToken);
            if (file != null) {
              debugPrint('Image trouvée dans le cache');
              return FileImage(file);
            }

            debugPrint('Image non trouvée dans le cache, téléchargement...');
            final result = await _imageCache.downloadFile(urlWithToken);
            return FileImage(result.file);
          }
        }

        // Si ce n'est pas une URL Facebook, utiliser l'URL originale
        final urlWithToken =
            Uri.parse(imageUrl)
                .replace(
                  queryParameters: {
                    ...Uri.parse(imageUrl).queryParameters,
                    'access_token': token.token,
                  },
                )
                .toString();

        debugPrint('URL avec token: $urlWithToken');

        final file = await _imageCache.getSingleFile(urlWithToken);

        if (file != null) {
          debugPrint('Image trouvée dans le cache');
          return FileImage(file);
        }

        debugPrint('Image non trouvée dans le cache, téléchargement...');
        final result = await _imageCache.downloadFile(urlWithToken);
        return FileImage(result.file);
      }

      debugPrint('Token non disponible, utilisation de l\'image par défaut');
      return AssetImage('assets/default_page_image.png');
    } catch (e) {
      debugPrint('Erreur lors du téléchargement de l\'image: $e');
      return AssetImage('assets/default_page_image.png');
    }
  }
}
