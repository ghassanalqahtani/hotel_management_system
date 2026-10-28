import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../Providers/BookingProvider.dart';
import '../Providers/UserProvider.dart';

class AddBookingScreen extends StatefulWidget {
  const AddBookingScreen({super.key});

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  int? selectedRoomId;
  int nights = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadAvailableRooms();
    });
  }

  double get total {
    final rooms = context.read<BookingProvider>().availableRooms;

    for (final r in rooms) {
      if (r['id'] == selectedRoomId) {
        final price = (r['pricePerNight'] as num?)?.toDouble() ?? 0;
        return price * nights;
      }
    }

    return 0;
  }

  Future<void> confirm() async {
    final roomId = selectedRoomId;
    if (roomId == null) return;

    final userId = context.read<UserProvider>().userId;
    final provider = context.read<BookingProvider>();

    final ok = await provider.createBooking(userId, roomId, nights);

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'تعذر الحجز'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final rooms = provider.availableRooms;

    return Scaffold(
      appBar: buildAppBar('حجز جديد'),
      body: Builder(
        builder: (context) {
          if (provider.isLoading && rooms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && rooms.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(provider.error!, textAlign: TextAlign.center),
              ),
            );
          }

          if (rooms.isEmpty) {
            return const Center(child: Text('ما فيه غرف متاحة حالياً'));
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: () => provider.loadAvailableRooms(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(14),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      final selected = selectedRoomId == room['id'];

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () =>
                            setState(() => selectedRoomId = room['id'] as int),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color:
                            selected ? AppColors.goldLight : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? AppColors.gold
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 26,
                                backgroundColor: AppColors.black,
                                child: Icon(Icons.hotel, color: AppColors.gold),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'غرفة ${room['roomNumber'] ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('${room['roomType'] ?? ''}'),
                                  ],
                                ),
                              ),
                              Text(
                                '${room['pricePerNight']} SAR',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.goldDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'عدد الليالي',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: AppColors.black,
                                  onPressed: nights > 1
                                      ? () => setState(() => nights--)
                                      : null,
                                ),
                                SizedBox(
                                  width: 36,
                                  child: Text(
                                    '$nights',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: AppColors.black,
                                  onPressed: () => setState(() => nights++),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'الإجمالي',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${total.toStringAsFixed(2)} SAR',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.goldDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                            (selectedRoomId == null || provider.isSaving)
                                ? null
                                : confirm,
                            child: provider.isSaving
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                                : const Text('تأكيد الحجز'),
                          ),
                        ),
                      ],
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