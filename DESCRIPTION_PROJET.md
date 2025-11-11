# Client Manager - Documentation Complète du Projet

## 📋 Vue d'Ensemble

**Client Manager** est une application mobile Flutter pour la gestion des services en restaurant. Elle permet aux serveurs de :

- ✅ S'authentifier (Email/Password ou Google)
- ✅ Sélectionner leur restaurant de travail
- ✅ Visualiser leurs tables assignées en temps réel
- ✅ Recevoir des notifications push (FCM)
- ✅ Gérer leur profil et préférences (thème clair/sombre)

### 🎯 Objectif

Faciliter le travail des serveurs en leur donnant un accès mobile instantané aux commandes de leurs tables.

---

## 🏗️ Architecture

### Stack Technique

```
┌─────────────────────────────────┐
│     UI Layer (Flutter)          │
│  • Pages & Widgets              │
├─────────────────────────────────┤
│   State Management (Provider)   │
│  • RestaurantProvider           │
│  • TableProvider                │
│  • NotificationProvider         │
│  • PreferencesProvider          │
├─────────────────────────────────┤
│      Services Layer             │
│  • AuthService (Firebase)       │
│  • RestaurantService (HTTP)     │
│  • TableService (HTTP)          │
│  • NotificationService (FCM)    │
│  • DeviceService                │
│  • PreferencesService           │
└─────────────────────────────────┘
         ↕️              ↕️
   Firebase      Backend API
```

### Technologies Principales

- **Flutter** 3.4+ / **Dart** 3.4+
- **Firebase** (Auth + Cloud Messaging)
- **Provider** (State Management)
- **HTTP** (API Calls)
- **SharedPreferences** (Local Storage)

---

## 📁 Structure du Projet

```
lib/
├── core/                  # Configuration centrale
│   ├── theme.dart         # Couleurs
│   └── theme_utils.dart   # Helpers thème
│
├── features/              # Fonctionnalités
│   ├── auth/              # Authentification
│   │   ├── auth_service.dart
│   │   ├── login_page.dart
│   │   └── register_page.dart
│   ├── restaurant/
│   │   └── restaurant_selection_page.dart
│   ├── home/
│   │   └── home_page.dart
│   ├── tables/
│   │   └── tables_page.dart
│   ├── notifications/
│   │   └── notifications_page.dart
│   └── profile/
│       ├── settings_page.dart
│       ├── history_page.dart
│       └── help_page.dart
│
├── models/                # Modèles
│   ├── restaurant.dart
│   └── table.dart
│
├── providers/             # État global
│   ├── restaurant_provider.dart
│   ├── table_provider.dart
│   ├── notification_provider.dart
│   └── preferences_provider.dart
│
├── services/              # Logique métier
│   ├── restaurant_service.dart
│   ├── table_service.dart
│   ├── notification_service.dart
│   ├── device_service.dart
│   ├── user_service.dart
│   └── preferences_service.dart
│
└── main.dart              # Point d'entrée
```

---

## 📦 Modèles de Données

### Restaurant
```dart
class Restaurant {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final bool isOpen;
}
```

### Table
```dart
class Table {
  final String id;
  final String tableNumber;
  final String status;          // "En cours", "Prête", "Servie"
  final List<OrderItem> orderItems;
  final double totalAmount;
  final String serverId;
  final String restaurantId;
}
```

### OrderItem
```dart
class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
}
```

---

## 🔧 Services Principaux

### 1. AuthService
**Authentification Firebase**
- Email/Password
- Google Sign-In
- Gestion de session

### 2. RestaurantService
**API des restaurants**
- `GET /servers/:email/restaurants`
- Récupération liste + restaurant par ID

### 3. TableService
**API des tables**
- `GET /servers/:email/:restaurantId/orders?date=YYYY-MM-DD`
- Récupération des commandes par serveur

### 4. NotificationService
**Firebase Cloud Messaging**
- Configuration FCM
- Notifications locales
- Permissions

### 5. DeviceService
**Enregistrement device**
- `POST /devices` avec email, fcmToken, platform
- Gestion refresh token

### 6. PreferencesService
**Stockage local**
- Thème (clair/sombre/système)
- Préférences utilisateur

---

## 📡 Providers (État Global)

### RestaurantProvider
```dart
- selectRestaurant(Restaurant)
- clearRestaurant()
- selectedRestaurant  // Getter
```

### TableProvider
```dart
- loadTables(restaurantId, serverEmail)
- clearTables()
- tables / isLoading / hasError
```

### NotificationProvider
```dart
- handleIncomingMessage(RemoteMessage)
- markNotificationAsRead()
- markAllNotificationsAsRead()
- unreadNotificationsCount
```

### PreferencesProvider
```dart
- setThemeMode(ThemeMode)
- currentThemeMode
```

---

## 🗺️ Navigation

### Flux Principal

```
LoginPage → RestaurantSelectionPage → TablesPage (défaut)
                                           ↓
                                        HomePage
                                           ├→ TablesPage
                                           ├→ NotificationsPage
                                           ├→ SettingsPage → HelpPage
                                           ├→ HistoryPage
                                           └→ Déconnexion → LoginPage
```

### Type de Navigation
- **MaterialPageRoute** (navigation directe)
- `Navigator.push()` / `pushReplacement()` / `pop()`
- ❌ Pas de routes nommées

---

## 🌐 API Backend

**Base URL:** `https://clientmanagerapi.onrender.com`

### Endpoints

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/servers/:email/restaurants` | Liste restaurants |
| GET | `/servers/:email/restaurants/:id` | Restaurant spécifique |
| GET | `/servers/:email/:restaurantId/orders` | Commandes du serveur |
| POST | `/devices` | Enregistrement device FCM |
| DELETE | `/users/:email` | Suppression compte |

---

## 🔔 Notifications Push (FCM)

### Configuration

1. **Initialisation** (main.dart)
```dart
await NotificationService().init();
await NotificationService().configureFirebaseMessaging();
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
```

2. **Enregistrement Device**
```dart
await deviceService.registerDevice(email, fcmToken, platform);
```

3. **Réception**
- **Foreground:** `FirebaseMessaging.onMessage.listen()`
- **Background:** `_firebaseMessagingBackgroundHandler()`
- **App fermée → ouverte:** `onMessageOpenedApp.listen()`

### Format Message
```json
{
  "notification": {
    "title": "Nouvelle table",
    "body": "Table 12 assignée"
  },
  "data": {
    "type": "table_assignment",
    "tableId": "123"
  }
}
```

---

## 🎨 Design System

### Couleurs
```dart
AppColors.orange      // #FF6B35 (principal)
AppColors.bgDark      // #18181B (fond sombre)
AppColors.bgSecondary // #27272A (fond secondaire)
```

### Thèmes
- **Clair:** fond gris 200, texte noir
- **Sombre:** fond #18181B, texte blanc
- **Système:** adaptatif

### Composants
- **Border radius:** 12px
- **Padding standard:** 16-20px
- **Boutons:** 56px hauteur
- **Espacement:** 8/16/24px

---

## 🚀 Installation

### 1. Prérequis
- Flutter 3.7+
- Dart 2.19+
- Compte Firebase

### 2. Installation
```bash
git clone <repo>
cd clientmanager
flutter pub get
```

### 3. Configuration Firebase

**Android:**
1. Télécharger `google-services.json`
2. Placer dans `android/app/`

**iOS:**
1. Télécharger `GoogleService-Info.plist`
2. Placer dans `ios/Runner/`

### 4. Lancer l'App
```bash
flutter run
```

---

## 📊 Dépendances Principales

```yaml
# Firebase
firebase_core: ^4.1.1
firebase_auth: ^6.1.0
firebase_messaging: ^16.0.2
google_sign_in: ^6.2.1

# State & Network
provider: ^6.1.0
http: ^1.2.0

# Storage & UI
shared_preferences: ^2.3.2
flutter_local_notifications: ^19.4.2
```

---

## 📝 Pages & Fonctionnalités

### 1. LoginPage
- Connexion Email/Password
- Google Sign-In
- Lien vers RegisterPage

### 2. RegisterPage
- Création compte
- Validation formulaire
- Auto-redirection

### 3. RestaurantSelectionPage
- Liste restaurants attribués
- Statut ouvert/fermé
- Sélection et changement

### 4. HomePage (Dashboard)
- Statistiques (tables, commandes, revenus)
- Navigation rapide
- 3 tabs: Dashboard, Orders, Profile

### 5. TablesPage
- Liste des tables assignées
- Statuts: En cours, Prête, Servie, Annulée
- Détails commandes + totaux
- Refresh manuel

### 6. NotificationsPage
- Historique notifications
- Badge compteur non-lues
- Marquer comme lu

### 7. SettingsPage
- Profil utilisateur
- Thème clair/sombre
- Paramètres notifications
- Suppression compte
- Lien aide

### 8. HistoryPage
- Historique activités
- (À développer)

### 9. HelpPage
- FAQ
- Support
- Documentation

---

## 🔒 Sécurité

- ✅ Authentification Firebase
- ✅ HTTPS pour toutes les requêtes API
- ✅ Tokens FCM sécurisés
- ✅ Validation côté client + serveur
- ✅ Pas de données sensibles stockées localement

---

## 📈 Améliorations Futures

- [ ] Support multi-langues complet
- [ ] Mode hors-ligne avec cache
- [ ] Filtres avancés des tables
- [ ] Statistiques détaillées
- [ ] Chat avec cuisine
- [ ] Support tablette
- [ ] Tests unitaires + intégration
- [ ] CI/CD pipeline

---

## 📚 Documentation Associée

- **ARBORESCENCE_PAGES.md** - Navigation détaillée
- **README.md** - Guide de démarrage rapide
- **FIREBASE_*.md** - Configuration Firebase
- **test/test.rest** - Exemples d'appels API

---

## 👨‍💻 Support & Contact

Pour toute question sur le projet, consulter la documentation ou contacter l'équipe de développement.

**Version:** 1.0.0  
**Dernière mise à jour:** 2025
