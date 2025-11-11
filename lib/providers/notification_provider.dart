import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // Ajout de cet import pour Provider
import '../services/notification_service.dart';
import '../providers/restaurant_provider.dart';
import '../providers/table_provider.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = true;
  int _unreadNotificationsCount = 0;
  List<RemoteMessage> _notifications = [];

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  int get unreadNotificationsCount => _unreadNotificationsCount;
  List<RemoteMessage> get notifications => List.unmodifiable(_notifications);

  // Setters
  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  // Méthode pour traiter les messages reçus
  Future<void> handleIncomingMessage(RemoteMessage message) async {
    try {
      // Vérifier si les notifications sont activées
      if (!_notificationsEnabled) {
        if (kDebugMode) {
          print('ℹ️ Notifications désactivées, message ignoré');
        }
        return;
      }

      // Ajouter le message à la liste des notifications
      _notifications.add(message);
      _unreadNotificationsCount++;
      
      // Afficher la notification locale
      await _notificationService.showLocalNotification(message);
      
      // Notifier les écouteurs
      notifyListeners();
      
      if (kDebugMode) {
        print('🔔 Nouvelle notification reçue: ${message.notification?.title}');
        print('📊 Nombre de notifications non lues: $_unreadNotificationsCount');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors du traitement du message: $e');
      }
    }
  }

  // Méthode pour marquer une notification comme lue
  void markNotificationAsRead(RemoteMessage message) {
    if (_notifications.contains(message) && _unreadNotificationsCount > 0) {
      _unreadNotificationsCount--;
      notifyListeners();
      
      if (kDebugMode) {
        print('✅ Notification marquée comme lue');
      }
    }
  }

  // Méthode pour marquer toutes les notifications comme lues
  void markAllNotificationsAsRead() {
    _unreadNotificationsCount = 0;
    notifyListeners();
    
    if (kDebugMode) {
      print('✅ Toutes les notifications marquées comme lues');
    }
  }

  // Méthode pour supprimer une notification
  void removeNotification(RemoteMessage message) {
    _notifications.remove(message);
    if (_unreadNotificationsCount > 0) {
      _unreadNotificationsCount--;
    }
    notifyListeners();
    
    if (kDebugMode) {
      print('🗑️ Notification supprimée');
    }
  }

  // Méthode pour effacer toutes les notifications
  void clearAllNotifications() {
    _notifications.clear();
    _unreadNotificationsCount = 0;
    notifyListeners();
    
    if (kDebugMode) {
      print('🧹 Toutes les notifications effacées');
    }
  }

  // Méthode pour vérifier si un message est une attribution de table
  bool isTableAssignmentMessage(RemoteMessage message) {
    // Vérifier si le message concerne une attribution de table
    final String? type = message.data['type'] as String?;
    final String? title = message.notification?.title;
    final String? body = message.notification?.body;
    final String? status = message.data['status'] as String?;
    
    bool isTableAssignment = type == 'table_assignment' || 
           status == 'VALIDATE' ||  // Nouveau: gérer le statut VALIDATE du webhook
           (title != null && title.toLowerCase().contains('table')) ||
           (body != null && body.toLowerCase().contains('table'));
    
    if (kDebugMode && isTableAssignment) {
      print('🎯 Message identifié comme attribution de table');
    }
    
    return isTableAssignment;
  }
  
  // Méthode pour obtenir le numéro de table depuis le message
  String? getTableNumberFromMessage(RemoteMessage message) {
    // Essayer d'extraire le numéro de table depuis les données
    final String? tableNumber = message.data['tableNumber'] as String?;
    if (tableNumber != null) {
      return tableNumber;
    }
    
    // Pour le webhook, l'ID de la table est dans tableId
    final String? tableId = message.data['tableId'] as String?;
    if (tableId != null) {
      // On peut utiliser l'ID de la table ou le formater si nécessaire
      return tableId.substring(0, tableId.length < 8 ? tableId.length : 8); // Retourner les 8 premiers caractères
    }
    
    // Essayer d'extraire depuis le titre ou le corps
    final String? title = message.notification?.title;
    final String? body = message.notification?.body;
    
    // Expression régulière pour trouver un numéro de table
    final RegExp tableNumberRegex = RegExp(r'table\s*(\d+)', caseSensitive: false);
    
    if (title != null) {
      final Match? match = tableNumberRegex.firstMatch(title);
      if (match != null) {
        return match.group(1);
      }
    }
    
    if (body != null) {
      final Match? match = tableNumberRegex.firstMatch(body);
      if (match != null) {
        return match.group(1);
      }
    }
    
    return null;
  }
  
  // Méthode pour obtenir l'ID de commande depuis le message
  String? getOrderIdFromMessage(RemoteMessage message) {
    // Pour le webhook, l'ID de commande est dans orderId
    final String? orderId = message.data['orderId'] as String?;
    return orderId;
  }
  
  // Méthode pour rafraîchir automatiquement les données lorsque une nouvelle attribution est reçue
  Future<void> refreshTablesOnAssignment(BuildContext context, RemoteMessage message) async {
    try {
      // Vérifier si le message concerne une attribution de table
      if (!isTableAssignmentMessage(message)) {
        return;
      }
      
      if (kDebugMode) {
        print('🔄 Rafraîchissement des tables après attribution');
      }
      
      // Obtenir les providers nécessaires
      final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
      final tableProvider = Provider.of<TableProvider>(context, listen: false);
      final currentUser = FirebaseAuth.instance.currentUser;
      
      // Vérifier que l'utilisateur est connecté et qu'un restaurant est sélectionné
      if (currentUser != null && restaurantProvider.hasSelectedRestaurant) {
        // Rafraîchir les tables
        await tableProvider.refreshTables(
          restaurantId: restaurantProvider.selectedRestaurant!.id,
          serverEmail: currentUser.email ?? '',
        );
        
        if (kDebugMode) {
          print('✅ Tables rafraîchies avec succès');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors du rafraîchissement des tables: $e');
      }
    }
  }
  
  // Méthode pour gérer les mises à jour en temps réel des commandes
  Future<void> handleRealTimeOrderUpdates(BuildContext context, RemoteMessage message) async {
    try {
      // Vérifier si le message concerne une mise à jour de commande
      final String? type = message.data['type'] as String?;
      final String? status = message.data['status'] as String?;
      
      bool isOrderUpdate = type == 'order_update' || 
                          type == 'new_order' || 
                          status == 'VALIDATE' || 
                          status == 'PENDING' || 
                          status == 'READY' || 
                          status == 'SERVED' || 
                          status == 'CANCELLED';
      
      if (!isOrderUpdate) {
        return;
      }
      
      if (kDebugMode) {
        print('🔄 Mise à jour en temps réel des commandes');
      }
      
      // Obtenir les providers nécessaires
      final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
      final tableProvider = Provider.of<TableProvider>(context, listen: false);
      final currentUser = FirebaseAuth.instance.currentUser;
      
      // Vérifier que l'utilisateur est connecté et qu'un restaurant est sélectionné
      if (currentUser != null && restaurantProvider.hasSelectedRestaurant) {
        // Rafraîchir les tables pour obtenir les dernières données
        await tableProvider.refreshTables(
          restaurantId: restaurantProvider.selectedRestaurant!.id,
          serverEmail: currentUser.email ?? '',
        );
        
        if (kDebugMode) {
          print('✅ Commandes mises à jour en temps réel avec succès');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la mise à jour en temps réel des commandes: $e');
      }
    }
  }
}