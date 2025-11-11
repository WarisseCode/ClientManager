import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // Utilisation de l'email warissecodeman@gmail.com
  final email = 'warissecodeman@gmail.com';
  final encodedEmail = Uri.encodeComponent(email);
  
  // Utiliser le deuxième restaurant de la liste
  final restaurantId = '851409c9-7b78-4e1c-ace9-0b6abccc9fcb'; // ID du restaurant "Mira Blanc"
  
  // URL corrigée selon la documentation: GET /servers/:email/:restaurantId/orders
  final url = 'https://clientmanagerapi.onrender.com/servers/$encodedEmail/$restaurantId/orders';
  
  print('🔍 Test de l\'API des commandes');
  print('Email de test: $email');
  print('Restaurant ID: $restaurantId');
  print('URL encodée: $url');
  print('');
  
  try {
    print('⏳ Envoi de la requête...');
    final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 30));
    print('✅ Réponse reçue!');
    print('Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('✅ Succès HTTP 200');
      try {
        final dynamic data = json.decode(response.body);
        print('✅ JSON décodé avec succès');
        print('Type de données: ${data.runtimeType}');
        print('');
        
        if (data is List) {
          print('📋 Liste de ${data.length} éléments reçue');
          if (data.isNotEmpty) {
            for (var i = 0; i < data.length && i < 3; i++) {
              print('Élément $i: ${data[i]}');
            }
          } else {
            print('❌ Liste vide');
          }
        } else if (data is Map<String, dynamic>) {
          print('📋 Objet Map reçu:');
          data.forEach((key, value) {
            print('  $key: $value (type: ${value.runtimeType})');
          });
          
          if (data.containsKey('orders')) {
            print('🔑 Clé "orders" trouvée');
            final orders = data['orders'];
            if (orders is List) {
              print('📋 ${orders.length} commandes trouvées');
              if (orders.isNotEmpty) {
                for (var i = 0; i < orders.length && i < 2; i++) {
                  print('Commande $i: ${orders[i]}');
                }
              } else {
                print('❌ Aucune commande dans la liste');
              }
            }
          }
        } else {
          print('❓ Type de données inattendu: ${data.runtimeType}');
          print('Contenu: $data');
        }
      } catch (e) {
        print('❌ Erreur lors du décodage JSON: $e');
        print('Contenu brut: ${response.body}');
      }
    } else {
      print('❌ Erreur HTTP: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
  
  print('');
  print('🏁 Test terminé');
}