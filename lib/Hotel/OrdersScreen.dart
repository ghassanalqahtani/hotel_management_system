import 'package:flutter/material.dart';
import 'Data/OrderService.dart';
import 'app_theme.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen(this.userId, {super.key});

  final int userId;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderService _orderService = OrderService();
  late Future<List<dynamic>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderService.getOrders(widget.userId);
  }

  Future<void> _refresh() async {
    setState(() {
      _ordersFuture = _orderService.getOrders(widget.userId);
    });
    await _ordersFuture;
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'Pending':
        return 'قيد الانتظار';
      case 'Processing':
        return 'قيد التجهيز';
      case 'Shipped':
        return 'تم الشحن';
      case 'Delivered':
        return 'تم التسليم';
      case 'Cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Processing':
        return Colors.blue;
      case 'Shipped':
        return Colors.indigo;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return AppColors.danger;
      default:
        return Colors.grey;
    }
  }


  String _formatDate(String value) {
    final text = value.endsWith('Z') ? value : '${value}Z';
    final d = DateTime.tryParse(text)?.toLocal();
    if (d == null) return value;

    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar('طلباتي'),
      body: FutureBuilder<List<dynamic>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  snapshot.error.toString().replaceAll('Exception: ', ''),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text('ما عندك طلبات'));
          }

          return RefreshIndicator(
            color: AppColors.gold,
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final status = '${order['status']}';
                final items = (order['items'] as List<dynamic>?) ?? [];

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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ExpansionTile(
                      shape: const Border(),
                      collapsedShape: const Border(),
                      iconColor: AppColors.black,
                      title: Text(
                        'طلب #${order['id']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(_formatDate('${order['createdAt']}')),
                      trailing: Chip(
                        side: BorderSide.none,
                        label: Text(
                          _statusLabel(status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: _statusColor(status),
                      ),
                      children: [
                        ...items.map(
                              (i) => ListTile(
                            dense: true,
                            title: Text('${i['productName'] ?? ''}'),
                            subtitle: Text('${i['price']} × ${i['quantity']}'),
                            trailing: Text(
                              '${i['lineTotal']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'الإجمالي: ${order['totalAmount']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.goldDark,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}