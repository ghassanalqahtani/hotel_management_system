import 'package:flutter/material.dart';
import 'Data/NotificationService.dart';
import 'app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen(this.userId, {super.key});

  final int userId;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<dynamic>> _load() async {
    final list = await _service.getNotifications(widget.userId);

    try {
      await _service.markAllAsRead(widget.userId);
    } catch (_) {}

    return list;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
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
      appBar: buildAppBar('الإشعارات'),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
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

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(child: Text('ما عندك إشعارات'));
          }

          return RefreshIndicator(
            color: AppColors.gold,
            onRefresh: _refresh,
            child: ListView.builder(
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
                      '${n['message']}\n${_formatDate('${n['createdAt']}')}',
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