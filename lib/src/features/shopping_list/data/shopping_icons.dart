import 'package:flutter/material.dart';

class ShoppingIcons {
  static const Map<String, IconData> iconMap = {
    // Lebensmittel
    'apple': Icons.apple,
    'local_grocery_store': Icons.local_grocery_store,
    'bakery_dining': Icons.bakery_dining,
    'coffee': Icons.coffee,
    'wine_bar': Icons.wine_bar,
    'local_pizza': Icons.local_pizza,
    'restaurant': Icons.restaurant,
    'cake': Icons.cake,
    
    // Getränke
    'local_drink': Icons.local_drink,
    'local_bar': Icons.local_bar,
    'emoji_food_beverage': Icons.emoji_food_beverage,
    
    // Haushalt
    'cleaning_services': Icons.cleaning_services,
    'soap': Icons.soap,
    'wash': Icons.wash,
    'lightbulb': Icons.lightbulb,
    'electrical_services': Icons.electrical_services,
    
    // Gesundheit & Pflege
    'health_and_safety': Icons.health_and_safety,
    'medical_services': Icons.medical_services,
    'face': Icons.face,
    'spa': Icons.spa,
    
    // Kleidung
    'checkroom': Icons.checkroom,
    'dry_cleaning': Icons.dry_cleaning,
    
    // Allgemein
    'shopping_cart': Icons.shopping_cart,
    'shopping_bag': Icons.shopping_bag,
    'store': Icons.store,
    'add_shopping_cart': Icons.add_shopping_cart,
    
    // Spielzeug & Freizeit
    'toys': Icons.toys,
    'sports_soccer': Icons.sports_soccer,
    'book': Icons.book,
    'music_note': Icons.music_note,
    
    // Elektronik
    'phone_android': Icons.phone_android,
    'laptop': Icons.laptop,
    'headphones': Icons.headphones,
    'camera': Icons.camera,
    
    // Werkzeug & Garten
    'build': Icons.build,
    'hardware': Icons.hardware,
    'grass': Icons.grass,
    'local_florist': Icons.local_florist,
  };
  
  static IconData getIcon(String iconName) {
    return iconMap[iconName] ?? Icons.shopping_cart;
  }
  
  static List<String> getAllIconNames() {
    return iconMap.keys.toList();
  }
  
  static List<IconCategory> getIconCategories() {
    return [
      IconCategory(
        name: 'Lebensmittel',
        icons: [
          'apple', 'local_grocery_store', 'bakery_dining', 'coffee', 
          'wine_bar', 'local_pizza', 'restaurant', 'cake'
        ],
      ),
      IconCategory(
        name: 'Getränke',
        icons: ['local_drink', 'local_bar', 'emoji_food_beverage'],
      ),
      IconCategory(
        name: 'Haushalt',
        icons: [
          'cleaning_services', 'soap', 'wash', 'lightbulb', 'electrical_services'
        ],
      ),
      IconCategory(
        name: 'Gesundheit',
        icons: ['health_and_safety', 'medical_services', 'face', 'spa'],
      ),
      IconCategory(
        name: 'Kleidung',
        icons: ['checkroom', 'dry_cleaning'],
      ),
      IconCategory(
        name: 'Elektronik',
        icons: ['phone_android', 'laptop', 'headphones', 'camera'],
      ),
      IconCategory(
        name: 'Werkzeug & Garten',
        icons: ['build', 'hardware', 'grass', 'local_florist'],
      ),
      IconCategory(
        name: 'Freizeit',
        icons: ['toys', 'sports_soccer', 'book', 'music_note'],
      ),
      IconCategory(
        name: 'Allgemein',
        icons: ['shopping_cart', 'shopping_bag', 'store', 'add_shopping_cart'],
      ),
    ];
  }
}

class IconCategory {
  final String name;
  final List<String> icons;
  
  const IconCategory({
    required this.name,
    required this.icons,
  });
}