import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // Utilisation de l'email warissecodeman@gmail.com
  final email = 'warissecodeman@gmail.com';
  final encodedEmail = Uri.encodeComponent(email);
  
  // URL pour récupérer les restaurants de l'utilisateur
  final restaurantsUrl = 'https://clientmanagerapi.onrender.com/servers/$encodedEmail/restaurants';
  
  print('🔍 Test de l\'API des restaurants pour l\'utilisateur');
  print('Email de test: $email');
  print('URL encodée: $restaurantsUrl');
  print('');
  
  try {
    print('⏳ Récupération des restaurants...');
    final restaurantsResponse = await http.get(Uri.parse(restaurantsUrl)).timeout(Duration(seconds: 30));
    print('✅ Réponse reçue!');
    print('Status: ${restaurantsResponse.statusCode}');
    
    if (restaurantsResponse.statusCode == 200) {
      final dynamic restaurantsData = json.decode(restaurantsResponse.body);
      
      if (restaurantsData is Map<String, dynamic> && restaurantsData.containsKey('restaurants')) {
        final restaurants = restaurantsData['restaurants'] as List<dynamic>;
        print('📋 ${restaurants.length} restaurants trouvés');
        
        // Tester chaque restaurant
        for (var i = 0; i < restaurants.length; i++) {
          final restaurant = restaurants[i] as Map<String, dynamic>;
          final restaurantId = restaurant['id'] as String;
          final restaurantName = restaurant['name'] as String;
          
          print('');
          print('--- Test du restaurant $i: $restaurantName ---');
          
          // URL pour les commandes de ce restaurant
          final ordersUrl = 'https://clientmanagerapi.onrender.com/servers/$encodedEmail/$restaurantId/orders';
          
          try {
            final ordersResponse = await http.get(Uri.parse(ordersUrl)).timeout(Duration(seconds: 30));
            print('Status: ${ordersResponse.statusCode}');
            
            if (ordersResponse.statusCode == 200) {
              final dynamic ordersData = json.decode(ordersResponse.body);
              
              if (ordersData is Map<String, dynamic> && ordersData.containsKey('orders')) {
                final orders = ordersData['orders'] as List<dynamic>;
                print('📋 ${orders.length} commandes trouvées');
                
                if (orders.isNotEmpty) {
                  print('✅ Commandes trouvées pour ce restaurant!');
                  for (var j = 0; j < orders.length && j < 2; j++) {
                    print('Commande $j: ${orders[j]}');
                  }
                } else {
                  print('❌ Aucune commande pour ce restaurant');
                }
              }
            } else {
              print('❌ Erreur HTTP: ${ordersResponse.statusCode}');
            }
          } catch (e) {
            print('❌ Exception lors du test des commandes: $e');
          }
        }
      }
    } else {
      print('❌ Erreur HTTP lors de la récupération des restaurants: ${restaurantsResponse.statusCode}');
    }
  } catch (e) {
    print('❌ Exception lors de la récupération des restaurants: $e');
  }
  
  print('');
  print('🏁 Test terminé');
}