import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/booking_model.dart';
import '../../../../data/models/review_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/reviews_provider.dart';

class AddReviewDialog extends ConsumerStatefulWidget {
  final BookingModel booking;

  const AddReviewDialog({super.key, required this.booking});

  @override
  ConsumerState<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends ConsumerState<AddReviewDialog> {
  double _rating = 5.0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tafadhali andika maoni yako mafupi.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final user = ref.read(currentUserProvider);

    final review = ReviewModel(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      bookingId: widget.booking.id,
      listingId: widget.booking.listingId,
      renterId: user?.id ?? widget.booking.renterId,
      renterName: user?.name ?? widget.booking.renterName,
      ownerId: widget.booking.ownerId,
      rating: _rating,
      comment: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    ref.read(reviewsProvider.notifier).addReview(review);

    setState(() => _isSubmitting = false);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Asante sana! Maoni yako yamewasilishwa.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          const Icon(Icons.rate_review, color: AppColors.primary, size: 36),
          const SizedBox(height: 8),
          const Text(
            'Toa Maoni & Ukadiriaji',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            widget.booking.listingTitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ulikiridhika vipi na kifaa hiki?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),

            // Interactive Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  onPressed: () {
                    setState(() => _rating = starIndex.toDouble());
                  },
                  icon: Icon(
                    starIndex <= _rating ? Icons.star : Icons.star_border,
                    color: AppColors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
            Text(
              '${_rating.toInt()} kati ya 5 Stars',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.amber,
              ),
            ),

            const SizedBox(height: 16),

            // Comment text field
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Andika jinsi kifaa kilivyofanya kazi, ubora wake n.k.',
                hintStyle: const TextStyle(fontSize: 13),
                filled: true,
                fillColor: AppColors.surfaceSubtle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Baadaye'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Wasilisha'),
        ),
      ],
    );
  }
}
