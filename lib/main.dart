import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'App3/app_theme.dart';
import 'App3/Screens/loginScreen.dart';
import 'App3/Providers/UserProvider.dart';
import 'App3/Providers/ProductProvider.dart';
import 'App3/Providers/CartProvider.dart';
import 'App3/Providers/OrderProvider.dart';
import 'App3/Providers/NotificationProvider.dart';
import 'App3/Providers/BookingProvider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => BookingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel',
      theme: AppTheme.theme,
      home: const LoginScreen(),
    );
  }
}