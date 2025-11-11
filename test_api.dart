import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const String baseUrl = 'https://clientmanagerapi.onrender.com';
  const String testEmail = 'martial@clientmanager.com';
  
  print('🔍 Test de l\'API ClientManager');
  print('URL de base: $baseUrl');
  print('Email de test: $testEmail');
  print('');
  
  // Test de l'endpoint des restaurants
  try {
    print('⏳ Requête vers: $baseUrl/servers/$testEmail/restaurants');
    print('🕒 Début de la requête: ${DateTime.now()}');
    
    final request = http.Request(
      'GET',
      Uri.parse('$baseUrl/servers/$testEmail/restaurants'),
    );
    
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'application/json';
    
    final response = await http.Response.fromStream(await request.send());
    
    print('✅ Réponse reçue!');
    print('🕒 Fin de la requête: ${DateTime.now()}');
    print('Status Code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('✅ Succès HTTP 200');
      try {
        final dynamic data = json.decode(response.body);
        print('✅ JSON décodé avec succès');
        print('Type de données: ${data.runtimeType}');
        print('');
        
        if (data is List) {
          print('📋 Liste de ${data.length} éléments reçue');
          for (var i = 0; i < data.length && i < 3; i++) {
            print('Élément $i: ${data[i]}');
          }
        } else if (data is Map<String, dynamic>) {
          print('📋 Objet Map reçu:');
          data.forEach((key, value) {
            print('  $key: $value (type: ${value.runtimeType})');
          });
          
          if (data.containsKey('restaurants')) {
            print('🔑 Clé "restaurants" trouvée');
            final restaurants = data['restaurants'];
            if (restaurants is List) {
              print('📋 ${restaurants.length} restaurants trouvés');
              for (var i = 0; i < restaurants.length && i < 2; i++) {
                print('Restaurant $i: ${restaurants[i]}');
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
    print('❌ Erreur lors de la requête: $e');
    print('🕒 Fin de la requête (erreur): ${DateTime.now()}');
  }
  
  print('');
  print('🏁 Test terminé');
}