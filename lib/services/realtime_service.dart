import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../providers/table_provider.dart';
import '../providers/restaurant_provider.dart';
import '../models/table.dart';
import '../models/restaurant.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RealTimeService {
  static final RealTimeService _instance = RealTimeService._internal();
  factory RealTimeService() => _instance;
  RealTimeService._internal();
  
  Timer? _refreshTimer;
  
  /// Démarre l'écoute des mises à jour en temps réel
  void startRealTimeUpdates(TableProvider tableProvider, RestaurantProvider restaurantProvider) {
    // Annuler le timer existant s'il y en a un
    _refreshTimer?.cancel();
    
    // Créer un timer pour rafraîchir périodiquement les données (toutes les 30 secondes)
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _refreshData(tableProvider, restaurantProvider);
    });
    
    if (kDebugMode) {
      print('🔄 Service de mise à jour en temps réel démarré');
    }
  }
  
  /// Rafraîchit les données depuis l'API
  Future<void> _refreshData(TableProvider tableProvider, RestaurantProvider restaurantProvider) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      
      // Vérifier que l'utilisateur est connecté et qu'un restaurant est sélectionné
      if (currentUser != null && restaurantProvider.hasSelectedRestaurant) {
        await tableProvider.refreshTables(
          restaurantId: restaurantProvider.selectedRestaurant!.id,
          serverEmail: currentUser.email ?? '',
        );
        
        /* if (kDebugMode) {
          print('✅ Données mises à jour en temps réel');
        } */
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la mise à jour en temps réel: $e');
      }
    }
  }
  
  /// Gère les messages FCM reçus pour les mises à jour en temps réel
  Future<void> handleFCMMessage(RemoteMessage message, TableProvider tableProvider, RestaurantProvider restaurantProvider) async {
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
      
      if (isOrderUpdate) {
        if (kDebugMode) {
          print('🔄 Mise à jour en temps réel déclenchée par FCM');
        }
        
        // Rafraîchir immédiatement les données
        await _refreshData(tableProvider, restaurantProvider);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors du traitement du message FCM: $e');
      }
    }
  }
  
  /// Arrête l'écoute des mises à jour en temps réel
  void stopRealTimeUpdates() {
    _refreshTimer?.cancel();
    
    if (kDebugMode) {
      print('🛑 Service de mise à jour en temps réel arrêté');
    }
  }
}