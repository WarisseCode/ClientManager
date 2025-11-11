import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/table.dart';
import '../models/restaurant.dart';

class TableService {
  static const String _baseUrl = 'https://clientmanagerapi.onrender.com';

  /// Récupère la liste des commandes pour un serveur dans un restaurant spécifique
  Future<List<Table>> fetchTables({
    required String restaurantId,
    required String serverEmail,
    String? date, // Format: YYYY-MM-DD
  }) async {
    try {
      // Construction de l'URL selon la documentation:
      // GET /servers/:email/:restaurantId/orders?date=YYYY-MM-DD
      final encodedEmail = Uri.encodeComponent(serverEmail);
      final url = '$_baseUrl/servers/$encodedEmail/$restaurantId/orders${date != null ? '?date=$date' : ''}';
      
      final response = await http.get(
        Uri.parse(url),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        if (decoded is List) {
          return decoded.map<Table>((item) => Table.fromJson(item as Map<String, dynamic>)).toList();
        }
        
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('orders') && decoded['orders'] is List) {
            // Adapter la structure des commandes aux tables
            final List<dynamic> ordersData = decoded['orders'] as List<dynamic>;
            return _convertOrdersToTables(ordersData, restaurantId);
          }
          
          // Single object fallback
          return [Table.fromJson(decoded)];
        }

        throw Exception('Format de réponse inattendu');
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des commandes: $e');
      rethrow;
    }
  }

  /// Convertit les commandes de l'API en objets Table
  List<Table> _convertOrdersToTables(List<dynamic> orders, String restaurantId) {
    // Regrouper les commandes par table
    final Map<String, List<Map<String, dynamic>>> ordersByTable = {};
    
    for (var order in orders) {
      if (order is Map<String, dynamic>) {
        final tableInfo = order['table'] as Map<String, dynamic>?;
        if (tableInfo != null && tableInfo.containsKey('id')) {
          final tableId = tableInfo['id'].toString();
          if (!ordersByTable.containsKey(tableId)) {
            ordersByTable[tableId] = [];
          }
          ordersByTable[tableId]!.add(order);
        }
      }
    }
    
    // Créer des objets Table à partir des commandes groupées
    final List<Table> tables = [];
    ordersByTable.forEach((tableId, tableOrders) {
      // Extraire les informations de la première commande pour cette table
      final firstOrder = tableOrders.first;
      final tableInfo = firstOrder['table'] as Map<String, dynamic>;
      
      // Créer des OrderItem à partir des commandes
      final List<OrderItem> orderItems = [];
      double totalAmount = 0.0;
      
      for (var order in tableOrders) {
        // Pour simplifier, on crée un item par commande
        // Dans une implémentation réelle, il faudrait parser les items de chaque commande
        orderItems.add(OrderItem(
          id: order['id']?.toString() ?? '',
          name: 'Commande #${order['id']?.toString().substring(0, 6) ?? ''}',
          quantity: 1,
          price: 0.0, // L'API ne fournit pas le prix dans cet exemple
        ));
        // totalAmount += order['amount'] ?? 0.0; // Si disponible
      }
      
      tables.add(Table(
        id: tableId,
        tableNumber: tableInfo['name']?.toString() ?? tableId,
        status: _convertStatus(firstOrder['status']?.toString() ?? 'En cours'),
        orderItems: orderItems,
        totalAmount: totalAmount,
        serverId: '', // Non disponible dans cette API
        restaurantId: restaurantId,
      ));
    });
    
    return tables;
  }

  /// Convertit le statut de l'API en statut d'affichage
  String _convertStatus(String apiStatus) {
    switch (apiStatus.toUpperCase()) {
      case 'VALIDATE':
        return 'Validée';
      case 'PENDING':
        return 'En cours';
      case 'READY':
        return 'Prête';
      case 'SERVED':
        return 'Servie';
      case 'CANCELLED':
        return 'Annulée';
      default:
        return apiStatus;
    }
  }

  /// Récupère une commande spécifique par son ID
  Future<Table?> fetchTableById({
    required String tableId,
    required String restaurantId,
    required String serverEmail,
  }) async {
    try {
      final encodedEmail = Uri.encodeComponent(serverEmail);
      final url = '$_baseUrl/servers/$encodedEmail/$restaurantId/orders/$tableId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          // Convertir une commande individuelle en Table
          final tableInfo = decoded['table'] as Map<String, dynamic>?;
          if (tableInfo != null) {
            return Table(
              id: tableInfo['id']?.toString() ?? '',
              tableNumber: tableInfo['name']?.toString() ?? '',
              status: _convertStatus(decoded['status']?.toString() ?? 'En cours'),
              orderItems: [
                OrderItem(
                  id: decoded['id']?.toString() ?? '',
                  name: 'Commande #${decoded['id']?.toString().substring(0, 6) ?? ''}',
                  quantity: 1,
                  price: 0.0,
                )
              ],
              totalAmount: 0.0,
              serverId: '',
              restaurantId: restaurantId,
            );
          }
        }
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la récupération de la commande $tableId: $e');
      return null;
    }
  }
}