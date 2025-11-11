import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';

class RestaurantService {
  static const String _baseUrl = 'https://clientmanagerapi.onrender.com';
  
  static String _restaurantsEndpointFor(String email) => '/servers/${Uri.encodeComponent(email)}/restaurants';

  /// Récupère la liste des restaurants depuis l'API pour un serveur (email)
  Future<List<Restaurant>> fetchRestaurants({required String email}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${_restaurantsEndpointFor(email)}'),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        if (decoded is List) {
          return decoded.map<Restaurant>((item) => Restaurant.fromJson(item as Map<String, dynamic>)).toList();
        }
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('restaurants') && decoded['restaurants'] is List) {
            final List<dynamic> restaurantsData = decoded['restaurants'] as List<dynamic>;
            return restaurantsData.map((json) => Restaurant.fromJson(json as Map<String, dynamic>)).toList();
          }
          // Single object fallback
          return [Restaurant.fromJson(decoded)];
        }

        throw Exception('Format de réponse inattendu');
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des restaurants: $e');
      return _getMockRestaurants();
    }
  }

  /// Récupère un restaurant spécifique par son ID pour un serveur (email)
  Future<Restaurant?> fetchRestaurantById({required String email, required String id}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${_restaurantsEndpointFor(email)}/$id'),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return Restaurant.fromJson(decoded);
        }
        if (decoded is List && decoded.isNotEmpty) {
          return Restaurant.fromJson(decoded.first as Map<String, dynamic>);
        }
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la récupération du restaurant $id: $e');
      return null;
    }
  }

  /// Données de démonstration en cas d'erreur API
  List<Restaurant> _getMockRestaurants() {
    return [
      Restaurant(
        id: '1',
        name: 'Le Bistrot Parisien',
        address: '123 Rue de la Paix, Paris',
        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
        isOpen: true,
      ),
      Restaurant(
        id: '2',
        name: 'La Terrasse du Sud',
        address: '45 Avenue des Champs, Lyon',
        imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
        isOpen: true,
      ),
      Restaurant(
        id: '3',
        name: 'Chez Marie',
        address: '78 Boulevard Saint-Germain, Paris',
        imageUrl: 'https://images.unsplash.com/photo-1551218808-94e220e084d2?w=400',
        isOpen: false,
      ),
      Restaurant(
        id: '4',
        name: 'Le Petit Café',
        address: '12 Place du Marché, Marseille',
        imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=400',
        isOpen: true,
      ),
    ];
  }
}
