import 'package:flutter/material.dart';
import 'Data/CartService.dart';
import 'Data/OrderService.dart';
import 'Data/conncetion.dart';
import 'app_theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen(this.userId, {super.key});

  final int userId;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();

  late Future<List<dynamic>> _cartFuture;
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    _cartFuture = _loadCart();
  }

  Future<List<dynamic>> _loadCart() async {
    final items = await _cartService.getCart(widget.userId);
    print('CART BODY: $items'); // عشان نتأكد من أسماء الحقول
    return items;
  }

  void _reload() {
    setState(() {
      _cartFuture = _loadCart();
    });
  }

  String _cleanError(Object e) => e.toString().replaceAll('Exception: ', '');

  void _showMessage(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? AppColors.danger : AppColors.black,
      ),
    );
  }

  String _imageUrl(dynamic path) {
    final p = path?.toString() ?? '';
    if (p.isEmpty) return '';
    if (p.startsWith('http')) return p;
    return Uri.parse(ConnectionString.imagesBaseUrl).resolve(p).toString();
  }

  Future<void> _placeOrder() async {
    setState(() => _placing = true);

    try {
      final orderId = await _orderService.makeOrder(widget.userId);
      if (!mounted) return;
      _showMessage('تم إنشاء الطلب رقم $orderId');
      _reload();
    } catch (e) {
      if (!mounted) return;
      _showMessage(_cleanError(e), error: true);
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  Future<void> _remove(int productId) async {
    try {
      await _cartService.removeFromCart(widget.userId, productId);
      if (!mounted) return;
      _reload();
    } catch (e) {
      if (!mounted) return;
      _showMessage(_cleanError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar('Cart'),
      body: FutureBuilder<List<dynamic>>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _cleanError(snapshot.error!),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(child: Text('السلة فاضية'));
          }

          final total = items.fold<double>(
            0,
                (sum, item) => sum + ((item['totalPrice'] ?? 0) as num).toDouble(),
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final image = _imageUrl(item['productImage']);

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
                          onPressed: () => _remove(item['productId'] as int),
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
                              total.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.goldDark,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: _placing ? null : _placeOrder,
                          child: _placing
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