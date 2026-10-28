import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../Data/connection.dart';
import '../Providers/CartProvider.dart';
import '../Providers/UserProvider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int get userId => context.read<UserProvider>().userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart(userId);
    });
  }

  void showMessage(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? AppColors.danger : AppColors.black,
      ),
    );
  }

  String imageUrl(dynamic path) {
    final p = path?.toString() ?? '';
    if (p.isEmpty) return '';
    if (p.startsWith('http')) return p;
    return Uri.parse(ConnectionString.dashboardUrl).resolve(p).toString();
  }

  Future<void> placeOrder() async {
    final provider = context.read<CartProvider>();
    final orderId = await provider.placeOrder(userId);

    if (!mounted) return;

    if (orderId > 0) {
      showMessage('تم إنشاء الطلب رقم $orderId');
    } else {
      showMessage(provider.error ?? 'تعذر إنشاء الطلب', error: true);
    }
  }

  Future<void> remove(int productId) async {
    final provider = context.read<CartProvider>();
    final ok = await provider.removeItem(userId, productId);

    if (!mounted) return;

    if (!ok) {
      showMessage(provider.error ?? 'تعذر الحذف', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CartProvider>();
    final items = provider.items;

    return Scaffold(
      appBar: buildAppBar('Cart'),
      body: Builder(
        builder: (context) {
          if (provider.isLoading && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(provider.error!, textAlign: TextAlign.center),
              ),
            );
          }

          if (items.isEmpty) {
            return const Center(child: Text('السلة فاضية'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final image = imageUrl(item['productImage']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: image.isEmpty
                                ? const Icon(
                              Icons.fastfood,
                              color: AppColors.black,
                            )
                                : Image.network(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.fastfood,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          '${item['productName'] ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${item['price']} × ${item['quantity']} = ${item['totalPrice']}',
                          style: const TextStyle(color: AppColors.goldDark),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.danger,
                          ),
                          onPressed: () => remove(item['productId'] as int),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              provider.total.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.goldDark,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: provider.isPlacing ? null : placeOrder,
                          child: provider.isPlacing
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : const Text('إتمام الطلب'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}