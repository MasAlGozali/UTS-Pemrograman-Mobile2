// lib/blocs/order_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/menu_model.dart';

// State untuk OrderCubit
class OrderState extends Equatable {
  final List<OrderItem> items;
  final int totalAmount; // Total harga setelah diskon item
  final int finalAmount; // Total harga setelah diskon bonus (jika ada)
  final String activeCategory; // Untuk Category Stack

  const OrderState({
    this.items = const [],
    this.totalAmount = 0,
    this.finalAmount = 0,
    this.activeCategory = 'Makanan', // Default kategori aktif
  });

  @override
  List<Object> get props => [items, totalAmount, finalAmount, activeCategory];

  OrderState copyWith({
    List<OrderItem>? items,
    int? totalAmount,
    int? finalAmount,
    String? activeCategory,
  }) {
    return OrderState(
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      activeCategory: activeCategory ?? this.activeCategory,
    );
  }
}

class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(const OrderState());

  // Data dummy menu
  static const List<MenuModel> _allMenus = [
    MenuModel(id: '1', name: 'Nasi Goreng', price: 20000, category: 'Makanan', discount: 0.1),
    MenuModel(id: '2', name: 'Mie Ayam', price: 18000, category: 'Makanan'),
    MenuModel(id: '3', name: 'Ayam Bakar', price: 25000, category: 'Makanan', discount: 0.05),
    MenuModel(id: '4', name: 'Es Teh Manis', price: 5000, category: 'Minuman'),
    MenuModel(id: '5', name: 'Es Jeruk', price: 7000, category: 'Minuman'),
    MenuModel(id: '6', name: 'Kopi Hitam', price: 8000, category: 'Minuman'),
    MenuModel(id: '7', name: 'Tahu Isi', price: 3000, category: 'Camilan'),
    MenuModel(id: '8', name: 'Tempe Mendoan', price: 4000, category: 'Camilan'),
  ];

  // Getter untuk mendapatkan semua menu
  List<MenuModel> get allMenus => _allMenus;

  // Getter untuk mendapatkan menu berdasarkan kategori aktif
  List<MenuModel> get menusByCategory => _allMenus
      .where((menu) => menu.category == state.activeCategory)
      .toList();

  void changeCategory(String category) {
    emit(state.copyWith(activeCategory: category));
    // Setelah kategori berubah, kita bisa memicu update UI di halaman terkait
  }

  void addToOrder(MenuModel menu) {
    final List<OrderItem> currentItems = List.from(state.items);
    final int existingIndex = currentItems.indexWhere((item) => item.menu.id == menu.id);

    if (existingIndex != -1) {
      // Jika item sudah ada, update kuantitas
      final updatedItem = currentItems[existingIndex].copyWith(
        quantity: currentItems[existingIndex].quantity + 1,
      );
      currentItems[existingIndex] = updatedItem;
    } else {
      // Jika item belum ada, tambahkan baru
      currentItems.add(OrderItem(menu: menu, quantity: 1));
    }

    _updateOrderState(currentItems);
  }

  void removeFromOrder(MenuModel menu) {
    final List<OrderItem> currentItems = List.from(state.items);
    final int existingIndex = currentItems.indexWhere((item) => item.menu.id == menu.id);

    if (existingIndex != -1) {
      final OrderItem item = currentItems[existingIndex];
      if (item.quantity > 1) {
        // Kurangi kuantitas jika lebih dari 1
        currentItems[existingIndex] = item.copyWith(quantity: item.quantity - 1);
      } else {
        // Hapus item jika kuantitasnya 1
        currentItems.removeAt(existingIndex);
      }
      _updateOrderState(currentItems);
    }
  }

  void updateQuantity(MenuModel menu, int qty) {
    final List<OrderItem> currentItems = List.from(state.items);
    final int existingIndex = currentItems.indexWhere((item) => item.menu.id == menu.id);

    if (existingIndex != -1) {
      if (qty > 0) {
        currentItems[existingIndex] = currentItems[existingIndex].copyWith(quantity: qty);
      } else {
        // Hapus jika kuantitas diatur ke 0 atau kurang
        currentItems.removeAt(existingIndex);
      }
      _updateOrderState(currentItems);
    }
  }

  // Fungsi untuk menghitung total harga (setelah diskon per item)
  int _calculateTotalAmount(List<OrderItem> items) {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  // Fungsi untuk menghitung total harga akhir (setelah diskon bonus)
  int getTotalPrice() {
    int totalAmount = _calculateTotalAmount(state.items);
    int finalAmount = totalAmount;

    // BAGIAN C - BONUS: Diskon total transaksi 10% jika belanja > Rp 100.000
    if (totalAmount > 100000) {
      finalAmount = (totalAmount - (totalAmount * 0.10)).toInt();
    }

    return finalAmount;
  }

  void _updateOrderState(List<OrderItem> newItems) {
    final int newTotalAmount = _calculateTotalAmount(newItems);
    final int newFinalAmount = newTotalAmount > 100000
        ? (newTotalAmount - (newTotalAmount * 0.10)).toInt()
        : newTotalAmount; // Terapkan bonus diskon saat update state

    emit(state.copyWith(
      items: newItems,
      totalAmount: newTotalAmount,
      finalAmount: newFinalAmount,
    ));
  }


  void clearOrder() {
    emit(const OrderState(activeCategory: 'Makanan')); // Reset ke initial state
  }
}