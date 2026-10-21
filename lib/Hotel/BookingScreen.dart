import 'package:flutter/material.dart';
import 'data/BookingService.dart';
import 'data/conncetion.dart';

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

  Future<void> cancelBooking(int bookingId) async {
    try {
      await bookingService.cancelBooking(
        widget.userId,
        bookingId,
      );

      if (!mounted) return;

      setState(() {
        loadBookings();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: bookingItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text('No Bookings Found'),
            );
          }

          double total = 0;

          for (var item in items) {
            total += (item['roomPrice'] as num).toDouble() * (item['nights'] as num).toInt();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    final String imagePath = item['roomImageUrl']?.toString() ?? '';

                    final String imageUrl = imagePath.isEmpty
                        ? ''
                        : Uri.parse(ConnectionString.baseUrl)
                        .resolve(imagePath)
                        .toString();

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: SizedBox(
                          width: 65,
                          height: 65,
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.hotel);
                            },
                          )
                              : const Icon(Icons.hotel),
                        ),
                        title: Text(
                          item['roomName']?.toString() ?? 'Room Details',
                        ),
                        subtitle: Text(
                          '${item['roomPrice']} SAR / Night\n'
                              'Nights: ${item['nights']} | Status: ${item['status']}\n'
                              'Check-in: ${item['checkInDate']}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            cancelBooking(item['bookingId']);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Text(
                  'Total Cost: ${total.toStringAsFixed(2)} SAR',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
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
