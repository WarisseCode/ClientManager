import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../core/theme_utils.dart';

/// Page d'aide avec FAQ et support
class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'Comment me connecter à l\'application ?',
      answer: 'Vous pouvez vous connecter de deux façons :\n\n1. Avec votre email et mot de passe\n2. Avec votre compte Google\n\nAppuyez sur le bouton "Se connecter" et choisissez votre méthode préférée.',
      category: 'Connexion',
    ),
    FAQItem(
      question: 'Comment créer un nouveau compte ?',
      answer: 'Pour créer un compte :\n\n1. Allez sur la page de connexion\n2. Appuyez sur "Créer un compte"\n3. Remplissez le formulaire avec vos informations\n4. Confirmez votre mot de passe\n5. Appuyez sur "Créer le compte"',
      category: 'Compte',
    ),
    FAQItem(
      question: 'J\'ai oublié mon mot de passe, que faire ?',
      answer: 'Si vous avez oublié votre mot de passe :\n\n1. Sur la page de connexion, appuyez sur "Mot de passe oublié"\n2. Entrez votre adresse email\n3. Vérifiez votre boîte mail pour le lien de réinitialisation\n4. Suivez les instructions dans l\'email',
      category: 'Compte',
    ),
    FAQItem(
      question: 'Comment prendre une nouvelle commande ?',
      answer: 'Pour prendre une commande :\n\n1. Allez dans l\'onglet "Commandes"\n2. Appuyez sur "Nouvelle commande"\n3. Sélectionnez la table\n4. Ajoutez les articles souhaités\n5. Confirmez la commande',
      category: 'Commandes',
    ),
    FAQItem(
      question: 'Comment modifier mes informations de profil ?',
      answer: 'Pour modifier votre profil :\n\n1. Allez dans l\'onglet "Profil"\n2. Appuyez sur "Paramètres"\n3. Sélectionnez "Modifier le profil"\n4. Mettez à jour vos informations\n5. Sauvegardez les modifications',
      category: 'Profil',
    ),
    FAQItem(
      question: 'Comment contacter le support technique ?',
      answer: 'Vous pouvez nous contacter :\n\n• Par email : support@clientmanager.com\n• Par téléphone : +33 1 23 45 67 89\n• Via le chat en ligne (disponible 24h/7j)\n• En remplissant le formulaire de contact ci-dessous',
      category: 'Support',
    ),
    FAQItem(
      question: 'L\'application ne fonctionne pas correctement',
      answer: 'Si vous rencontrez des problèmes :\n\n1. Vérifiez votre connexion internet\n2. Redémarrez l\'application\n3. Mettez à jour l\'application si nécessaire\n4. Contactez le support si le problème persiste',
      category: 'Problèmes',
    ),
    FAQItem(
      question: 'Comment changer la langue de l\'application ?',
      answer: 'Pour changer la langue :\n\n1. Allez dans "Profil" > "Paramètres"\n2. Sélectionnez "Langue"\n3. Choisissez votre langue préférée\n4. L\'application se mettra à jour automatiquement',
      category: 'Paramètres',
    ),
  ];

  List<FAQItem> _filteredItems = [];
  String _selectedCategory = 'Tous';

  @override
  void initState() {
    super.initState();
    _filteredItems = _faqItems;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          child: Column(
            children: [
              // Header avec bouton retour
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: ThemeUtils.getPrimaryTextColor(context)),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Centre d\'aide',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ThemeUtils.getPrimaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Barre de recherche
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: ThemeUtils.getSecondaryColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeUtils.getBorderColor(context), width: 1),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context)),
                  decoration: InputDecoration(
                    hintText: 'Rechercher dans l\'aide...',
                    hintStyle: TextStyle(color: ThemeUtils.getSecondaryTextColor(context)),
                    prefixIcon: Icon(Icons.search, color: ThemeUtils.getIconColor(context)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onChanged: _filterItems,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Filtres par catégorie
              _buildCategoryFilter(context),
              
              const SizedBox(height: 16),
              
              // Actions rapides
              _buildQuickActions(context),
              
              const SizedBox(height: 16),
              
              // Liste FAQ
              Expanded(
                child: _filteredItems.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          return _buildFAQItem(context, _filteredItems[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    final categories = ['Tous', ..._faqItems.map((e) => e.category).toSet()];
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                  _filterItems(_searchController.text);
                });
              },
              backgroundColor: ThemeUtils.getSecondaryColor(context),
              selectedColor: AppColors.orange,
              labelStyle: TextStyle(
                color: isSelected ? ThemeUtils.getPrimaryTextColor(context) : ThemeUtils.getSecondaryTextColor(context),
              ),
              side: BorderSide(
                color: isSelected ? AppColors.orange : ThemeUtils.getBorderColor(context),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionButton(
              context,
              'Contacter le support',
              Icons.support_agent,
              () => _showContactSupport(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionButton(
              context,
              'Signaler un bug',
              Icons.bug_report,
              () => _showBugReport(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: ThemeUtils.getSecondaryColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeUtils.getBorderColor(context), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.orange, size: 20),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeUtils.getPrimaryTextColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, FAQItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ThemeUtils.getSecondaryColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeUtils.getBorderColor(context), width: 1),
      ),
      child: ExpansionTile(
        title: Text(
          item.question,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeUtils.getPrimaryTextColor(context),
          ),
        ),
        subtitle: Text(
          item.category,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.orange,
          ),
        ),
        iconColor: AppColors.orange,
        collapsedIconColor: ThemeUtils.getIconColor(context),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              item.answer,
              style: TextStyle(
                fontSize: 14,
                color: ThemeUtils.getPrimaryTextColor(context),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: ThemeUtils.getIconColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeUtils.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez avec d\'autres mots-clés',
            style: TextStyle(
              fontSize: 14,
              color: ThemeUtils.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = _faqItems.where((item) {
        final matchesSearch = query.isEmpty ||
            item.question.toLowerCase().contains(query.toLowerCase()) ||
            item.answer.toLowerCase().contains(query.toLowerCase());
        
        final matchesCategory = _selectedCategory == 'Tous' ||
            item.category == _selectedCategory;
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _showContactSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildContactSupportSheet(context),
    );
  }

  Widget _buildContactSupportSheet(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeUtils.getSecondaryColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contacter le support',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ThemeUtils.getPrimaryTextColor(context),
            ),
          ),
          const SizedBox(height: 20),
          
          _buildContactOption(
            context,
            'Email',
            'support@clientmanager.com',
            Icons.email,
            () => _copyToClipboard('support@clientmanager.com'),
          ),
          _buildContactOption(
            context,
            'Téléphone',
            '+33 1 23 45 67 89',
            Icons.phone,
            () => _copyToClipboard('+33123456789'),
          ),
          _buildContactOption(
            context,
            'Chat en ligne',
            'Disponible 24h/7j',
            Icons.chat,
            () => _showSnackBar(context, 'Chat en ligne bientôt disponible'),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContactOption(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ThemeUtils.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeUtils.getBorderColor(context), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.orange, size: 24),
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
                Icon(Icons.copy, color: ThemeUtils.getIconColor(context), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBugReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeUtils.getSecondaryColor(context),
        title: Text('Signaler un bug', style: TextStyle(color: ThemeUtils.getPrimaryTextColor(context))),
        content: Text(
          'Pour signaler un bug, veuillez nous envoyer un email à bugs@clientmanager.com avec :\n\n• Description du problème\n• Étapes pour le reproduire\n• Version de l\'application\n• Modèle de votre appareil',
          style: TextStyle(color: ThemeUtils.getSecondaryTextColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: ThemeUtils.getSecondaryTextColor(context))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _copyToClipboard('bugs@clientmanager.com');
            },
            child: Text('Copier l\'email', style: TextStyle(color: AppColors.orange)),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    // Note: Nous devons obtenir le contexte depuis le widget pour afficher le snackbar
    // Cette méthode est appelée depuis un contexte qui a accès à Scaffold
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  final String category;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}
