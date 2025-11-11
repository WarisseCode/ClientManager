import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/table.dart';
import '../services/table_service.dart';
import '../providers/restaurant_provider.dart';

class TableProvider with ChangeNotifier {
  List<Table> _tables = [];
  bool _isLoading = false;
  String? _error;
  final TableService _tableService = TableService();
  
  // Stream controller pour les mises à jour en temps réel
  final StreamController<List<Table>> _tableStreamController = StreamController<List<Table>>.broadcast();
  Stream<List<Table>> get tableStream => _tableStreamController.stream;

  // Getters
  List<Table> get tables => _tables;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  int get tableCount => _tables.length;

  /// Charge les tables pour le restaurant sélectionné
  Future<void> loadTables({
    required String restaurantId,
    required String serverEmail,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final tables = await _tableService.fetchTables(
        restaurantId: restaurantId,
        serverEmail: serverEmail,
      );
      _tables = tables;
      
      // Émettre les nouvelles données via le stream
      _tableStreamController.sink.add(tables);
    } catch (e) {
      _error = e.toString();
      print('Erreur lors du chargement des tables: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Met à jour la liste des tables
  void updateTables(List<Table> tables) {
    _tables = tables;
    _error = null;
    
    // Émettre les nouvelles données via le stream
    _tableStreamController.sink.add(tables);
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

  /// Rafraîchit les tables
  Future<void> refreshTables({
    required String restaurantId,
    required String serverEmail,
  }) async {
    await loadTables(
      restaurantId: restaurantId,
      serverEmail: serverEmail,
    );
  }

  /// Obtient une table par son ID
  Table? getTableById(String id) {
    try {
      return _tables.firstWhere((table) => table.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Filtre les tables par statut
  List<Table> getTablesByStatus(String status) {
    return _tables.where((table) => table.status == status).toList();
  }

  /// Efface les tables actuelles
  void clearTables() {
    _tables = [];
    _error = null;
    notifyListeners();
  }
  
  /// Ajoute ou met à jour une table spécifique
  void upsertTable(Table table) {
    // Vérifier si la table existe déjà
    final int existingIndex = _tables.indexWhere((t) => t.id == table.id);
    
    if (existingIndex != -1) {
      // Mettre à jour la table existante
      _tables[existingIndex] = table;
    } else {
      // Ajouter la nouvelle table
      _tables.add(table);
    }
    
    _error = null;
    
    // Émettre les nouvelles données via le stream
    _tableStreamController.sink.add(_tables);
    notifyListeners();
  }
  
  /// Supprime une table par son ID
  void removeTableById(String id) {
    _tables.removeWhere((table) => table.id == id);
    
    // Émettre les nouvelles données via le stream
    _tableStreamController.sink.add(_tables);
    notifyListeners();
  }
  
  /// Ferme le stream controller
  void dispose() {
    _tableStreamController.close();
    super.dispose();
  }
}