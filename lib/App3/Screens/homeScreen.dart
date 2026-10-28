import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/UserProvider.dart';
import '../Providers/CartProvider.dart';
import '../Providers/OrderProvider.dart';
import '../Providers/NotificationProvider.dart';
import '../Providers/BookingProvider.dart';
import '../Providers/ProductProvider.dart';
import 'productsScreen.dart';
import 'cartScreen.dart';
import 'ordersScreen.dart';
import 'notificationsScreen.dart';
import 'bookingScreen.dart';
import 'loginScreen.dart';

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  static const Color black = Color(0xFF1C1C1E);
  static const Color gold = Color(0xFFC9A24D);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<UserProvider>().userId;
      context.read<NotificationProvider>().loadUnreadCount(userId);
    });
  }

  Widget drawerTile({
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

  void logout() {
    context.read<ProductProvider>().clear();
    context.read<CartProvider>().clear();
    context.read<OrderProvider>().clear();
    context.read<NotificationProvider>().clear();
    context.read<BookingProvider>().clear();
    context.read<UserProvider>().logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final unread = context.watch<NotificationProvider>().unreadCount;

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
              icon: Icons.shopping_bag,
              title: 'Products',
              screen: const ProductsScreen(),
            ),
            drawerTile(
              icon: Icons.shopping_cart,
              title: 'Cart',
              screen: const CartScreen(),
            ),
            drawerTile(
              icon: Icons.receipt_long,
              title: 'طلباتي',
              screen: const OrdersScreen(),
            ),
            drawerTile(
              icon: Icons.notifications,
              title: 'الإشعارات',
              screen: const NotificationsScreen(),
              trailing: unread == 0
                  ? null
                  : CircleAvatar(
                radius: 12,
                backgroundColor: gold,
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            drawerTile(
              icon: Icons.book_online,
              title: 'Bookings',
              screen: const BookingScreen(),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: logout,
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