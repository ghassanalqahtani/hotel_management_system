import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../Providers/NotificationProvider.dart';
import '../Providers/UserProvider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
    });
  }

  Future<void> load() async {
    final userId = context.read<UserProvider>().userId;
    final provider = context.read<NotificationProvider>();

    await provider.loadNotifications(userId);
    await provider.markAllAsRead(userId);
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
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;

    return Scaffold(
      appBar: buildAppBar('الإشعارات'),
      body: Builder(
        builder: (context) {
          if (provider.isLoading && notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(provider.error!, textAlign: TextAlign.center),
              ),
            );
          }

          if (notifications.isEmpty) {
            return const Center(child: Text('ما عندك إشعارات'));
          }

          return RefreshIndicator(
            color: AppColors.gold,
            onRefresh: load,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(14),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                final unread = n['isRead'] == false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: unread ? AppColors.goldLight : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: unread ? AppColors.goldBorder : Colors.transparent,
                    ),
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
                      horizontal: 14,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor:
                      unread ? AppColors.black : AppColors.background,
                      child: Icon(
                        unread
                            ? Icons.notifications_active
                            : Icons.notifications_none,
                        color: unread ? AppColors.gold : Colors.grey,
                      ),
                    ),
                    title: Text(
                      '${n['title']}',
                      style: TextStyle(
                        fontWeight:
                        unread ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${n['message']}\n${formatDate('${n['createdAt']}')}',
                    ),
                    isThreeLine: true,
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