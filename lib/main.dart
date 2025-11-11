import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'core/theme.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/restaurant/restaurant_selection_page.dart';
import 'features/home/home_page.dart';
// Import de la nouvelle page de tables
import 'features/tables/tables_page.dart';
// Import de la page de notifications
import 'features/notifications/notifications_page.dart';
import 'features/auth/auth_service.dart';
import 'providers/restaurant_provider.dart';
import 'providers/table_provider.dart';
// Import du service et provider de préférences
import 'services/preferences_service.dart';
import 'providers/preferences_provider.dart';
// Import du service de notification
import 'services/notification_service.dart';
// Import du provider de notification
import 'providers/notification_provider.dart';
// Import du service de device
import 'services/device_service.dart';
// Import du service de mise à jour en temps réel
import 'services/realtime_service.dart';

// Handler pour les messages reçus en arrière-plan
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Note: Firebase.initializeApp() n'est pas nécessaire ici car l'application est déjà initialisée
  print("📩 Message reçu en arrière-plan: ${message.messageId}");
  
  // Afficher une notification locale pour les messages reçus en arrière-plan
  await NotificationService().showLocalNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp();
  
  // Initialiser le service de notification
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.configureFirebaseMessaging();
  
  // Initialiser le service de préférences
  final preferencesService = PreferencesService();
  await preferencesService.init();
  
  // Configurer le handler pour les messages en arrière-plan
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => TableProvider()),
        // Ajout du provider de préférences
        ChangeNotifierProvider(create: (_) => PreferencesProvider(preferencesService)),
        // Ajout du provider de notification
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const RestaurantNotifierApp(),
    ),
  );
}

class RestaurantNotifierApp extends StatefulWidget {
  const RestaurantNotifierApp({super.key});

  @override
  State<RestaurantNotifierApp> createState() => _RestaurantNotifierAppState();
}

class _RestaurantNotifierAppState extends State<RestaurantNotifierApp> {
  final AuthService _authService = AuthService();
  bool _deviceRegistered = false; // Ajout d'un indicateur pour éviter les enregistrements multiples

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
  }

  Future<void> _initializeFirebaseMessaging() async {
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
      print('✅ Permissions accordées');
    } else {
      print('❌ Permissions refusées');
    }

    // Obtenir le token FCM
    String? token = await FirebaseMessaging.instance.getToken();
    print('🔑 Token FCM: $token');
  }

  @override
  Widget build(BuildContext context) {
    // Configurer les écouteurs de messages FCM dans le build method où le context est disponible
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Obtenir les providers
      final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
      final tableProvider = Provider.of<TableProvider>(context, listen: false);
      
      // Démarrer le service de mise à jour en temps réel
      RealTimeService().startRealTimeUpdates(tableProvider, restaurantProvider);
      
      // Écouter les messages en premier plan
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📨 Message reçu en premier plan: ${message.notification?.title}');
        
        // Utiliser le NotificationProvider pour gérer le message
        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
        notificationProvider.handleIncomingMessage(message);
        
        // Rafraîchir automatiquement les tables si c'est une attribution de table
        notificationProvider.refreshTablesOnAssignment(context, message);
        
        // Gérer les mises à jour en temps réel des commandes
        notificationProvider.handleRealTimeOrderUpdates(context, message);
        
        // Gérer les messages FCM pour les mises à jour en temps réel
        RealTimeService().handleFCMMessage(message, tableProvider, restaurantProvider);
      });

      // Écouter les messages quand l'app est ouverte depuis une notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('📱 App ouverte depuis une notification: ${message.notification?.title}');
        
        // Marquer la notification comme lue
        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
        notificationProvider.markNotificationAsRead(message);
      });
      
      // Enregistrer le device auprès du backend
      await _registerDevice(context);
      
      // Initialiser le lien entre RestaurantProvider et TableProvider
      restaurantProvider.setTableProvider(tableProvider);
    });
    
    return MaterialApp(
      title: 'Client Manager',
      // Déplacer la gestion du thème à l'intérieur d'un Consumer
      home: Consumer<PreferencesProvider>(
        builder: (context, preferencesProvider, child) {
          return MaterialApp(
            title: 'Client Manager',
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.grey[200],
              colorScheme: ColorScheme.light(
                primary: AppColors.orange,
                secondary: AppColors.orange,
                background: Colors.grey[200]!,
              ),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Colors.black),
              ),
            ),
            // Appliquer le thème en fonction des préférences
            themeMode: preferencesProvider.currentThemeMode,
            darkTheme: ThemeData(
              scaffoldBackgroundColor: AppColors.bgDark,
              colorScheme: ColorScheme.dark(
                primary: AppColors.orange,
                secondary: AppColors.orange,
                background: AppColors.bgDark,
              ),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Colors.white),
              ),
            ),
            // Utilisation de StreamBuilder pour la redirection automatique
            home: StreamBuilder<User?>(
              stream: _authService.authStateChanges(),
              builder: (context, snapshot) {
                // Afficher un indicateur de chargement pendant la vérification
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Rediriger vers la page de connexion si l'utilisateur n'est pas connecté
                if (snapshot.connectionState == ConnectionState.active && snapshot.data == null) {
                  return const LoginPage();
                }

                // Rediriger vers la sélection de restaurant si l'utilisateur est connecté mais sans restaurant sélectionné
                if (snapshot.connectionState == ConnectionState.active && snapshot.data != null) {
                  final restaurantProvider = Provider.of<RestaurantProvider>(context);
                  if (restaurantProvider.selectedRestaurant == null) {
                    return const RestaurantSelectionPage();
                  }
                }

                // Rediriger vers la page d'accueil si l'utilisateur est connecté et a un restaurant sélectionné
                return HomePage();
              },
            ),
          );
        },
      ),
    );
  }

  /// Enregistre le device auprès du backend
  Future<void> _registerDevice(BuildContext context) async {
    // Vérifier si le device est déjà enregistré
    if (_deviceRegistered) {
      print('ℹ️ Device déjà enregistré, passage');
      return;
    }
    
    try {
      // Attendre que l'utilisateur soit connecté
      await Future.delayed(const Duration(seconds: 3));
      
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        final deviceService = DeviceService();
        final fcmToken = await deviceService.getFcmToken();
        
        if (fcmToken != null) {
          // Déterminer la plateforme
          String platform;
          if (defaultTargetPlatform == TargetPlatform.android) {
            platform = 'android';
          } else if (defaultTargetPlatform == TargetPlatform.iOS) {
            platform = 'ios';
          } else {
            platform = 'web';
          }
          
          // Enregistrer le device
          final success = await deviceService.registerDevice(
            email: user.email!,
            fcmToken: fcmToken,
            platform: platform,
          );
          
          if (success) {
            print('✅ Device enregistré avec succès pour ${user.email}');
            setState(() {
              _deviceRegistered = true; // Marquer le device comme enregistré
            });
            
            // Écouter les changements de token
            deviceService.listenForTokenRefresh(user.email!);
          } else {
            print('❌ Échec de l\'enregistrement du device pour ${user.email}');
          }
        } else {
          print('❌ Impossible de récupérer le token FCM pour ${user.email}');
        }
      } else {
        print('❌ Aucun utilisateur connecté');
      }
    } catch (e) {
      print('❌ Erreur lors de l\'enregistrement du device: $e');
    }
  }
}
