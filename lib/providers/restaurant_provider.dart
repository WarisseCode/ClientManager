import 'package:flutter/foundation.dart';
import '../models/restaurant.dart';
import '../providers/table_provider.dart';

class RestaurantProvider with ChangeNotifier {
  Restaurant? _selectedRestaurant;
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  String? _error;
  TableProvider? _tableProvider;

  // Getters
  Restaurant? get selectedRestaurant => _selectedRestaurant;
  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Définit le TableProvider pour pouvoir le nettoyer lorsque le restaurant change
  void setTableProvider(TableProvider tableProvider) {
    _tableProvider = tableProvider;
  }

  /// Sélectionne un restaurant
  void selectRestaurant(Restaurant restaurant) {
    _selectedRestaurant = restaurant;
    // Nettoyer les tables de l'ancien restaurant
    _tableProvider?.clearTables();
    notifyListeners();
  }

  /// Désélectionne le restaurant actuel
  void clearSelection() {
    _selectedRestaurant = null;
    // Nettoyer les tables
    _tableProvider?.clearTables();
    notifyListeners();
  }

  /// Met à jour la liste des restaurants
  void updateRestaurants(List<Restaurant> restaurants) {
    _restaurants = restaurants;
    _error = null;
    notifyListeners();
  }

  /// Définit l'état de chargement
  void setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _error = null;
    }
    notifyListeners();
  }

  /// Définit une erreur
  void setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  /// Efface l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Vérifie si un restaurant est sélectionné
  bool get hasSelectedRestaurant => _selectedRestaurant != null;

  /// Obtient le nom du restaurant sélectionné
  String? get selectedRestaurantName => _selectedRestaurant?.name;

  /// Obtient l'ID du restaurant sélectionné
  String? get selectedRestaurantId => _selectedRestaurant?.id;
}