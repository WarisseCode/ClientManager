import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Met à jour le nom d'affichage de l'utilisateur
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.reload();
      } else {
        throw Exception('Aucun utilisateur connecté');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    }
  }

  /// Met à jour l'adresse email de l'utilisateur
  Future<void> updateEmail(String newEmail, String password) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Ré-authentifier l'utilisateur avant de changer l'email
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        
        // Mettre à jour l'email avec la nouvelle méthode
        await user.verifyBeforeUpdateEmail(newEmail);
        await user.reload();
      } else {
        throw Exception('Aucun utilisateur connecté');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    }
  }

  /// Met à jour le mot de passe de l'utilisateur
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Ré-authentifier l'utilisateur avant de changer le mot de passe
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        
        // Mettre à jour le mot de passe
        await user.updatePassword(newPassword);
      } else {
        throw Exception('Aucun utilisateur connecté');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    }
  }

  /// Supprime le compte de l'utilisateur
  Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Ré-authentifier l'utilisateur avant de supprimer le compte
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        
        // Supprimer le compte
        await user.delete();
      } else {
        throw Exception('Aucun utilisateur connecté');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    }
  }

  /// Gestion des erreurs Firebase
  String _handleFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'L\'adresse email n\'est pas valide.';
      case 'email-already-in-use':
        return 'Cette adresse email est déjà utilisée.';
      case 'wrong-password':
        return 'Le mot de passe actuel est incorrect.';
      case 'weak-password':
        return 'Le nouveau mot de passe est trop faible.';
      case 'requires-recent-login':
        return 'Veuillez vous reconnecter avant d\'effectuer cette action.';
      case 'user-not-found':
        return 'Utilisateur non trouvé.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez réessayer plus tard.';
      case 'operation-not-allowed':
        return 'Cette opération n\'est pas autorisée.';
      case 'network-request-failed':
        return 'Erreur de réseau. Vérifiez votre connexion.';
      default:
        return 'Erreur: ${e.message}';
    }
  }
}