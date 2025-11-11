import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../../core/theme_utils.dart';
import '../../models/table.dart' as table_model;
import '../../providers/table_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../home/home_page.dart';

class TablesPage extends StatefulWidget {
  const TablesPage({super.key});

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  @override
  void initState() {
    super.initState();
    // Charger les tables lorsque la page est affichée
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTables();
    });
  }

  Future<void> _loadTables() async {
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    final tableProvider = Provider.of<TableProvider>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (restaurantProvider.hasSelectedRestaurant && currentUser != null) {
      await tableProvider.loadTables(
        restaurantId: restaurantProvider.selectedRestaurant!.id,
        serverEmail: currentUser.email ?? '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ThemeUtils.getBackgroundColor(context),
              ThemeUtils.getSecondaryColor(context),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      },
                      icon: Icon(Icons.arrow_back, color: ThemeUtils.getPrimaryTextColor(context)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tables',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ThemeUtils.getPrimaryTextColor(context),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: ThemeUtils.getPrimaryTextColor(context)),
                      onPressed: _loadTables,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Contenu principal
                Expanded(
                  child: Consumer<TableProvider>(
                    builder: (context, tableProvider, child) {
                      if (tableProvider.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orange),
                            backgroundColor: ThemeUtils.getSecondaryColor(context),
                          ),
                        );
                      }

                      if (tableProvider.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red[400],
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Erreur de chargement',
                                style: TextStyle(
                                  color: ThemeUtils.getPrimaryTextColor(context),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tableProvider.error ?? 'Une erreur inconnue est survenue',
                                style: TextStyle(
                                  color: ThemeUtils.getSecondaryTextColor(context),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _loadTables,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.orange,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('Réessayer', 
                                    style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context))),
                              ),
                            ],
                          ),
                        );
                      }

                      if (tableProvider.tables.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.table_restaurant,
                                color: ThemeUtils.getIconColor(context),
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune table disponible',
                                style: TextStyle(
                                  color: ThemeUtils.getPrimaryTextColor(context),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Les tables apparaîtront ici une fois disponibles',
                                style: TextStyle(
                                  color: ThemeUtils.getSecondaryTextColor(context),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: tableProvider.tables.length,
                        itemBuilder: (context, index) {
                          final table = tableProvider.tables[index];
                          return _buildTableCard(context, table);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableCard(BuildContext context, table_model.Table table) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeUtils.getSecondaryColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeUtils.getBorderColor(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Table ${table.tableNumber}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ThemeUtils.getPrimaryTextColor(context),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(table.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  table.status,
                  style: TextStyle(
                    color: ThemeUtils.getPrimaryTextColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (table.orderItems.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...table.orderItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${item.quantity}x ${item.name}',
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeUtils.getSecondaryTextColor(context),
                        ),
                      ),
                    )),
              ],
            ),
          const SizedBox(height: 8),
          Text(
            '€${table.totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en cours':
        return Colors.orange[600]!;
      case 'prête':
        return Colors.green[600]!;
      case 'servie':
        return Colors.blue[600]!;
      case 'annulée':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}