import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../Providers/OrderProvider.dart';
import '../Providers/UserProvider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int get userId => context.read<UserProvider>().userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders(userId);
    });
  }

  String statusLabel(String status) {
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

  Color statusColor(String status) {
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

  String formatDate(String value) {
    final text = value.endsWith('Z') ? value : '${value}Z';
    final d = DateTime.tryParse(text)?.toLocal();
    if (d == null) return value;

    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final orders = provider.orders;

    return Scaffold(
      appBar: buildAppBar('طلباتي'),
      body: Builder(
        builder: (context) {
          if (provider.isLoading && orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(provider.error!, textAlign: TextAlign.center),
              ),
            );
          }

          if (orders.isEmpty) {
            return const Center(child: Text('ما عندك طلبات'));
          }

          return RefreshIndicator(
            color: AppColors.gold,
            onRefresh: () => provider.loadOrders(userId),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
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
                      subtitle: Text(formatDate('${order['createdAt']}')),
                      trailing: Chip(
                        side: BorderSide.none,
                        label: Text(
                          statusLabel(status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: statusColor(status),
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