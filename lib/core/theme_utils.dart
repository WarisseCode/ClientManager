import 'package:flutter/material.dart';

class ThemeUtils {
  /// Obtient la couleur de fond principale selon le thème
  static Color getBackgroundColor(BuildContext context) {
    try {
      return Theme.of(context).colorScheme.background;
    } catch (e) {
      // Valeur par défaut en cas d'erreur
      return const Color(0xFF18181B); // bgDark
    }
  }

  /// Obtient la couleur secondaire selon le thème
  static Color getSecondaryColor(BuildContext context) {
    try {
      return Theme.of(context).brightness == Brightness.dark 
        ? const Color(0xFF27272A) // bgSecondary pour le thème sombre
        : Colors.grey[300]!; // Couleur équivalente pour le thème clair
    } catch (e) {
      // Valeur par défaut en cas d'erreur
      return const Color(0xFF27272A); // bgSecondary
    }
  }

  /// Obtient la couleur du texte principal selon le thème
  static Color getPrimaryTextColor(BuildContext context) {
    try {
      return Theme.of(context).brightness == Brightness.dark 
        ? Colors.white 
        : Colors.black;
    } catch (e) {
      // Valeur par défaut en cas d'erreur
      return Colors.white;
    }
  }

  /// Obtient la couleur du texte secondaire selon le thème
  static Color getSecondaryTextColor(BuildContext context) {
    try {
      return Theme.of(context).brightness == Brightness.dark 
        ? Colors.grey[400]!
        : Colors.grey[600]!;
    } catch (e) {
      // Valeur par défaut en cas d'erreur
      return Colors.grey[400]!;
    }
  }

  /// Obtient la couleur de la bordure selon le thème
  static Color getBorderColor(BuildContext context) {
    try {
      return Theme.of(context).brightness == Brightness.dark 
        ? Colors.grey[700]!
        : Colors.grey[400]!;
    } catch (e) {
      // Valeur par défaut en cas d'erreur
      return Colors.grey[700]!;
    }
  }

  /// Obtient la couleur d'icône selon le thème
  static Color getIconColor(BuildContext context) {
    try {
      return Theme.of(context).brightness == Brightness.dark 
        ? Colors.grey[400]!
        : Colors.grey[600]!;
    } catch (e) {
      // Valeur par défaut en cas d'erreur
      return Colors.grey[400]!;
    }
  }
}