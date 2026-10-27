import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/UserProvider.dart';
import '../../Hotel/Data/NotificationService.dart';
import '../../Hotel/productsScreen.dart';
import '../../Hotel/BookingScreen.dart';
import '../../Hotel/CartScreen.dart';
import '../../Hotel/OrdersScreen.dart';
import '../../Hotel/NotificationsScreen.dart';
import 'loginScreen.dart';

class homeScreen extends StatelessWidget {
  const homeScreen({super.key});

  static const Color black = Color(0xFF1C1C1E);
  static const Color gold = Color(0xFFC9A24D);

  Widget drawerTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Widget screen,
        Widget? trailing,
      }) {
    return ListTile(
      leading: Icon(icon, color: black),
      title: Text(title),
      trailing: trailing,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final userId = userProvider.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true,
        backgroundColor: black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              color: black,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: gold,
                    child: Icon(Icons.person, size: 36, color: black),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    userProvider.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userProvider.email,
                    style: const TextStyle(color: Color(0xB3FFFFFF)),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: black),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            drawerTile(
              context,
              icon: Icons.shopping_bag,
              title: 'Products',
              screen: ProductsScreen(userId),
            ),
            drawerTile(
              context,
              icon: Icons.shopping_cart,
              title: 'Cart',
              screen: CartScreen(userId),
            ),
            drawerTile(
              context,
              icon: Icons.receipt_long,
              title: 'طلباتي',
              screen: OrdersScreen(userId),
            ),
            drawerTile(
              context,
              icon: Icons.notifications,
              title: 'الإشعارات',
              screen: NotificationsScreen(userId),
              trailing: FutureBuilder<int>(
                future: NotificationService().getUnreadCount(userId),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  if (count == 0) return const SizedBox.shrink();

                  return CircleAvatar(
                    radius: 12,
                    backgroundColor: gold,
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            drawerTile(
              context,
              icon: Icons.book_online,
              title: 'Bookings',
              screen: BookingScreen(userId),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                context.read<UserProvider>().logout();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hotel, size: 60, color: gold),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome Ya ${userProvider.username}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}