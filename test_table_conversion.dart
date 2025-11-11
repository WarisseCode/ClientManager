import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/models/table.dart';
import 'lib/services/table_service.dart';

void main() async {
  // Simuler une réponse de l'API avec des données de test
  final String mockResponse = '''
  {
    "orders": [
      {
        "id": "ORD123",
        "status": "VALIDATE",
        "createdAt": "2025-09-23T10:30:00Z",
        "table": {
          "id": "12",
          "name": "Table 5"
        }
      },
      {
        "id": "ORD124",
        "status": "PENDING",
        "createdAt": "2025-09-23T11:30:00Z",
        "table": {
          "id": "15",
          "name": "Table 8"
        }
      }
    ]
  }
  ''';
  
  print('🔍 Test de conversion des données API en objets Table');
  print('');
  
  try {
    final dynamic data = json.decode(mockResponse);
    print('✅ JSON décodé avec succès');
    
    if (data is Map<String, dynamic> && data.containsKey('orders')) {
      final orders = data['orders'] as List<dynamic>;
      print('📋 ${orders.length} commandes trouvées dans la réponse simulée');
      
      // Tester la conversion avec le service
      final tableService = TableService();
      
      // Utiliser la méthode privée via un hack (seulement pour le test)
      // En pratique, cette méthode serait appelée par fetchTables
      final List<Table> tables = _convertOrdersToTablesForTest(orders, 'test-restaurant-id');
      
      print('🔄 Conversion en objets Table réussie');
      print('📋 ${tables.length} tables créées');
      
      for (var i = 0; i < tables.length; i++) {
        final table = tables[i];
        print('');
        print('Table $i:');
        print('  ID: ${table.id}');
        print('  Numéro: ${table.tableNumber}');
        print('  Statut: ${table.status}');
        print('  Montant total: ${table.totalAmount}');
        print('  Articles: ${table.orderItems.length}');
        for (var j = 0; j < table.orderItems.length; j++) {
          final item = table.orderItems[j];
          print('    - ${item.name} (x${item.quantity}) ${item.price}€');
        }
      }
    }
  } catch (e) {
    print('❌ Erreur lors du test: $e');
  }
  
  print('');
  print('🏁 Test terminé');
}

// Copie de la méthode privée pour le test
List<Table> _convertOrdersToTablesForTest(List<dynamic> orders, String restaurantId) {
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
      status: _convertStatusForTest(firstOrder['status']?.toString() ?? 'En cours'),
      orderItems: orderItems,
      totalAmount: totalAmount,
      serverId: '', // Non disponible dans cette API
      restaurantId: restaurantId,
    ));
  });
  
  return tables;
}

// Copie de la méthode privée pour le test
String _convertStatusForTest(String apiStatus) {
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