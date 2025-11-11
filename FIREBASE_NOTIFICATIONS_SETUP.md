# Configuration des Notifications Firebase

## Configuration requise

- Compte Firebase avec projet créé
- Application Android/iOS enregistrée dans Firebase Console
- Fichiers de configuration (`google-services.json` pour Android, `GoogleService-Info.plist` pour iOS)

## Étapes de configuration

### 1. Configuration Android

1. **Ajouter le fichier de configuration**
   - Copier `google-services.json` dans `android/app/`

2. **Mettre à jour `android/build.gradle`**
   ```gradle
   buildscript {
       dependencies {
           classpath 'com.google.gms:google-services:4.3.15'
       }
   }
   ```

3. **Mettre à jour `android/app/build.gradle`**
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   
   dependencies {
       implementation 'com.google.firebase:firebase-messaging:23.1.2'
   }
   ```

4. **Configurer les permissions dans `AndroidManifest.xml`**
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.WAKE_LOCK" />
   ```

### 2. Configuration iOS

1. **Ajouter le fichier de configuration**
   - Copier `GoogleService-Info.plist` dans `ios/Runner/`

2. **Configurer les capacités**
   - Activer "Push Notifications" dans Xcode
   - Activer "Background Modes" > "Remote notifications"

3. **Mettre à jour `ios/Podfile`**
   ```ruby
   platform :ios, '10.0'
   ```

### 3. Configuration Flutter

1. **Dépendances requises**
   ```yaml
   dependencies:
     firebase_core: ^4.1.1
     firebase_messaging: ^16.0.2
     flutter_local_notifications: ^19.4.2
   ```

2. **Initialisation dans `main.dart`**
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     runApp(MyApp());
   }
   ```

## Gestion des tokens FCM

### Enregistrement du device
```dart
final fcmToken = await FirebaseMessaging.instance.getToken();
await deviceService.registerDevice(
  email: userEmail,
  fcmToken: fcmToken,
  platform: platform,
);
```

### Mise à jour du token
```dart
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
  await deviceService.updateDeviceToken(
    email: userEmail,
    oldToken: oldToken,
    newToken: newToken,
  );
});
```

## Types de notifications

### 1. Notifications de table
```json
{
  "to": "FCM_TOKEN",
  "notification": {
    "title": "Nouvelle table attribuée",
    "body": "La table 12 vous a été attribuée"
  },
  "data": {
    "type": "table_assignment",
    "tableNumber": "12",
    "restaurantId": "abc123"
  }
}
```

### 2. Notifications de commande
```json
{
  "to": "FCM_TOKEN",
  "notification": {
    "title": "Commande prête",
    "body": "La commande pour la table 5 est prête"
  },
  "data": {
    "type": "order_ready",
    "tableNumber": "5",
    "orderId": "xyz789"
  }
}
```

## Gestion des permissions

### Demander les permissions
```dart
NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);
```

### Vérifier l'état des permissions
```dart
if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  // Permissions accordées
}
```

## Tests

### Test de notification via API REST
```bash
POST https://fcm.googleapis.com/fcm/send
Content-Type: application/json
Authorization: key=SERVER_KEY

{
  "to": "DEVICE_FCM_TOKEN",
  "notification": {
    "title": "Test",
    "body": "Notification de test"
  }
}
```

### Test avec Firebase Console
1. Accéder à Firebase Console
2. Sélectionner le projet
3. Aller dans "Cloud Messaging"
4. Créer un nouveau message
5. Saisir le titre et le corps
6. Sélectionner l'application
7. Envoyer le message

## Débogage

### Logs utiles
```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Message reçu: ${message.notification?.title}');
});

FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  print('App ouverte via notification: ${message.notification?.title}');
});
```

### Vérification du token
```dart
String? token = await FirebaseMessaging.instance.getToken();
print('FCM Token: $token');
```

## Bonnes pratiques

1. **Enregistrement du device**
   - Enregistrer le device dès la connexion de l'utilisateur
   - Mettre à jour le token lors des changements
   - Désenregistrer le device lors de la déconnexion

2. **Gestion des erreurs**
   - Toujours vérifier les tokens avant envoi
   - Gérer les cas où les permissions sont refusées
   - Mettre en place des logs pour le débogage

3. **Sécurité**
   - Ne pas exposer les tokens FCM côté client
   - Utiliser l'authentification pour les endpoints d'enregistrement
   - Mettre en place des vérifications côté serveur

4. **Performance**
   - Utiliser des channels de notification pour Android
   - Optimiser les icônes de notification
   - Mettre en cache les tokens pour éviter les appels répétés