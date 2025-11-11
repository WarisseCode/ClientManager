import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../core/theme.dart';
import '../core/theme_utils.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final bool isSelected;
  final VoidCallback? onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ThemeUtils.getSecondaryColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.orange : ThemeUtils.getBorderColor(context),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: restaurant.isOpen ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Image du restaurant
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(restaurant.imageUrl),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        // En cas d'erreur de chargement d'image
                      },
                    ),
                  ),
                  child: restaurant.imageUrl.isEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            color: ThemeUtils.getSecondaryColor(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.restaurant,
                            color: ThemeUtils.getIconColor(context),
                            size: 40,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),

                // Informations du restaurant
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              restaurant.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: restaurant.isOpen
                                    ? ThemeUtils.getPrimaryTextColor(context)
                                    : ThemeUtils.getSecondaryTextColor(context),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.orange,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: ThemeUtils.getPrimaryTextColor(context),
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        restaurant.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: restaurant.isOpen
                              ? ThemeUtils.getSecondaryTextColor(context)
                              : ThemeUtils.getSecondaryTextColor(context).withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Statut d'ouverture
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: restaurant.isOpen
                                  ? Colors.green[700]
                                  : Colors.red[700],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              restaurant.isOpen ? 'Ouvert' : 'Fermé',
                              style: TextStyle(
                                color: ThemeUtils.getPrimaryTextColor(context),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}