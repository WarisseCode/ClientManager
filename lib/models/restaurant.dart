class Restaurant {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final bool isOpen;
  // Suppression de activeServers

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.isOpen,
    // Suppression de activeServers
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['nom'] ?? '',
      address: json['address'] ?? json['adresse'] ?? '',
      imageUrl: json['logo'] ?? json['image'] ?? json['logo'] ?? '',
      isOpen: json['isOpen'] ?? json['is_open'] ?? json['open'] ?? true,
      // Suppression de activeServers
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'logo': imageUrl,
      'isOpen': isOpen,
      // Suppression de activeServers
    };
  }

  @override
  String toString() {
    return 'Restaurant(id: $id, name: $name, address: $address, isOpen: $isOpen)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Restaurant && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}