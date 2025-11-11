import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/theme_utils.dart';
import '../../models/restaurant.dart';
import '../../services/restaurant_service.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/restaurant_card.dart';
import '../home/home_page.dart';
import '../auth/login_page.dart';

class RestaurantSelectionPage extends StatefulWidget {
  const RestaurantSelectionPage({super.key});

  @override
  State<RestaurantSelectionPage> createState() => _RestaurantSelectionPageState();
}

class _RestaurantSelectionPageState extends State<RestaurantSelectionPage> {
  final RestaurantService _restaurantService = RestaurantService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _selectedRestaurantId;
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recharger les restaurants chaque fois que les dépendances changent
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String? email = _auth.currentUser?.email;
      if (email == null || email.isEmpty) {
        throw Exception('Email utilisateur introuvable. Veuillez vous reconnecter.');
      }
      final restaurants = await _restaurantService.fetchRestaurants(email: email);
      
      if (!mounted) return;
      setState(() {
        _restaurants = restaurants;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur lors du chargement des restaurants: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectRestaurant(BuildContext context) async {
    if (_selectedRestaurantId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner un restaurant', 
              style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context))),
          backgroundColor: Colors.red[600],
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    // Trouver le restaurant sélectionné
    final selectedRestaurant = _restaurants.firstWhere(
      (restaurant) => restaurant.id == _selectedRestaurantId,
    );

    // Utilisation du Provider existant au lieu de créer une nouvelle instance
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    restaurantProvider.selectRestaurant(selectedRestaurant);

    // Simuler la connexion au restaurant
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Naviguer vers la page d'accueil
    if (mounted) {
      // Utiliser Navigator.pop au lieu de Navigator.pushReplacementNamed pour retourner à la page d'accueil existante
      Navigator.pop(context);
    }
  }

  Widget _buildMainContent(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement des restaurants...',
              style: TextStyle(
                color: ThemeUtils.getPrimaryTextColor(context),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                _error!,
                style: TextStyle(
                  color: ThemeUtils.getSecondaryTextColor(context),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadRestaurants,
                icon: Icon(Icons.refresh, color: ThemeUtils.getPrimaryTextColor(context)),
                label: Text('Réessayer', 
                    style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              color: ThemeUtils.getIconColor(context),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun restaurant disponible',
              style: TextStyle(
                color: ThemeUtils.getPrimaryTextColor(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Veuillez réessayer plus tard',
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = _restaurants[index];
        final isSelected = _selectedRestaurantId == restaurant.id;

        return RestaurantCard(
          restaurant: restaurant,
          isSelected: isSelected,
          onTap: restaurant.isOpen
              ? () {
                  setState(() {
                    _selectedRestaurantId = restaurant.id;
                  });
                }
              : null,
        );
      },
    );
  }

  /// Gère le comportement du bouton retour
  Future<void> _handleBackButton(BuildContext context) async {
    // Vérifier si la page d'accueil existe déjà dans la pile de navigation
    if (Navigator.canPop(context)) {
      // Si oui, simplement revenir en arrière
      Navigator.pop(context);
    } else {
      // Si non (cas de la première connexion), aller directement à la page d'accueil
      final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
      if (restaurantProvider.hasSelectedRestaurant) {
        // Si un restaurant est déjà sélectionné, aller à la page d'accueil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        // Sinon, aller à la page de connexion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
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
          child: WillPopScope(
            // Désactiver le bouton retour selon le contexte
            onWillPop: () async {
              // Vérifier si on peut revenir en arrière (c'est-à-dire si on vient de la page d'accueil)
              return Navigator.canPop(context);
            },
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Le bouton retour est conditionnellement désactivé
                          IconButton(
                            onPressed: Navigator.canPop(context) 
                                ? () => Navigator.pop(context) 
                                : null,
                            icon: Icon(Icons.arrow_back, 
                                color: Navigator.canPop(context) 
                                    ? ThemeUtils.getPrimaryTextColor(context) 
                                    : Colors.transparent),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sélectionner un restaurant',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: ThemeUtils.getPrimaryTextColor(context),
                              ),
                            ),
                          ),
                          // Bouton d'actualisation
                          IconButton(
                            onPressed: _loadRestaurants,
                            icon: Icon(Icons.refresh, 
                                color: ThemeUtils.getPrimaryTextColor(context)),
                            tooltip: 'Actualiser la liste des restaurants',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Choisissez le restaurant où vous souhaitez travailler aujourd\'hui',
                        style: TextStyle(
                          fontSize: 16,
                          color: ThemeUtils.getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenu principal
                Expanded(
                  child: _buildMainContent(context),
                ),

                // Bouton de confirmation
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _selectRestaurant(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Commencer le service',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ThemeUtils.getPrimaryTextColor(context),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}