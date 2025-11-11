import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/theme_utils.dart';

/// Page d'historique de l'activité utilisateur
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Données simulées pour l'historique
  final List<HistoryItem> _recentActivity = [
    HistoryItem(
      title: 'Connexion réussie',
      subtitle: 'Connexion via Google',
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      type: HistoryType.login,
      icon: Icons.login,
    ),
    HistoryItem(
      title: 'Commande terminée',
      subtitle: 'Table 5 - €45.50',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      type: HistoryType.order,
      icon: Icons.restaurant_menu,
    ),
    HistoryItem(
      title: 'Nouvelle commande',
      subtitle: 'Table 3 - 4 personnes',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      type: HistoryType.order,
      icon: Icons.add_circle,
    ),
    HistoryItem(
      title: 'Mise à jour du profil',
      subtitle: 'Informations personnelles modifiées',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: HistoryType.profile,
      icon: Icons.person,
    ),
    HistoryItem(
      title: 'Connexion réussie',
      subtitle: 'Connexion via Email',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: HistoryType.login,
      icon: Icons.email,
    ),
  ];

  final List<OrderHistory> _orderHistory = [
    OrderHistory(
      id: 'ORD-001',
      tableNumber: 5,
      total: 45.50,
      items: ['Pizza Margherita', 'Salade César', 'Coca-Cola'],
      date: DateTime.now().subtract(const Duration(hours: 2)),
      status: OrderStatus.completed,
    ),
    OrderHistory(
      id: 'ORD-002',
      tableNumber: 3,
      total: 32.75,
      items: ['Pasta Carbonara', 'Tiramisu'],
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: OrderStatus.completed,
    ),
    OrderHistory(
      id: 'ORD-003',
      tableNumber: 7,
      total: 28.90,
      items: ['Burger Deluxe', 'Frites'],
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: OrderStatus.completed,
    ),
  ];

  final List<Achievement> _achievements = [
    Achievement(
      title: 'Premier service',
      description: 'Votre première commande',
      date: DateTime.now().subtract(const Duration(days: 30)),
      icon: Icons.star,
      isUnlocked: true,
    ),
    Achievement(
      title: 'Service rapide',
      description: 'Commande traitée en moins de 5 minutes',
      date: DateTime.now().subtract(const Duration(days: 15)),
      icon: Icons.speed,
      isUnlocked: true,
    ),
    Achievement(
      title: 'Client satisfait',
      description: 'Note 5 étoiles reçue',
      date: DateTime.now().subtract(const Duration(days: 10)),
      icon: Icons.thumb_up,
      isUnlocked: true,
    ),
    Achievement(
      title: 'Expert du service',
      description: '100 commandes traitées',
      date: null,
      icon: Icons.emoji_events,
      isUnlocked: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          child: Column(
            children: [
              // Header avec bouton retour
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: ThemeUtils.getPrimaryTextColor(context)),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Historique',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ThemeUtils.getPrimaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Statistiques rapides
              _buildQuickStats(context),
              
              // Onglets
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: ThemeUtils.getSecondaryColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeUtils.getBorderColor(context), width: 1),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: ThemeUtils.getPrimaryTextColor(context),
                  unselectedLabelColor: ThemeUtils.getSecondaryTextColor(context),
                  tabs: [
                    Tab(text: 'Activité'),
                    Tab(text: 'Commandes'),
                    Tab(text: 'Succès'),
                  ],
                ),
              ),
              
              // Contenu des onglets
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildActivityTab(context),
                    _buildOrdersTab(context),
                    _buildAchievementsTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeUtils.getSecondaryColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeUtils.getBorderColor(context), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(context, 'Commandes', '\${_orderHistory.length}', Icons.restaurant_menu),
          ),
          Container(
            width: 1,
            height: 40,
            color: ThemeUtils.getBorderColor(context),
          ),
          Expanded(
            child: _buildStatItem(context, 'Succès', '\${_achievements.where((a) => a.isUnlocked).length}', Icons.emoji_events),
          ),
          Container(
            width: 1,
            height: 40,
            color: ThemeUtils.getBorderColor(context),
          ),
          Expanded(
            child: _buildStatItem(context, 'Note', '4.8/5', Icons.star),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.orange, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ThemeUtils.getPrimaryTextColor(context),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: ThemeUtils.getSecondaryTextColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTab(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _recentActivity.length,
      itemBuilder: (context, index) {
        final item = _recentActivity[index];
        return _buildActivityItem(context, item);
      },
    );
  }

  Widget _buildActivityItem(BuildContext context, HistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeUtils.getSecondaryColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeUtils.getBorderColor(context), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTypeColor(item.type).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.icon,
              color: _getTypeColor(item.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeUtils.getPrimaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeUtils.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(item.time),
            style: TextStyle(
              fontSize: 12,
              color: ThemeUtils.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _orderHistory.length,
      itemBuilder: (context, index) {
        final order = _orderHistory[index];
        return _buildOrderItem(context, order);
      },
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderHistory order) {
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
                'Commande \${order.id}',
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
                  color: Colors.green[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Terminée',
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
          Text(
            'Table \${order.tableNumber} • \${_formatDate(order.date)}',
            style: TextStyle(
              fontSize: 14,
              color: ThemeUtils.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.items.join(', '),
            style: TextStyle(
              fontSize: 14,
              color: ThemeUtils.getPrimaryTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '€\${order.total.toStringAsFixed(2)}',
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

  Widget _buildAchievementsTab(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final achievement = _achievements[index];
        return _buildAchievementItem(context, achievement);
      },
    );
  }

  Widget _buildAchievementItem(BuildContext context, Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.isUnlocked 
            ? ThemeUtils.getSecondaryColor(context) 
            : ThemeUtils.getSecondaryColor(context).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked 
              ? ThemeUtils.getBorderColor(context) 
              : ThemeUtils.getBorderColor(context).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: achievement.isUnlocked 
                  ? AppColors.orange.withOpacity(0.2)
                  : ThemeUtils.getSecondaryTextColor(context).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              achievement.icon,
              color: achievement.isUnlocked 
                  ? AppColors.orange 
                  : ThemeUtils.getSecondaryTextColor(context),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: achievement.isUnlocked 
                        ? ThemeUtils.getPrimaryTextColor(context) 
                        : ThemeUtils.getSecondaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: achievement.isUnlocked 
                        ? ThemeUtils.getSecondaryTextColor(context) 
                        : ThemeUtils.getSecondaryTextColor(context).withOpacity(0.7),
                  ),
                ),
                if (achievement.date != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Débloqué le \${_formatDate(achievement.date!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeUtils.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (achievement.isUnlocked)
            Icon(
              Icons.check_circle,
              color: Colors.green[400],
              size: 20,
            )
          else
            Icon(
              Icons.lock,
              color: ThemeUtils.getSecondaryTextColor(context),
              size: 20,
            ),
        ],
      ),
    );
  }

  Color _getTypeColor(HistoryType type) {
    switch (type) {
      case HistoryType.login:
        return Colors.blue;
      case HistoryType.order:
        return Colors.green;
      case HistoryType.profile:
        return Colors.purple;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return 'Il y a \${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Il y a \${difference.inHours}h';
    } else {
      return 'Il y a \${difference.inDays}j';
    }
  }

  String _formatDate(DateTime date) {
    return '\${date.day}/\${date.month}/\${date.year}';
  }
}

// Modèles de données
class HistoryItem {
  final String title;
  final String subtitle;
  final DateTime time;
  final HistoryType type;
  final IconData icon;

  HistoryItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
    required this.icon,
  });
}

enum HistoryType { login, order, profile }

class OrderHistory {
  final String id;
  final int tableNumber;
  final double total;
  final List<String> items;
  final DateTime date;
  final OrderStatus status;

  OrderHistory({
    required this.id,
    required this.tableNumber,
    required this.total,
    required this.items,
    required this.date,
    required this.status,
  });
}

enum OrderStatus { pending, completed, cancelled }

class Achievement {
  final String title;
  final String description;
  final DateTime? date;
  final IconData icon;
  final bool isUnlocked;

  Achievement({
    required this.title,
    required this.description,
    required this.date,
    required this.icon,
    required this.isUnlocked,
  });
}
