import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/theme_utils.dart';
import '../auth/auth_service.dart';
// Import du provider de préférences
import '../../providers/preferences_provider.dart';
// Import du service utilisateur
import '../../services/user_service.dart';

/// Page des paramètres utilisateur
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  User? _currentUser;
  
  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                      icon: Icon(
                        Icons.arrow_back, 
                        color: ThemeUtils.getPrimaryTextColor(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Paramètres',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ThemeUtils.getPrimaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Contenu des paramètres (scrollable adaptatif pour éviter overflow)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        20 + MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Compte
                            _buildSectionTitle('Compte'),
                            _buildAccountSection(context),
                            const SizedBox(height: 24),

                            // Section Notifications
                            _buildSectionTitle('Notifications'),
                            _buildNotificationSection(context),
                            const SizedBox(height: 24),

                            // Section Préférences
                            _buildSectionTitle('Préférences'),
                            _buildPreferencesSection(context),
                            const SizedBox(height: 24),

                            // Section Confidentialité
                            _buildSectionTitle('Confidentialité'),
                            _buildPrivacySection(context),
                            const SizedBox(height: 24),

                            // Section À propos
                            _buildSectionTitle('À propos'),
                            _buildAboutSection(context),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.orange,
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeUtils.getSecondaryColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeUtils.getBorderColor(context), 
          width: 1
        ),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.person,
            title: 'Modifier le profil',
            subtitle: 'Nom, photo, informations personnelles',
            onTap: () => _showEditProfileDialog(),
            context: context,
          ),
          _buildDivider(context),
          _buildSettingsTile(
            icon: Icons.email,
            title: 'Email',
            subtitle: _currentUser?.email ?? 'Non défini',
            onTap: () => _showChangeEmailDialog(),
            context: context,
          ),
          _buildDivider(context),
          _buildSettingsTile(
            icon: Icons.lock,
            title: 'Changer le mot de passe',
            subtitle: 'Sécuriser votre compte',
            onTap: () => _showChangePasswordDialog(),
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context) {
    return Consumer<PreferencesProvider>(
      builder: (context, preferencesProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: ThemeUtils.getSecondaryColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeUtils.getBorderColor(context), 
              width: 1
            ),
          ),
          child: Column(
            children: [
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'Notifications push',
                subtitle: 'Recevoir des notifications',
                value: preferencesProvider.notificationsEnabled,
                onChanged: (value) {
                  preferencesProvider.setNotificationsEnabled(value);
                  _showSnackBar('Notifications ${value ? 'activées' : 'désactivées'}');
                },
                context: context,
              ),
              _buildDivider(context),
              _buildSettingsTile(
                icon: Icons.schedule,
                title: 'Heures de silence',
                subtitle: '22h00 - 08h00',
                onTap: () => _showQuietHoursDialog(),
                context: context,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return Consumer<PreferencesProvider>(
      builder: (context, preferencesProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: ThemeUtils.getSecondaryColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeUtils.getBorderColor(context), 
              width: 1
            ),
          ),
          child: Column(
            children: [
              _buildThemeTile(preferencesProvider, context),
              _buildDivider(context),
              _buildLanguageTile(preferencesProvider, context),
              _buildDivider(context),
              _buildSettingsTile(
                icon: Icons.attach_money,
                title: 'Devise',
                subtitle: preferencesProvider.currencyCode,
                onTap: () => _showCurrencyDialog(preferencesProvider),
                context: context,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeTile(PreferencesProvider preferencesProvider, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.dark_mode, color: ThemeUtils.getIconColor(context), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thème',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeUtils.getPrimaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getThemeDisplayName(preferencesProvider.themeMode),
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeUtils.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: preferencesProvider.themeMode,
              dropdownColor: ThemeUtils.getSecondaryColor(context),
              style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context)),
              items: const [
                DropdownMenuItem(
                  value: 'dark',
                  child: Text('Sombre'),
                ),
                DropdownMenuItem(
                  value: 'light',
                  child: Text('Clair'),
                ),
                DropdownMenuItem(
                  value: 'system',
                  child: Text('Système'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  // Utiliser setState pour forcer la reconstruction du widget
                  setState(() {
                    preferencesProvider.setThemeMode(value);
                  });
                  _showSnackBar('Thème mis à jour');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(PreferencesProvider preferencesProvider, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.language, color: ThemeUtils.getIconColor(context), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Langue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeUtils.getPrimaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getLanguageDisplayName(preferencesProvider.languageCode),
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeUtils.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: preferencesProvider.languageCode,
              dropdownColor: ThemeUtils.getSecondaryColor(context),
              style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context)),
              items: const [
                DropdownMenuItem(
                  value: 'fr',
                  child: Text('Français'),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text('Anglais'),
                ),
                DropdownMenuItem(
                  value: 'es',
                  child: Text('Espagnol'),
                ),
                DropdownMenuItem(
                  value: 'de',
                  child: Text('Allemand'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  // Utiliser setState pour forcer la reconstruction du widget
                  setState(() {
                    preferencesProvider.setLanguageCode(value);
                  });
                  _showSnackBar('Langue mise à jour');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeDisplayName(String themeMode) {
    switch (themeMode) {
      case 'dark':
        return 'Sombre';
      case 'light':
        return 'Clair';
      case 'system':
        return 'Système';
      default:
        return 'Sombre';
    }
  }

  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'Anglais';
      case 'es':
        return 'Espagnol';
      case 'de':
        return 'Allemand';
      default:
        return 'Français';
    }
  }

  Widget _buildPrivacySection(BuildContext context) {
    return Consumer<PreferencesProvider>(
      builder: (context, preferencesProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: ThemeUtils.getSecondaryColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeUtils.getBorderColor(context), 
              width: 1
            ),
          ),
          child: Column(
            children: [
              _buildSwitchTile(
                icon: Icons.location_on,
                title: 'Localisation',
                subtitle: 'Partager ma position',
                value: preferencesProvider.locationEnabled,
                onChanged: (value) {
                  preferencesProvider.setLocationEnabled(value);
                  _showSnackBar('Localisation ${value ? 'activée' : 'désactivée'}');
                },
                context: context,
              ),
              _buildDivider(context),
              _buildSettingsTile(
                icon: Icons.privacy_tip,
                title: 'Politique de confidentialité',
                subtitle: 'Lire notre politique',
                onTap: () => _showPrivacyPolicy(),
                context: context,
              ),
              _buildDivider(context),
              _buildSettingsTile(
                icon: Icons.delete_forever,
                title: 'Supprimer le compte',
                subtitle: 'Action irréversible',
                onTap: () => _showDeleteAccountDialog(),
                isDestructive: true,
                context: context,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeUtils.getSecondaryColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeUtils.getBorderColor(context), 
          width: 1
        ),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.info,
            title: 'Version de l\'application',
            subtitle: '1.0.0',
            onTap: null,
            context: context,
          ),
          _buildDivider(context),
          _buildSettingsTile(
            icon: Icons.help,
            title: 'Centre d\'aide',
            subtitle: 'FAQ et support',
            onTap: () => Navigator.pushNamed(context, '/help'),
            context: context,
          ),
          _buildDivider(context),
          _buildSettingsTile(
            icon: Icons.star,
            title: 'Évaluer l\'application',
            subtitle: 'Sur le Play Store',
            onTap: () => _showSnackBar('Redirection vers le Play Store'),
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
    required BuildContext context,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive 
                  ? Colors.red[400] 
                  : ThemeUtils.getIconColor(context),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive 
                          ? Colors.red[400] 
                          : ThemeUtils.getPrimaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeUtils.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  color: ThemeUtils.getIconColor(context),
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: ThemeUtils.getIconColor(context), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeUtils.getPrimaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeUtils.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      color: ThemeUtils.getBorderColor(context),
      height: 1,
      indent: 56,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEditProfileDialog() {
    // Pour l'instant, utilisons un TextEditingController pour le nom
    final nameController = TextEditingController(
      text: _currentUser?.displayName ?? _currentUser?.email?.split('@')[0] ?? 'Utilisateur'
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeUtils.getSecondaryColor(context),
        title: Text('Modifier le profil', style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Nom',
                labelStyle: TextStyle(color: ThemeUtils.getSecondaryTextColor(context)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeUtils.getBorderColor(context)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.orange),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: ThemeUtils.getSecondaryTextColor(context))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _userService.updateDisplayName(nameController.text);
                // Mettre à jour l'utilisateur courant
                setState(() {
                  _currentUser = _authService.currentUser;
                });
                _showSnackBar('Profil mis à jour avec succès');
              } catch (e) {
                _showSnackBar('Erreur: $e');
              }
            },
            child: const Text('Enregistrer', style: TextStyle(color: AppColors.orange)),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog() {
    final emailController = TextEditingController(text: _currentUser?.email);
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeUtils.getSecondaryColor(context),
        title: Text('Changer l\'email', style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Nouvel email',
                labelStyle: TextStyle(color: ThemeUtils.getSecondaryTextColor(context)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeUtils.getBorderColor(context)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.orange),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Mot de passe actuel',
                labelStyle: TextStyle(color: ThemeUtils.getSecondaryTextColor(context)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeUtils.getBorderColor(context)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.orange),
                ),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: ThemeUtils.getSecondaryTextColor(context))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _userService.updateEmail(
                  emailController.text, 
                  passwordController.text
                );
                // Mettre à jour l'utilisateur courant
                setState(() {
                  _currentUser = _authService.currentUser;
                });
                _showSnackBar('Email mis à jour avec succès');
              } catch (e) {
                _showSnackBar('Erreur: $e');
              }
            },
            child: const Text('Changer', style: TextStyle(color: AppColors.orange)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmNewPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeUtils.getSecondaryColor(context),
        title: Text('Changer le mot de passe', style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Mot de passe actuel',
                labelStyle: TextStyle(color: ThemeUtils.getSecondaryTextColor(context)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeUtils.getBorderColor(context)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.orange),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe',
                labelStyle: TextStyle(color: ThemeUtils.getSecondaryTextColor(context)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeUtils.getBorderColor(context)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.orange),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmNewPasswordController,
              style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Confirmer le nouveau mot de passe',
                labelStyle: TextStyle(color: ThemeUtils.getSecondaryTextColor(context)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeUtils.getBorderColor(context)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.orange),
                ),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: ThemeUtils.getSecondaryTextColor(context))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Vérifier que les mots de passe correspondent
              if (newPasswordController.text != confirmNewPasswordController.text) {
                _showSnackBar('Les nouveaux mots de passe ne correspondent pas');
                return;
              }
              
              // Vérifier que le nouveau mot de passe n'est pas vide
              if (newPasswordController.text.isEmpty) {
                _showSnackBar('Le nouveau mot de passe ne peut pas être vide');
                return;
              }
              
              try {
                await _userService.updatePassword(
                  currentPasswordController.text, 
                  newPasswordController.text
                );
                _showSnackBar('Mot de passe mis à jour avec succès');
              } catch (e) {
                _showSnackBar('Erreur: $e');
              }
            },
            child: const Text('Changer', style: TextStyle(color: AppColors.orange)),
          ),
        ],
      ),
    );
  }

  void _showQuietHoursDialog() {
    // Variables d'état pour les heures de silence
    String startHour = '22';
    String startMinute = '00';
    String endHour = '08';
    String endMinute = '00';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeUtils.getSecondaryColor(context),
        title: Text('Heures de silence', style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context))),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Début', style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: startHour,
                      dropdownColor: ThemeUtils.getSecondaryColor(context),
                      style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context)),
                      underline: Container(),
                      items: List.generate(24, (index) => '$index'.padLeft(2, '0'))
                          .map((hour) => DropdownMenuItem(
                                value: hour,
                                child: Text(hour),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            startHour = value;
                          });
                        }
                      },
                    ),
                    const Text(':', style: TextStyle(color: Colors.white)),
                    DropdownButton<String>(
                      value: startMinute,
                      dropdownColor: ThemeUtils.getSecondaryColor(context),
                      style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context)),
                      underline: Container(),
                      items: ['00', '15', '30', '45']
                          .map((minute) => DropdownMenuItem(
                                value: minute,
                                child: Text(minute),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            startMinute = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Fin', style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: endHour,
                      dropdownColor: ThemeUtils.getSecondaryColor(context),
                      style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context)),
                      underline: Container(),
                      items: List.generate(24, (index) => '$index'.padLeft(2, '0'))
                          .map((hour) => DropdownMenuItem(
                                value: hour,
                                child: Text(hour),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            endHour = value;
                          });
                        }
                      },
                    ),
                    const Text(':', style: TextStyle(color: Colors.white)),
                    DropdownButton<String>(
                      value: endMinute,
                      dropdownColor: ThemeUtils.getSecondaryColor(context),
                      style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context)),
                      underline: Container(),
                      items: ['00', '15', '30', '45']
                          .map((minute) => DropdownMenuItem(
                                value: minute,
                                child: Text(minute),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            endMinute = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: ThemeUtils.getSecondaryTextColor(context))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Ici, vous implémenteriez la logique pour sauvegarder les heures de silence
              // Par exemple, les stocker dans les préférences partagées
              _showSnackBar('Heures de silence mises à jour');
            },
            child: const Text('Enregistrer', style: TextStyle(color: AppColors.orange)),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(PreferencesProvider preferencesProvider) {
    final List<String> currencies = ['EUR', 'USD', 'GBP', 'JPY'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeUtils.getSecondaryColor(context),
        title: Text('Choisir la devise', style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies
              .map((currency) => RadioListTile<String>(
                    title: Text(currency, style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context))),
                    value: currency,
                    groupValue: preferencesProvider.currencyCode,
                    onChanged: (value) {
                      if (value != null) {
                        preferencesProvider.setCurrencyCode(value);
                        Navigator.pop(context);
                        _showSnackBar('Devise mise à jour');
                      }
                    },
                    activeColor: AppColors.orange,
                    fillColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return AppColors.orange;
                        }
                        return ThemeUtils.getSecondaryTextColor(context);
                      },
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeUtils.getSecondaryColor(context),
        title: Text('Politique de confidentialité', style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context))),
        content: const SingleChildScrollView(
          child: Text(
            'Politique de confidentialité de Client Manager\n\n'
            '1. Collecte des données\n'
            'Nous collectons uniquement les informations nécessaires à l\'utilisation de l\'application.\n\n'
            '2. Utilisation des données\n'
            'Vos données sont utilisées pour améliorer votre expérience utilisateur.\n\n'
            '3. Partage des données\n'
            'Nous ne partageons pas vos données personnelles avec des tiers.\n\n'
            '4. Sécurité\n'
            'Nous mettons en place des mesures de sécurité pour protéger vos données.\n\n'
            '5. Contact\n'
            'Pour toute question, contactez-nous à support@clientmanager.com',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer', style: TextStyle(color: AppColors.orange)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeUtils.getSecondaryColor(context),
        title: Text('Supprimer le compte', style: TextStyle(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cette action est irréversible. Êtes-vous sûr de vouloir supprimer votre compte ?',
              style: TextStyle(color: ThemeUtils.getSecondaryTextColor(context)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Confirmez votre mot de passe',
                labelStyle: TextStyle(color: ThemeUtils.getSecondaryTextColor(context)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeUtils.getBorderColor(context)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.orange),
                ),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: ThemeUtils.getSecondaryTextColor(context))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _userService.deleteAccount(passwordController.text);
                _showSnackBar('Compte supprimé avec succès');
                // Déconnecter l'utilisateur après la suppression
                await _authService.signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              } catch (e) {
                _showSnackBar('Erreur: $e');
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}