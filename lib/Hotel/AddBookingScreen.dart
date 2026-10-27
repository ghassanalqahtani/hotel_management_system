import 'package:flutter/material.dart';
import 'Data/BookingService.dart';
import 'app_theme.dart';

class AddBookingScreen extends StatefulWidget {
  const AddBookingScreen(this.userId, {super.key});

  final int userId;

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  final BookingService _service = BookingService();

  late Future<List<dynamic>> _roomsFuture;
  dynamic _selectedRoom;
  int _nights = 1;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _roomsFuture = _service.getAvailableRooms();
  }

  void _reload() {
    setState(() {
      _selectedRoom = null;
      _roomsFuture = _service.getAvailableRooms();
    });
  }

  double get _total {
    if (_selectedRoom == null) return 0;
    final price = (_selectedRoom['pricePerNight'] as num?)?.toDouble() ?? 0;
    return price * _nights;
  }

  Future<void> _confirm() async {
    if (_selectedRoom == null) return;

    setState(() => _saving = true);

    try {
      await _service.createBooking(
        widget.userId,
        _selectedRoom['id'] as int,
        _nights,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar('حجز جديد'),
      body: FutureBuilder<List<dynamic>>(
        future: _roomsFuture,
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

          final rooms = snapshot.data ?? [];

          if (rooms.isEmpty) {
            return const Center(child: Text('ما فيه غرف متاحة حالياً'));
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: () async {
                    _reload();
                    await _roomsFuture;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      final selected =
                          _selectedRoom != null && _selectedRoom['id'] == room['id'];

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(() => _selectedRoom = room),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.goldLight : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected ? AppColors.gold : Colors.transparent,
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                                  onPressed: _nights > 1
                                      ? () => setState(() => _nights--)
                                      : null,
                                ),
                                SizedBox(
                                  width: 36,
                                  child: Text(
                                    '$_nights',
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
                                  onPressed: () => setState(() => _nights++),
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
                              '${_total.toStringAsFixed(2)} SAR',
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
                            (_selectedRoom == null || _saving) ? null : _confirm,
                            child: _saving
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
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