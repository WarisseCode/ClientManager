import 'package:flutter/material.dart';
import '../providers/restaurant_provider.dart';
import '../models/restaurant.dart';

/// Exemple d'utilisation du RestaurantProvider
/// Ce fichier montre comment utiliser le provider dans différentes pages
class RestaurantUsageExample extends StatelessWidget {
  const RestaurantUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemple d\'utilisation'),
      ),
      body: Column(
        children: [
          // Exemple 1: Afficher le restaurant sélectionné
          const RestaurantInfoCard(),
          
          const SizedBox(height: 20),
          
          // Exemple 2: Bouton pour sélectionner un restaurant
          ElevatedButton(
            onPressed: () {
              // Simuler la sélection d'un restaurant
              final provider = RestaurantProvider();
              final mockRestaurant = Restaurant(
                id: '1',
                name: 'Restaurant Exemple',
                address: '123 Rue Exemple',
                imageUrl: 'https://example.com/image.jpg',
                isOpen: true,
                // Suppression de activeServers
              );
              provider.selectRestaurant(mockRestaurant);
            },
            child: const Text('Sélectionner un restaurant'),
          ),
          
          const SizedBox(height: 20),
          
          // Exemple 3: Bouton pour effacer la sélection
          ElevatedButton(
            onPressed: () {
              final provider = RestaurantProvider();
              provider.clearSelection();
            },
            child: const Text('Effacer la sélection'),
          ),
        ],
      ),
    );
  }
}

/// Widget qui affiche les informations du restaurant sélectionné
class RestaurantInfoCard extends StatelessWidget {
  const RestaurantInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = RestaurantProvider();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Restaurant sélectionné:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (provider.hasSelectedRestaurant) ...[
              Text('Nom: ${provider.selectedRestaurantName}'),
              Text('ID: ${provider.selectedRestaurantId}'),
              Text('Adresse: ${provider.selectedRestaurant?.address}'),
              Text('Statut: ${provider.selectedRestaurant?.isOpen == true ? "Ouvert" : "Fermé"}'),
              // Suppression de l'affichage de activeServers
            ] else ...[
              const Text(
                'Aucun restaurant sélectionné',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Exemple d'utilisation dans une page avec StatefulWidget
class RestaurantPageExample extends StatefulWidget {
  const RestaurantPageExample({super.key});

  @override
  State<RestaurantPageExample> createState() => _RestaurantPageExampleState();
}

class _RestaurantPageExampleState extends State<RestaurantPageExample> {
  final RestaurantProvider _restaurantProvider = RestaurantProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page avec Restaurant Provider'),
      ),
      body: Column(
        children: [
          // Afficher le restaurant sélectionné
          if (_restaurantProvider.hasSelectedRestaurant)
            Card(
              child: ListTile(
                leading: const Icon(Icons.restaurant),
                title: Text(_restaurantProvider.selectedRestaurantName ?? ''),
                subtitle: Text(_restaurantProvider.selectedRestaurant?.address ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _restaurantProvider.clearSelection();
                    });
                  },
                ),
              ),
            ),
          
          // Bouton pour naviguer vers la sélection
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/restaurant-selection');
            },
            child: const Text('Sélectionner un restaurant'),
          ),
        ],
      ),
    );
  }
}