import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staybay/models/apartment_model.dart';
import 'package:staybay/services/get_apartment_not_available_dates_service.dart';

class BookingDetailsScreen extends StatefulWidget {
  static const routeName = 'bookingDetails';
  final Apartment? apartment;

  const BookingDetailsScreen({super.key, required this.apartment});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  DateTimeRange? _selectedRange;
  // String? _paymentMethod;
  List<DateTime> _blockedDates = [];
  bool _isLoadingDates = true;

  @override
  void initState() {
    super.initState();
    _fetchBlockedDates();
  }

  Future<void> _fetchBlockedDates() async {
    final dates = await GetApartmentNotAvailableDatesService.getDisabledDates(
      widget.apartment!.id,
    );
    setState(() {
      _blockedDates = dates;
      _isLoadingDates = false;
    });
  }

  
  bool _isDayAvailable(DateTime date) {
    return !_blockedDates.any((blocked) => DateUtils.isSameDay(blocked, date));
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedRange,
      selectableDayPredicate: (DateTime date, DateTime? _, DateTime? _) =>
          _isDayAvailable(date), 
    );

    if (picked == null) return;

    bool hasBlockedDateInRange = false;
    for (int i = 0; i <= picked.end.difference(picked.start).inDays; i++) {
      DateTime current = picked.start.add(Duration(days: i));
      if (!_isDayAvailable(current)) {
        hasBlockedDateInRange = true;
        break;
      }
    }

    if (hasBlockedDateInRange) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected Dates Contains Unavailable Dates.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _selectedRange = picked);
  }

  int get nights => (_selectedRange?.duration.inDays ?? 0) + 1;
  double get total =>
      (widget.apartment?.pricePerNight ?? 0) *
      (nights == 0 ? 0 : nights.toDouble());

  @override
  Widget build(BuildContext context) {
    final apt = widget.apartment;
    if (apt == null) return const Scaffold(body: Center(child: Text("Error")));

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details'), centerTitle: true),
      body: _isLoadingDates
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildApartmentHeader(apt),
                const SizedBox(height: 24),
                _buildDateRangePickerTile(),
                const SizedBox(height: 20),
                // _buildPaymentDropdown(),
                const SizedBox(height: 32),
                _buildPriceSummary(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        (_selectedRange == null
                        // || _paymentMethod == null
                        )
                        ? null
                        : () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Booking Confirmed!'),
                              ),
                            );
                          },
                    child: const Text(
                      'Confirm Booking',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildApartmentHeader(Apartment apt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            apt.imagePath,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(height: 220, color: Colors.grey[200]),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          apt.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          apt.location ?? "Unknown location",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDateRangePickerTile() {
    final bool hasDate = _selectedRange != null;
    return InkWell(
      onTap: _pickDateRange,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDate ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.blue),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasDate
                      ? "${DateFormat('MMM d').format(_selectedRange!.start)} - ${DateFormat('MMM d, yyyy').format(_selectedRange!.end)}"
                      : "Select Dates",
                  style: TextStyle(
                    fontWeight: hasDate ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                Text(
                  hasDate ? "$nights nights" : "Check-in to Check-out",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.edit, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Widget _buildPaymentDropdown() {
  //   return DropdownButtonFormField<String>(
  //     value: _paymentMethod,
  //     decoration: InputDecoration(
  //       labelText: 'Payment Method',
  //       prefixIcon: const Icon(Icons.payment),
  //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  //     ),
  //     items: const [
  //       DropdownMenuItem(value: 'Cash', child: Text('Cash')),
  //       DropdownMenuItem(value: 'Card', child: Text('Credit Card')),
  //       DropdownMenuItem(value: 'PayPal', child: Text('PayPal')),
  //     ],
  //     onChanged: (val) => setState(() => _paymentMethod = val),
  //   );
  // }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total Price",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Text(
            "\$${total.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
