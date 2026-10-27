import 'package:flutter/material.dart';
import 'Data/NotificationService.dart';
import 'app_theme.dart';
import 'productsScreen.dart';
import 'BookingScreen.dart';
import 'CartScreen.dart';
import 'OrdersScreen.dart';
import 'NotificationsScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen(this.username, this.userId, this.email, {super.key});

  final String username;
  final int userId;
  final String email;

  Widget _drawerTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Widget screen,
        Widget? trailing,
      }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.black),
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
    return Scaffold(
      appBar: buildAppBar('Home Page'),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              color: AppColors.black,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.gold,
                    child: Icon(Icons.person, size: 36, color: AppColors.black),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(color: Color(0xB3FFFFFF)),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: AppColors.black),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            _drawerTile(
              context,
              icon: Icons.shopping_bag,
              title: 'Products',
              screen: ProductsScreen(userId),
            ),
            _drawerTile(
              context,
              icon: Icons.shopping_cart,
              title: 'Cart',
              screen: CartScreen(userId),
            ),
            _drawerTile(
              context,
              icon: Icons.receipt_long,
              title: 'طلباتي',
              screen: OrdersScreen(userId),
            ),
            _drawerTile(
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
                    backgroundColor: AppColors.gold,
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            _drawerTile(
              context,
              icon: Icons.book_online,
              title: 'Bookings',
              screen: BookingScreen(userId),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
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
                color: AppColors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hotel, size: 60, color: AppColors.gold),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome Ya $username',
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