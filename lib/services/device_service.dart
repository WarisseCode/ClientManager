import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class DeviceService {
  static const String _baseUrl = 'https://clientmanagerapi.onrender.com';
  
  /// Enregistre le device auprès du backend pour recevoir les notifications
  Future<bool> registerDevice({
    required String email,
    required String fcmToken,
    String platform = 'android',
  }) async {
    try {
      // Vérifier que les paramètres requis ne sont pas vides
      if (email.isEmpty || fcmToken.isEmpty) {
        if (kDebugMode) {
          print('❌ Email ou FCM token manquant');
        }
        return false;
      }
      
      final url = '$_baseUrl/devices/register';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'fcmToken': fcmToken,
          'platform': platform,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print('✅ Device enregistré avec succès pour $email');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('❌ Erreur lors de l\'enregistrement du device: ${response.statusCode}');
          print('Message: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur réseau lors de l\'enregistrement du device: $e');
      }
      return false;
    }
  }

  /// Met à jour le token FCM du device
  Future<bool> updateDeviceToken({
    required String email,
    required String oldToken,
    required String newToken,
  }) async {
    try {
      // Vérifier que les paramètres requis ne sont pas vides
      if (email.isEmpty || oldToken.isEmpty || newToken.isEmpty) {
        if (kDebugMode) {
          print('❌ Paramètres manquants pour la mise à jour du token');
        }
        return false;
      }
      
      final url = '$_baseUrl/devices/update-token';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'oldToken': oldToken,
          'newToken': newToken,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Token FCM mis à jour avec succès pour $email');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('❌ Erreur lors de la mise à jour du token: ${response.statusCode}');
          print('Message: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur réseau lors de la mise à jour du token: $e');
      }
      return false;
    }
  }

  /// Désenregistre le device
  Future<bool> unregisterDevice({
    required String email,
    required String fcmToken,
  }) async {
    try {
      // Vérifier que les paramètres requis ne sont pas vides
      if (email.isEmpty || fcmToken.isEmpty) {
        if (kDebugMode) {
          print('❌ Email ou FCM token manquant pour le désenregistrement');
        }
        return false;
      }
      
      final url = '$_baseUrl/devices/unregister';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'fcmToken': fcmToken,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Device désenregistré avec succès pour $email');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('❌ Erreur lors du désenregistrement du device: ${response.statusCode}');
          print('Message: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur réseau lors du désenregistrement du device: $e');
      }
      return false;
    }
  }

  /// Récupère le token FCM actuel
  Future<String?> getFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la récupération du token FCM: $e');
      }
      return null;
    }
  }
  
  /// Écoute les changements de token FCM et met à jour le backend
  void listenForTokenRefresh(String email) {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      try {
        final oldToken = await getFcmToken();
        if (oldToken != null && oldToken != newToken) {
          await updateDeviceToken(
            email: email,
            oldToken: oldToken,
            newToken: newToken,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Erreur lors de la mise à jour du token refresh: $e');
        }
      }
    });
  }
}