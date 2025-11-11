# Client Manager

Application de gestion de restaurants pour serveurs.

## Fonctionnalités

- Authentification des serveurs
- Sélection de restaurant
- Gestion des tables et commandes
- Notifications en temps réel
- Thème clair/sombre
- Support multi-langues

## Configuration requise

- Flutter 3.7+
- Dart 2.19+
- Android SDK ou iOS SDK
- Compte Firebase

## Installation

1. Cloner le repository
2. Exécuter `flutter pub get`
3. Configurer Firebase (ajouter google-services.json pour Android et GoogleService-Info.plist pour iOS)
4. Exécuter `flutter run`

## Fonctionnalités de notification

L'application utilise Firebase Cloud Messaging (FCM) pour envoyer des notifications aux serveurs lorsqu'une table leur est attribuée.

### Configuration

1. Le device est automatiquement enregistré auprès du backend lors de la connexion
2. Les notifications sont affichées même lorsque l'application est en arrière-plan
3. Les notifications peuvent être consultées dans l'onglet Notifications de l'application

### Types de notifications

- Attribution de table
- Mise à jour de commande
- Annulation de commande

## Structure du projet

- `lib/core/` - Thèmes et utilitaires
- `lib/features/` - Fonctionnalités principales
- `lib/models/` - Modèles de données
- `lib/providers/` - Gestion d'état avec Provider
- `lib/services/` - Services API et utilitaires

## Dépendances principales

- firebase_core
- firebase_messaging
- firebase_auth
- provider
- http
- shared_preferences
- flutter_local_notifications