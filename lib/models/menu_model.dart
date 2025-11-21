// lib/models/menu_model.dart
import 'package:equatable/equatable.dart';

class MenuModel extends Equatable {
  final String id;
  final String name;
  final int price;
  final String category;
  final double discount; // Nilai antara 0-1 (e.g., 0.1 untuk 10% diskon)

  const MenuModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.discount = 0.0, // Default tidak ada diskon
  });

  // Method untuk mendapatkan harga setelah diskon
  int getDiscountedPrice() {
    return (price - (price * discount)).toInt();
  }

  // Override props dari Equatable untuk perbandingan objek
  @override
  List<Object?> get props => [id, name, price, category, discount];

  // Helper untuk membuat copy dari objek (jika perlu untuk perubahan)
  MenuModel copyWith({
    String? id,
    String? name,
    int? price,
    String? category,
    double? discount,
  }) {
    return MenuModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      discount: discount ?? this.discount,
    );
  }
}

// Untuk OrderItem yang akan disimpan di Cubit
class OrderItem extends Equatable {
  final MenuModel menu;
  final int quantity;

  const OrderItem({
    required this.menu,
    required this.quantity,
  });

  // Getter untuk total harga item ini (setelah diskon)
  int get totalPrice => menu.getDiscountedPrice() * quantity;

  @override
  List<Object?> get props => [menu, quantity];

  OrderItem copyWith({
    MenuModel? menu,
    int? quantity,
  }) {
    return OrderItem(
      menu: menu ?? this.menu,
      quantity: quantity ?? this.quantity,
    );
  }
}