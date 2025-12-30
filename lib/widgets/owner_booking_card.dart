import 'package:flutter/material.dart';
import 'package:staybay/consetans.dart';
import 'package:staybay/models/book_model.dart';
import 'package:staybay/services/owner_update_booking_servcie.dart';

class OwnerBookedCard extends StatefulWidget {
  final BookModel book;
  final VoidCallback? onUpdate;

  const OwnerBookedCard({super.key, required this.book, this.onUpdate});

  @override
  State<OwnerBookedCard> createState() => _OwnerBookedCardState();
}

class _OwnerBookedCardState extends State<OwnerBookedCard> {
  bool _isLoading = false;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'completed':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> _confirmAction(String newStatus) async {
    final bool isApprove = newStatus == 'approved';

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${newStatus[0].toUpperCase()}${newStatus.substring(1)} Booking?',
        ),
        content: Text('Are you sure you want to $newStatus this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('YES, ${newStatus.toUpperCase()}'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _handleUpdate(newStatus);
    }
  }

  Future<void> _handleUpdate(String newStatus) async {
    setState(() => _isLoading = true);

    bool success = await OwnerUpdateBookingService.updateBooking(
      context: context,
      bookingId: widget.book.id.toString(),
      status: newStatus,
    );

    if (success && mounted) {
      if (widget.onUpdate != null) {
        widget.onUpdate!();
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canOwnerEdit = widget.book.canOwnerEdit;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    widget.book.apartment.imagePath.startsWith('http')
                        ? widget.book.apartment.imagePath
                        : '$kBaseUrlImage/${widget.book.apartment.imagePath}',
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _StatusChip(
                    label: widget.book.status,
                    color: _getStatusColor(widget.book.status),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.book.apartment.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "#${widget.book.id}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _DateInfo(label: "Check-in", date: widget.book.startDate),
                      const SizedBox(width: 24),
                      _DateInfo(label: "Check-out", date: widget.book.endDate),
                    ],
                  ),

                  const Divider(height: 32),

                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (canOwnerEdit)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _confirmAction('rejected'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("REJECT"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _confirmAction('approved'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("APPROVE"),
                          ),
                        ),
                      ],
                    )
                  else
                    Center(
                      child: Text(
                        "No further actions available",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateInfo extends StatelessWidget {
  final String label;
  final String date;
  const _DateInfo({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          date,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
