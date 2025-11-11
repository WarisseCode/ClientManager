import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../core/theme.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      // Initialiser les notifications locales
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      );
      
      // Créer le channel de notification pour Android
      await _createNotificationChannel();
      
      if (kDebugMode) {
        print('✅ Service de notification initialisé');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de l\'initialisation du service de notification: $e');
      }
    }
  }
  
  /// Créer le channel de notification pour Android
  Future<void> _createNotificationChannel() async {
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'table_assignment_channel', // id
        'Attribution de table', // title
        description: 'Notifications d\'attribution de table', // description
        importance: Importance.max,
      );
      
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la création du channel de notification: $e');
      }
    }
  }

  // Gérer les notifications reçues en premier plan
  Future<void> showLocalNotification(RemoteMessage message) async {
    try {
      // Extraire les données du message
      final String title = message.notification?.title ?? 'Nouvelle attribution';
      final String body = message.notification?.body ?? 
          message.data['message'] ?? 
          'Une table vous a été attribuée';
      
      // Vérifier si c'est une attribution de table spécifique
      final String? type = message.data['type'] as String?;
      final String? status = message.data['status'] as String?;
      
      // Personnaliser le titre et le corps pour les attributions de table
      String notificationTitle = title;
      String notificationBody = body;
      
      if (type == 'table_assignment' || status == 'VALIDATE') {
        final String? tableNumber = message.data['tableNumber'] as String? ?? 
                                  message.data['tableId'] as String?;
        final String? orderId = message.data['orderId'] as String?;
        
        notificationTitle = 'Nouvelle table attribuée';
        notificationBody = tableNumber != null 
            ? 'Table $tableNumber vous a été attribuée' 
            : 'Une nouvelle table vous a été attribuée';
      }
      
      // Créer la notification Android
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'table_assignment_channel', 
        'Attribution de table',
        channelDescription: 'Notifications d\'attribution de table',
        importance: Importance.max,
        priority: Priority.high,
        color: AppColors.orange,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
      );

      // Créer la notification iOS
      const DarwinNotificationDetails iOSNotificationDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Combiner les détails
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iOSNotificationDetails,
      );

      // Afficher la notification
      await _localNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        notificationTitle,
        notificationBody,
        notificationDetails,
        payload: message.data.toString(),
      );
      
      if (kDebugMode) {
        print('🔔 Notification affichée: $notificationTitle - $notificationBody');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de l\'affichage de la notification: $e');
      }
    }
  }

  // Gérer les interactions avec les notifications
  static void onDidReceiveNotificationResponse(NotificationResponse response) {
    // Cette méthode est appelée lorsqu'un utilisateur interagit avec une notification
    if (kDebugMode) {
      print('📱 Notification cliquée: ${response.payload}');
    }
    
    // TODO: Naviguer vers l'écran approprié en fonction du payload
  }

  // Vérifier les permissions de notification
  Future<bool> requestNotificationPermissions() async {
    try {
      final bool? granted = await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      
      return granted ?? true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la demande de permissions: $e');
      }
      return false;
    }
  }
  
  /// Configurer Firebase Messaging
  Future<void> configureFirebaseMessaging() async {
    try {
      // Demander les permissions
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('✅ Permissions de notification accordées');
        }
      } else {
        if (kDebugMode) {
          print('❌ Permissions de notification refusées');
        }
      }
      
      // Obtenir le token FCM
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        if (kDebugMode) {
          print('🔑 Token FCM: $token');
        }
      }
      
      // Écouter les changements de token
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        if (kDebugMode) {
          print('🔄 Token FCM mis à jour: $newToken');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la configuration de Firebase Messaging: $e');
      }
    }
  }
}