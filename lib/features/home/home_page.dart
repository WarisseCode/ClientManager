import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import '../../core/theme.dart';
import '../auth/auth_service.dart';
import '../auth/login_page.dart';
import '../profile/settings_page.dart';
import '../profile/history_page.dart';
import '../profile/help_page.dart';
import '../restaurant/restaurant_selection_page.dart';
import '../notifications/notifications_page.dart';
import '../tables/tables_page.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/table_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/table.dart' as table_model;
import '../../models/table.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  User? _currentUser;

  final List<Widget> _pages = [
    const DashboardTab(),
    const OrdersTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recharger les données lorsque les dépendances changent (par exemple, lorsque le restaurant change)
    _reloadData();
  }

  // Fonction pour recharger les données
  Future<void> _reloadData() async {
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

  // Fonction pour ouvrir le sélecteur de restaurant
  Future<void> _openRestaurantSelector(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RestaurantSelectionPage()),
    ).then((_) {
      // Recharger les données après le retour de la sélection du restaurant
      _reloadData();
    });
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
              Theme.of(context).colorScheme.background,
              Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF27272A) // bgSecondary pour le thème sombre
                : Colors.grey[300]!, // Couleur équivalente pour le thème clair
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header avec profil actif
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Image du restaurant à la place de l'icône
                    Consumer<RestaurantProvider>(
                      builder: (context, restaurantProvider, child) {
                        final restaurant = restaurantProvider.selectedRestaurant;
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            //color: AppColors.orange,
                            borderRadius: BorderRadius.circular(25),
                            image: restaurant?.imageUrl.isNotEmpty == true
                                ? DecorationImage(
                                    image: NetworkImage(restaurant!.imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: restaurant?.imageUrl.isEmpty == true || restaurant == null
                              ? const Icon(
                                  Icons.restaurant,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : null,
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    
                    // Informations du restaurant
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Provider.of<RestaurantProvider>(context).selectedRestaurant?.name ?? 'Sélectionnez un restaurant',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            Provider.of<RestaurantProvider>(context).selectedRestaurant?.address ?? 'Adresse non disponible',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Bouton de notifications
                    Consumer<NotificationProvider>(
                      builder: (context, notificationProvider, child) {
                        return Stack(
                          children: [
                            IconButton(
                              icon: Icon(Icons.notifications, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                              tooltip: 'Notifications',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const NotificationsPage()),
                                );
                              },
                            ),
                            if (notificationProvider.unreadNotificationsCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    notificationProvider.unreadNotificationsCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    
                    // Bouton de changement de restaurant
                    IconButton(
                      icon: Icon(Icons.switch_account, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                      tooltip: 'Changer de restaurant',
                      onPressed: () => _openRestaurantSelector(context),
                    ),
                  ],
                ),
              ),
              
              // Contenu principal
              Expanded(
                child: _pages[_selectedIndex],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle,
        items: [
          TabItem(icon: Icons.dashboard, title: 'Tableau de bord'),
          TabItem(icon: Icons.restaurant_menu, title: 'Commandes'),
          TabItem(icon: Icons.person, title: 'Profil'),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF27272A) // bgSecondary pour le thème sombre
            : Colors.grey[300], // Couleur équivalente pour le thème clair,
        activeColor: AppColors.orange,
        color: Colors.grey[600],
        curveSize: 80,
      ),
    );
  }
}

// Onglet Tableau de bord
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tableau de bord',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          
          // Statistiques avec Consumer pour accéder aux données du TableProvider
          Consumer<TableProvider>(
            builder: (context, tableProvider, child) {
              // Calculer le nombre total de commandes
              int totalOrders = 0;
              for (final table in tableProvider.tables) {
                totalOrders += table.orderItems.length;
              }
              
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Commandes du jour',
                      '$totalOrders', // Afficher le nombre réel de commandes
                      Icons.restaurant_menu,
                      Colors.blue,
                      context,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Tables servies',
                      '${tableProvider.tables.length}',
                      Icons.table_restaurant,
                      Colors.green,
                      context,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Actions rapides
          Text(
            'Actions rapides',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Voir les tables',
                  Icons.table_restaurant,
                  () {
                    // Navigation vers la page dédiée aux tables
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TablesPage()),
                    );
                  },
                  context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF27272A) // bgSecondary pour le thème sombre
          : Colors.grey[300], // Couleur équivalente pour le thème clair,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey[700]! 
            : Colors.grey[400]!, 
          width: 1
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[400] 
                : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap, BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF27272A) // bgSecondary pour le thème sombre
          : Colors.grey[300], // Couleur équivalente pour le thème clair,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey[700]! 
            : Colors.grey[400]!, 
          width: 1
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.orange, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Onglet Commandes
class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  @override
  void initState() {
    super.initState();
    // Charger les tables lorsque l'onglet est affiché
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

  // Méthode pour recharger les tables lorsqu'une notification est reçue
  Future<void> _refreshTables() async {
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    final tableProvider = Provider.of<TableProvider>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (restaurantProvider.hasSelectedRestaurant && currentUser != null) {
      await tableProvider.refreshTables(
        restaurantId: restaurantProvider.selectedRestaurant!.id,
        serverEmail: currentUser.email ?? '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Commandes en cours',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.refresh, 
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
                ),
                onPressed: _loadTables,
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: Consumer<TableProvider>(
              builder: (context, tableProvider, child) {
                if (tableProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
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
                            color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tableProvider.error ?? 'Une erreur inconnue est survenue',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[400] 
                              : Colors.grey[600],
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
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                // Collecter toutes les commandes de toutes les tables
                final List<table_model.Order> allOrders = [];
                for (final table in tableProvider.tables) {
                  for (final item in table.orderItems) {
                    allOrders.add(table_model.Order.fromOrderItemAndTable(item, table));
                  }
                }

                if (allOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          color: Colors.grey,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune commande en cours',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Les commandes apparaîtront ici une fois passées',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey 
                              : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Trier les commandes par table
                allOrders.sort((a, b) => a.tableNumber.compareTo(b.tableNumber));

                return RefreshIndicator(
                  onRefresh: () async {
                    await _refreshTables();
                  },
                  child: ListView.builder(
                    itemCount: allOrders.length,
                    itemBuilder: (context, index) {
                      final order = allOrders[index];
                      return _buildOrderCard(order, context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(table_model.Order order, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF27272A) // bgSecondary pour le thème sombre
          : Colors.grey[300], // Couleur équivalente pour le thème clair,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey[700]! 
            : Colors.grey[400]!, 
          width: 1
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre principal : nom de la commande (ou description de l'item)
          Text(
            order.items.isNotEmpty ? order.items.first.name : 'Commande',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          // Sous-titre : nom de la table
          Text(
            'Table ${order.tableNumber}',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[400] 
                : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Statut de la commande
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              // Quantité totale d'items
              if (order.items.length > 1)
                Text(
                  '${order.items.length} items',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Afficher les items de la commande (si plus d'un item)
          if (order.items.length > 1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${item.quantity}x ${item.name}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    )),
              ],
            ),
          const SizedBox(height: 8),
          Text(
            '€${order.totalAmount.toStringAsFixed(2)}',
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

// Onglet Profil
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final AuthService _authService = AuthService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
  }

  /// Gestion de la déconnexion
  Future<void> _handleSignOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mon profil',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // Informations du profil
                Container(
                  padding: const EdgeInsets.all(30),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFF27272A) // bgSecondary pour le thème sombre
                      : Colors.grey[300], // Couleur équivalente pour le thème clair,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.orange, 
                      width: 1
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.orange,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentUser?.displayName ?? 
                        _currentUser?.email?.split('@')[0] ?? 
                        'Utilisateur',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentUser?.email ?? 'Email non disponible',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[400] 
                            : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Options du profil
                _buildProfileOption(Icons.settings, 'Paramètres', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                }, context: context),
                _buildProfileOption(Icons.history, 'Historique', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryPage()),
                  );
                }, context: context),
                _buildProfileOption(Icons.help, 'Aide', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HelpPage()),
                  );
                }, context: context),
                _buildProfileOption(Icons.logout, 'Se déconnecter', _handleSignOut, isLogout: true, context: context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap, {bool isLogout = false, required BuildContext context}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF27272A) // bgSecondary pour le thème sombre
          : Colors.grey[300], // Couleur équivalente pour le thème clair,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLogout 
            ? Colors.red[400]! 
            : (Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[700]! 
                : Colors.grey[400]!), 
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon, 
                  color: isLogout 
                    ? Colors.red[400] 
                    : (Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[400] 
                        : Colors.grey[600]), 
                  size: 24
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: isLogout 
                      ? Colors.red[400] 
                      : (Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black),
                    fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios, 
                  color: isLogout 
                    ? Colors.red[400] 
                    : (Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[400] 
                        : Colors.grey[600]), 
                  size: 16
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Classe de notification personnalisée pour rafraîchir les données
class RefreshNotification extends Notification {
  final String message;
  
  RefreshNotification(this.message);
}
