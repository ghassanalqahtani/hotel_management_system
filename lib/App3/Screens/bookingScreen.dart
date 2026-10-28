import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../Providers/BookingProvider.dart';
import '../Providers/UserProvider.dart';
import 'addBookingScreen.dart';


class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int get userId => context.read<UserProvider>().userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadBookings(userId);
    });
  }

  Future<void> openAddBooking() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddBookingScreen()),
    );

    if (added == true && mounted) {
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

    if (confirm != true || !mounted) return;

    final provider = context.read<BookingProvider>();
    final ok = await provider.cancelBooking(userId, bookingId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Booking cancelled successfully' : 'Error: ${provider.error}',
        ),
        backgroundColor: ok ? AppColors.black : AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final items = provider.bookings;

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
      body: Builder(
        builder: (context) {
          if (provider.isLoading && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: ${provider.error}'),
              ),
            );
          }

          if (items.isEmpty) {
            return const Center(child: Text('No Bookings Found'));
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
                      'Total Cost: ${provider.total.toStringAsFixed(2)} SAR',
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