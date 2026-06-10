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
      backgroundColor: const Color(0xFFF0F2F8),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(8.w, 50.h, 24.w, 20.h),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C63FF), Color(0xFF9747FF)],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'My Bookings',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                BlocBuilder<MyBookingsCubit, ScreenState<List<BookingModel>>>(
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
                        Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEDFF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.calendar_today_outlined,
                              size: 48.sp,
                              color: const Color(0xFF6C63FF)),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'No bookings yet',
                          style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A2E)),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Book a slot to see it here',
                          style: TextStyle(
                              fontSize: 13.sp, color: Colors.grey[500]),
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
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context, BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('Cancel Booking'),
        content: Text(
          'Cancel ${booking.slot.startTime}–${booking.slot.endTime} at ${booking.slot.venue.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MyBookingsCubit>().cancelBooking(booking.id);
            },
            child: const Text('Cancel Booking',
                style: TextStyle(color: Colors.white)),
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
    final isBadminton = slot.venue.sport == 'Badminton';
    final sportColor =
        isBadminton ? const Color(0xFF2980B9) : const Color(0xFF27AE60);
    final sportIcon =
        isBadminton ? Icons.sports_tennis : Icons.sports_soccer;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: sportColor.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: sportColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                bottomLeft: Radius.circular(18.r),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: sportColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(sportIcon, color: sportColor, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.venue.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: const Color(0xFF1A1A2E)),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$displayDate  •  ${slot.startTime}–${slot.endTime}',
                  style:
                      TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[400]),
            tooltip: 'Cancel',
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}
