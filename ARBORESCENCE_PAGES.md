# Arborescence des Pages - Client Manager

## Vue d'ensemble
Cette application Flutter de gestion de restaurant comporte **9 pages principales** avec une navigation basée sur l'authentification et la sélection de restaurant.

---

## 📊 Diagramme de Navigation

```
┌────────────────────────────────────────────────────────────────┐
│                     FLUX D'AUTHENTIFICATION                      │
└────────────────────────────────────────────────────────────────┘

                         ┌─────────────┐
                         │ LoginPage   │ (Page d'accueil)
                         │ /login      │
                         └─────┬───────┘
                               │
                ┌──────────────┼──────────────┐
                │              │              │
                ▼              ▼              ▼
        [Se connecter]  [Google SignIn]  [Créer compte]
                │              │              │
                │              │              │
                └──────────────┴──────────────┘
                               │
                               ▼
                    ┌────────────────────┐
                    │  RegisterPage      │
                    │  /register         │
                    └──────────┬─────────┘
                               │
                               ▼
┌────────────────────────────────────────────────────────────────┐
│                   SÉLECTION DE RESTAURANT                      │    
└────────────────────────────────────────────────────────────────┘

                    ┌─────────────────────────┐
                    │ RestaurantSelectionPage │
                    │ /restaurant-selection   │
                    └───────────┬─────────────┘
                                │
                                ▼ (Sélection effectuée)
┌────────────────────────────────────────────────────────────────┐
│                      PAGES PRINCIPALES                         │
└────────────────────────────────────────────────────────────────┘

                    ┌─────────────────────┐
                    │   TablesPage        │ (Page par défaut après login)
                    │   /tables           │
                    └──────────┬──────────┘
                               │
                [Retour → HomePage]
                               │
                               ▼
                    ┌─────────────────────┐
                    │    HomePage         │
                    │    /home            │
                    └──────────┬──────────┘
                               │
        ┌──────────────────────┼────────────────────┐
        │                      │                    │
        ▼                      ▼                    ▼
┌──────────────┐    ┌──────────────────┐    ┌──────────────┐
│NotificationsP│    │   SettingsPage   │    │  HelpPage    │
│/notifications│    │   (via Profil)   │    │  /help       │
└──────────────┘    └────────┬─────────┘    └──────────────┘
                             │
                    ┌────────┴─────────┐
                    │                  │
                    ▼                  ▼
           ┌──────────────┐   ┌──────────────┐
           │ HistoryPage  │   │   HelpPage   │
           │ (via Profil) │   │   (via Profil)│
           └──────────────┘   └──────────────┘
```

---

## 📄 Description Détaillée des Pages et Liens

### 🔐 **1. LoginPage** (`/login`)
**Fichier:** `lib/features/auth/login_page.dart`

**Navigation sortante:**
- ➡️ **RegisterPage** (`/register`) - Bouton "Créer un compte"
- ➡️ **RestaurantSelectionPage** (`/restaurant-selection`) - Après connexion réussie
- ➡️ **RestaurantSelectionPage** (`/restaurant-selection`) - Après connexion Google

**État:** Page d'entrée de l'application (non authentifié)

---

### 📝 **2. RegisterPage** (`/register`)
**Fichier:** `lib/features/auth/register_page.dart`

**Navigation entrante:**
- ⬅️ **LoginPage** - Bouton "Créer un compte"

**Navigation sortante:**
- ➡️ **RestaurantSelectionPage** (`/restaurant-selection`) - Après inscription réussie
- ➡️ **RestaurantSelectionPage** (`/restaurant-selection`) - Après connexion Google

---

### 🍴 **3. RestaurantSelectionPage** (`/restaurant-selection`)
**Fichier:** `lib/features/restaurant/restaurant_selection_page.dart`

**Navigation entrante:**
- ⬅️ **LoginPage** - Après connexion
- ⬅️ **RegisterPage** - Après inscription
- ⬅️ **HomePage** - Bouton pour changer de restaurant

**Navigation sortante:**
- ➡️ **HomePage** (`/home`) - Après sélection d'un restaurant (pushNamedAndRemoveUntil)

**État:** Page intermédiaire obligatoire après authentification

---

### 🏠 **4. HomePage** (`/home`)
**Fichier:** `lib/features/home/home_page.dart`

**Navigation entrante:**
- ⬅️ **RestaurantSelectionPage** - Après sélection du restaurant

**Navigation sortante:**
- ➡️ **RestaurantSelectionPage** - Changer de restaurant (pushReplacement avec MaterialPageRoute)
- ➡️ **NotificationsPage** - Bouton notification dans l'AppBar (push avec MaterialPageRoute)
- ➡️ **TablesPage** - Bouton "Tables" dans le dashboard (push avec MaterialPageRoute)
- ➡️ **SettingsPage** - Via MaterialPageRoute depuis le profil
- ➡️ **HistoryPage** - Via MaterialPageRoute depuis le profil
- ➡️ **HelpPage** - Via MaterialPageRoute depuis le profil
- ➡️ **LoginPage** - Après déconnexion (pushReplacement avec MaterialPageRoute)

**Composants internes:**
- **DashboardTab** - Vue principale avec statistiques
- **OrdersTab** - Gestion des commandes
- **ProfileTab** - Profil utilisateur avec options

---

### 🍽️ **5. TablesPage** (`/tables`)
**Fichier:** `lib/features/tables/tables_page.dart`

**Navigation entrante:**
- ⬅️ **HomePage** - Bouton "Tables"
- ⬅️ **main.dart** - Page par défaut après authentification complète

**Navigation sortante:**
- ➡️ **HomePage** - Bouton retour (pushReplacement avec MaterialPageRoute)

**État:** Page dédiée à la visualisation des tables du restaurant

---

### 🔔 **6. NotificationsPage** (`/notifications`)
**Fichier:** `lib/features/notifications/notifications_page.dart`

**Navigation entrante:**
- ⬅️ **HomePage** - Bouton notification dans l'AppBar

**Navigation sortante:**
- ➡️ **Retour** - Navigator.pop() vers HomePage

**Fonctionnalités:**
- Affichage des notifications push
- Marquer comme lu
- Badge de compteur de notifications non lues

---

### ⚙️ **7. SettingsPage** (Paramètres)
**Fichier:** `lib/features/profile/settings_page.dart`

**Navigation entrante:**
- ⬅️ **HomePage** - Via ProfileTab > Bouton "Paramètres" (MaterialPageRoute)

**Navigation sortante:**
- ➡️ **HelpPage** (`/help`) - Bouton "Centre d'aide"
- ➡️ **LoginPage** (`/login`) - Après suppression du compte (pushReplacement)
- ➡️ **Retour** - Navigator.pop() vers HomePage

**Fonctionnalités:**
- Gestion du profil utilisateur
- Paramètres de notification
- Thème (clair/sombre)
- Langue
- Suppression de compte

---

### 📚 **8. HistoryPage** (Historique)
**Fichier:** `lib/features/profile/history_page.dart`

**Navigation entrante:**
- ⬅️ **HomePage** - Via ProfileTab > Bouton "Historique" (MaterialPageRoute)

**Navigation sortante:**
- ➡️ **Retour** - Navigator.pop() vers HomePage

**Fonctionnalités:**
- Historique des actions/commandes

---

### ❓ **9. HelpPage** (Aide)
**Fichier:** `lib/features/profile/help_page.dart`

**Navigation entrante:**
- ⬅️ **HomePage** - Via ProfileTab > Bouton "Aide" (MaterialPageRoute)
- ⬅️ **SettingsPage** - Bouton "Centre d'aide"

**Navigation sortante:**
- ➡️ **Retour** - Navigator.pop() vers la page précédente

**Fonctionnalités:**
- FAQ
- Support utilisateur

---

## 🔄 Types de Navigation Utilisés

### Navigation avec Routes Nommées
- `Navigator.pushNamed(context, '/route')` - Navigation simple
- `Navigator.pushReplacementNamed(context, '/route')` - Remplace la page actuelle
- `Navigator.pushNamedAndRemoveUntil(context, '/route', (route) => false)` - Efface tout l'historique

### Navigation avec MaterialPageRoute
- `Navigator.push(context, MaterialPageRoute(builder: (context) => Page()))` - Navigation directe
- `Navigator.pop(context)` - Retour à la page précédente

---

## 🔐 Flux d'Authentification

```
1. App Start
   └─> LoginPage (si non authentifié)
       └─> RestaurantSelectionPage (si authentifié sans restaurant)
           └─> TablesPage (si authentifié avec restaurant)
```

---

## ⚠️ Note sur les Routes

L'application utilise principalement des **routes nommées non définies** (references à `/login`, `/register`, etc.) mais la navigation réelle se fait via `StreamBuilder` dans `main.dart` qui gère automatiquement les redirections basées sur:
- État d'authentification (FirebaseAuth)
- Restaurant sélectionné (RestaurantProvider)

---

## 📊 Statistiques

- **Total Pages:** 9
- **Pages d'authentification:** 2 (Login, Register)
- **Pages principales:** 4 (RestaurantSelection, Home, Tables, Notifications)
- **Pages de profil:** 3 (Settings, History, Help)
- **Providers utilisés:** 4 (RestaurantProvider, TableProvider, PreferencesProvider, NotificationProvider)

---

## 🎯 Page par Défaut

Après authentification complète et sélection de restaurant:
➡️ **TablesPage** (définie dans `main.dart` ligne 192)
