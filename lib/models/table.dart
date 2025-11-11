class Table {
  final String id;
  final String tableNumber;
  final String status;
  final List<OrderItem> orderItems;
  final double totalAmount;
  final String serverId;
  final String restaurantId;

  Table({
    required this.id,
    required this.tableNumber,
    required this.status,
    required this.orderItems,
    required this.totalAmount,
    required this.serverId,
    required this.restaurantId,
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    List<OrderItem> items = [];
    if (json['orderItems'] is List) {
      items = (json['orderItems'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return Table(
      id: json['id']?.toString() ?? '',
      tableNumber: json['tableNumber'] ?? json['table_number'] ?? '',
      status: json['status'] ?? 'En cours',
      orderItems: items,
      totalAmount: (json['totalAmount'] ?? json['total_amount'] ?? 0.0).toDouble(),
      serverId: json['serverId'] ?? json['server_id'] ?? '',
      restaurantId: json['restaurantId'] ?? json['restaurant_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'status': status,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'serverId': serverId,
      'restaurantId': restaurantId,
    };
  }

  @override
  String toString() {
    return 'Table(id: $id, tableNumber: $tableNumber, status: $status, totalAmount: $totalAmount)';
  }
}

class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  @override
  String toString() {
    return 'OrderItem(id: $id, name: $name, quantity: $quantity, price: $price)';
  }
}

// Nouvelle classe pour représenter une commande individuelle avec information de la table
class Order {
  final String id;
  final String tableId;
  final String tableNumber;
  final String status;
  final List<OrderItem> items;
  final double totalAmount;

  Order({
    required this.id,
    required this.tableId,
    required this.tableNumber,
    required this.status,
    required this.items,
    required this.totalAmount,
  });

  // Créer une commande à partir d'un OrderItem et des informations de la table
  factory Order.fromOrderItemAndTable(OrderItem item, Table table) {
    return Order(
      id: item.id,
      tableId: table.id,
      tableNumber: table.tableNumber,
      status: table.status,
      items: [item],
      totalAmount: item.price * item.quantity,
    );
  }
}