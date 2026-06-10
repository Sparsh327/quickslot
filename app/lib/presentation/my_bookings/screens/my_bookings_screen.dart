import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/presentation/screen_state.dart';
import '../../../data/models/booking_model.dart';
import '../cubit/my_bookings_cubit.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Bookings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: BlocBuilder<MyBookingsCubit, ScreenState<List<BookingModel>>>(
        builder: (context, state) {
          if (state.isLoading || state.isInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Failed to load bookings'),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<MyBookingsCubit>().loadBookings(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final bookings = state.data ?? [];
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 64.sp, color: Colors.grey[300]),
                  SizedBox(height: 16.h),
                  Text(
                    'No bookings yet',
                    style:
                        TextStyle(fontSize: 16.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: bookings.length,
            itemBuilder: (_, i) => _BookingCard(
              booking: bookings[i],
              onCancel: () => _confirmCancel(context, bookings[i]),
            ),
          );
        },
      ),
    );
  }

  void _confirmCancel(BuildContext context, BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
          'Cancel ${booking.slot.startTime}–${booking.slot.endTime} at ${booking.slot.venue.name}?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MyBookingsCubit>().cancelBooking(booking.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onCancel;
  const _BookingCard({required this.booking, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final slot = booking.slot;
    final date = DateTime.tryParse(slot.date);
    final displayDate =
        date != null ? DateFormat('EEE, MMM d').format(date) : slot.date;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDFF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.sports_tennis,
                color: const Color(0xFF6C63FF), size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.venue.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$displayDate · ${slot.startTime}–${slot.endTime}',
                  style:
                      TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Cancel',
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}
