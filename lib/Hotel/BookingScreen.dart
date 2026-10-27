import 'package:flutter/material.dart';
import 'Data/BookingService.dart';
import 'AddBookingScreen.dart';
import 'app_theme.dart';

class BookingScreen extends StatefulWidget {
  final int userId;

  const BookingScreen(this.userId, {super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingService bookingService = BookingService();
  late Future<List<dynamic>> bookingItems;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  void loadBookings() {
    bookingItems = bookingService.getBookings(widget.userId);
  }

  Future<void> openAddBooking() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddBookingScreen(widget.userId),
      ),
    );

    if (added == true && mounted) {
      setState(() {
        loadBookings();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الحجز بنجاح')),
      );
    }
  }

  Future<void> confirmAndCancel(int bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await cancelBooking(bookingId);
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    try {
      await bookingService.cancelBooking(widget.userId, bookingId);

      if (!mounted) return;

      setState(() {
        loadBookings();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        'My Bookings',
        actions: [
          IconButton(
            onPressed: openAddBooking,
            icon: const Icon(
              Icons.add_circle,
              color: AppColors.gold,
              size: 30,
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: bookingItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(child: Text('No Bookings Found'));
          }

          double total = 0;
          for (var item in items) {
            total += (item['totalPrice'] as num?)?.toDouble() ?? 0;
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

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
                          horizontal: 14,
                          vertical: 8,
                        ),
                        leading: const CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.black,
                          child: Icon(Icons.hotel, color: AppColors.gold),
                        ),
                        title: Text(
                          'غرفة ${item['roomNumber'] ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${item['customerName'] ?? ''}\n'
                              'Nights: ${item['numberOfNights']} | Total: ${item['totalPrice']} SAR',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: AppColors.danger,
                          ),
                          onPressed: () => confirmAndCancel(item['id'] as int),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Total Cost: ${total.toStringAsFixed(2)} SAR',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
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