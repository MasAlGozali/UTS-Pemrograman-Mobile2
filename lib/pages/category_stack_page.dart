// lib/pages/category_stack_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/order_cubit.dart';
import '../widgets/menu_card.dart'; // Digunakan untuk menampilkan menu

class CategoryStackPage extends StatelessWidget {
  const CategoryStackPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderCubit = context.read<OrderCubit>();

    // List kategori dummy
    final List<String> categories = ['Makanan', 'Minuman', 'Camilan'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Kategori Menu'),
      ),
      body: Column(
        children: [
          // Bagian untuk memilih kategori
          Container(
            height: 60,
            color: Colors.grey[200],
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return BlocBuilder<OrderCubit, OrderState>(
                  builder: (context, state) {
                    final isActive = state.activeCategory == category;
                    return GestureDetector(
                      onTap: () => orderCubit.changeCategory(category),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Theme.of(context).primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isActive ? Colors.transparent : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.black,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<OrderCubit, OrderState>(
              builder: (context, state) {
                if (state.items.isEmpty && orderCubit.menusByCategory.isEmpty) {
                  return const Center(child: Text('Tidak ada menu untuk kategori ini.'));
                }
                return Stack(
                  children: [
                    // Tampilkan menu berdasarkan kategori aktif
                    Positioned.fill(
                      child: ListView.builder(
                        itemCount: orderCubit.menusByCategory.length,
                        itemBuilder: (context, index) {
                          final menu = orderCubit.menusByCategory[index];
                          return MenuCard(menu: menu);
                        },
                      ),
                    ),
                    // Ini adalah contoh bagaimana Stack bisa digunakan untuk overlay
                    // Misalnya, jika kita ingin menampilkan sesuatu di atas list menu
                    // if (state.activeCategory == 'Minuman')
                    //   Positioned(
                    //     bottom: 20,
                    //     right: 20,
                    //     child: FloatingActionButton(
                    //       onPressed: () {},
                    //       child: const Icon(Icons.local_cafe),
                    //     ),
                    //   ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}