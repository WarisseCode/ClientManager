# Intégration API Restaurants - ClientManager

## 🎯 Objectif
Remplacer les données simulées par des données réelles provenant de l'API REST située à `https://clientmanagerapi.onrender.com`.

## 📁 Structure des fichiers créés

### 1. Modèle de données
- **`lib/models/restaurant.dart`** : Classe modèle Restaurant avec sérialisation JSON

### 2. Service API
- **`lib/services/restaurant_service.dart`** : Service pour consommer l'API REST

### 3. Gestion d'état
- **`lib/providers/restaurant_provider.dart`** : Provider pour gérer la sélection de restaurant

### 4. Widgets
- **`lib/widgets/restaurant_card.dart`** : Widget réutilisable pour afficher un restaurant

### 5. Page mise à jour
- **`lib/features/restaurant/restaurant_selection_page.dart`** : Page de sélection avec données réelles

### 6. Exemples
- **`lib/examples/restaurant_usage_example.dart`** : Exemples d'utilisation du provider

## 🔧 Fonctionnalités implémentées

### ✅ Données réelles depuis l'API
- Appel à l'API uniquement après connexion réussie
- Gestion de plusieurs endpoints possibles (`/restaurants`, `/restaurant`, `/api/restaurants`)
- Fallback vers données de démonstration en cas d'erreur

### ✅ Gestion des états
- **Loader** : `CircularProgressIndicator` pendant le chargement
- **Erreur** : Message d'erreur avec bouton "Réessayer"
- **Vide** : Message quand aucun restaurant n'est disponible

### ✅ Sélection de restaurant
- Interface de sélection avec indicateur visuel
- Stockage du restaurant sélectionné via `RestaurantProvider`
- Navigation vers la page d'accueil après sélection

### ✅ Widget RestaurantCard
- Affichage des informations du restaurant
- Indicateur de statut (ouvert/fermé)
- ~~Nombre de serveurs actifs~~
- Gestion des erreurs d'image

## 🚀 Utilisation

### 1. Accès au restaurant sélectionné
```dart
final provider = RestaurantProvider();

// Vérifier si un restaurant est sélectionné
if (provider.hasSelectedRestaurant) {
  final restaurant = provider.selectedRestaurant;
  print('Restaurant: ${restaurant?.name}');
}
```

### 2. Sélectionner un restaurant
```dart
final provider = RestaurantProvider();
provider.selectRestaurant(restaurant);
```

### 3. Effacer la sélection
```dart
final provider = RestaurantProvider();
provider.clearSelection();
```

## 🔌 Configuration API

### Endpoint utilisé
`https://clientmanagerapi.onrender.com/servers/serveur@rest/restaurants`

### Structure JSON attendue
```json
{
  "restaurants": [
    {
      "id": "1",
      "name": "Nom du restaurant",
      "address": "Adresse du restaurant",
      "imageUrl": "URL de l'image",
      "isOpen": true
    }
  ]
}
```

### Champs supportés (flexibles)
- `id` ou `_id`
- `name` ou `nom`
- `address` ou `adresse`
- `imageUrl` ou `image` ou `image_url`
- `isOpen` ou `is_open` ou `open`
- ~~`activeServers` ou `active_servers` ou `servers`~~

## 🛠️ Personnalisation

### Modifier l'URL de l'API
Éditez `lib/services/restaurant_service.dart` :
```dart
static const String _baseUrl = 'https://votre-api.com';
```

### Ajouter de nouveaux champs
1. Modifiez `lib/models/restaurant.dart`
2. Ajoutez le champ dans `fromJson()` et `toJson()`
3. Mettez à jour `lib/widgets/restaurant_card.dart` si nécessaire

### Changer le style des cartes
Modifiez `lib/widgets/restaurant_card.dart` pour personnaliser l'apparence.

## 🔍 Débogage

### Logs de l'API
Les erreurs sont affichées dans la console :
```
Erreur lors de la récupération des restaurants: [détails]
```

### Mode démonstration
Si l'API n'est pas accessible, l'application utilise automatiquement des données de démonstration.

## 📱 Navigation

### Routes disponibles
- `/restaurant-selection` : Page de sélection des restaurants
- `/home` : Page d'accueil (après sélection)

### Flux utilisateur
1. Connexion utilisateur
2. Navigation vers sélection restaurant
3. Chargement des restaurants depuis l'API
4. Sélection d'un restaurant
5. Stockage dans le provider
6. Navigation vers la page d'accueil

## 🎨 Interface utilisateur

### États de l'interface
- **Chargement** : Spinner avec message "Chargement des restaurants..."
- **Erreur** : Icône d'erreur avec message et bouton "Réessayer"
- **Vide** : Message "Aucun restaurant disponible"
- **Succès** : Liste des restaurants avec cartes interactives

### Thème
Utilise le thème existant avec `AppColors.bgDark`, `AppColors.bgSecondary`, et `AppColors.orange`.

## 🔄 Prochaines étapes

1. **Tester l'API** : Vérifier que l'endpoint fonctionne correctement
2. **Ajuster les champs** : Modifier le modèle selon la structure réelle de l'API
3. **Ajouter la persistance** : Sauvegarder la sélection localement
4. **Améliorer l'UX** : Ajouter des animations et transitions
5. **Tests** : Ajouter des tests unitaires pour le service et le provider