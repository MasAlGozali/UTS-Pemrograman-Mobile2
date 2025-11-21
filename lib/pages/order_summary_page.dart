// lib/pages/order_summary_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/order_cubit.dart';
import '../models/menu_model.dart'; // Import OrderItem

class OrderSummaryPage extends StatelessWidget {
  const OrderSummaryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Pesanan'),
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return const Center(child: Text('Belum ada pesanan.'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final OrderItem item = state.items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.menu.name,
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Harga: Rp ${item.menu.getDiscountedPrice()} x ${item.quantity}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    'Subtotal: Rp ${item.totalPrice}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  onPressed: () {
                                    context.read<OrderCubit>().removeFromOrder(item.menu);
                                  },
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle),
                                  onPressed: () {
                                    context.read<OrderCubit>().addToOrder(item.menu);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Total Pesanan (sebelum diskon bonus): Rp ${state.totalAmount}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (state.totalAmount > 100000) // Tampilkan jika diskon bonus diterapkan
                      Text(
                        'Diskon Bonus (10%): Rp ${state.totalAmount - state.finalAmount}',
                        style: const TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    const Divider(height: 20, thickness: 2),
                    Text(
                      'Total Akhir: Rp ${state.finalAmount}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<OrderCubit>().clearOrder();
                        Navigator.pop(context); // Kembali ke halaman utama
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pesanan berhasil diselesaikan!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Selesaikan Pesanan', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}