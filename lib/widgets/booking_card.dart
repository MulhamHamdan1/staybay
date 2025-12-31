import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:staybay/constants.dart';
import 'package:staybay/models/book_model.dart';
import 'package:staybay/models/chat.dart';
import 'package:staybay/screens/booking_details_screen.dart';
import 'package:staybay/screens/chat_screen.dart';
import 'package:staybay/services/chat_service.dart';
import 'package:staybay/services/pay_booking_service.dart';
import 'package:staybay/services/rate_booking_service.dart';
import 'package:staybay/widgets/rating_dialog.dart';

class BookedCard extends StatefulWidget {
  final BookModel book;
  final VoidCallback? onUpdate;

  const BookedCard({super.key, required this.book, this.onUpdate});

  @override
  State<BookedCard> createState() => _BookedCardState();
}

class _BookedCardState extends State<BookedCard> {
  bool _isActionLoading = false;

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
      case 'started':
        return Colors.blue;
      case 'completed':
      case 'finished':
        return Colors.teal;
      case 'failed':
        return Colors.deepOrange;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.book.status;
    final bool canEdit = widget.book.canUserEdit;
    final bool canRate = widget.book.userCanRate;
    final bool canPay = widget.book.canUserPay;
    final double ratingVal =
        (double.tryParse(widget.book.apartment.rating) ?? 0.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                widget.book.apartment.imagePath.startsWith('http')
                    ? widget.book.apartment.imagePath
                    : '$kBaseUrlImage/${widget.book.apartment.imagePath}',
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 170,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.book.apartment.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _StatusChip(
                        label: widget.book.status,
                        color: _getStatusColor(status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.book.apartment.location ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "Total: \$${widget.book.totalPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < ratingVal.floor()
                                ? Icons.star
                                : Icons.star_border,
                            size: 18,
                            color: Colors.amber,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _DateItem(icon: Icons.login, text: widget.book.startDate),
                      const Spacer(),
                      _DateItem(icon: Icons.logout, text: widget.book.endDate),
                    ],
                  ),
                  const Divider(height: 28),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isActionLoading)
                        const Center(child: CircularProgressIndicator())
                      else ...[
                        TextButton(
                          onPressed: () async {
                            if (widget.book.apartment.ownerId != null) {
                              Chat chat = await ChatApiService.getChat(
                                widget.book.apartment.ownerId!,
                              );
                              try {
                                // After getting the chat, push the ChatScreen with the appropriate chat data
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => ChatScreen(
                                      chatId: chat
                                          .id, // Assuming Chat has an `id` field
                                      receiverId: chat
                                          .receiverId, // Assuming Chat has `receiverId` field
                                    ),
                                  ),
                                );
                              } catch (e) {
                                // Handle error (e.g., network error, chat creation failure)
                                log("Error fetching or creating chat: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Error creating or fetching chat.',
                                    ),
                                  ),
                                );
                              }
                            } else {
                              // Handle the case where ownerId is null
                              log("Owner ID is null, cannot initiate chat.");
                            }
                          },
                          child: Text("chat"),
                        ),
                        const SizedBox(height: 8),

                        TextButton.icon(
                          onPressed: canEdit ? _handleEdit : null,
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                        ),
                        const SizedBox(height: 8),

                        OutlinedButton.icon(
                          onPressed: canRate ? _handleRate : null,
                          icon: const Icon(Icons.star_outline, size: 18),
                          label: const Text('Rate'),
                        ),
                        const SizedBox(height: 8),

                        ElevatedButton(
                          onPressed: canPay ? _handlePay : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canPay
                                ? Colors.blue
                                : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Pay Now'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingDetailsScreen(booking: widget.book),
      ),
    ).then((_) => widget.onUpdate?.call());
  }

  void _handleRate() async {
    final selectedRating = await showDialog<int>(
      context: context,
      builder: (_) => const RatingDialog(),
    );

    if (selectedRating != null && selectedRating > 0) {
      setState(() => _isActionLoading = true);
      bool success = await RateBookingService.rateBooking(
        context: context,
        bookingId: widget.book.id.toString(),
        rating: selectedRating.toDouble(),
      );

      if (success && mounted) {
        if (widget.onUpdate != null) {
          widget.onUpdate!();
        }
      }
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  void _handlePay() async {
    setState(() => _isActionLoading = true);

    bool success = await PayBookingService.payBooking(
      context: context,
      bookingId: widget.book.id.toString(),
    );

    if (success && mounted) {
      if (widget.onUpdate != null) {
        widget.onUpdate!();
      }
    } else {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DateItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DateItem({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
