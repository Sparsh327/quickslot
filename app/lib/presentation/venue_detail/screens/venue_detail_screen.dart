import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/presentation/screen_state.dart';
import '../../../data/models/slot_model.dart';
import '../cubit/venue_detail_cubit.dart';

class VenueDetailScreen extends StatefulWidget {
  final String venueId;
  const VenueDetailScreen({super.key, required this.venueId});

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  late final List<DateTime> _dates;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _dates = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
    _selected = _dates.first;
    context
        .read<VenueDetailCubit>()
        .loadSlots(widget.venueId, _fmt(_selected));
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _onDateTap(DateTime date) {
    setState(() => _selected = date);
    context.read<VenueDetailCubit>().selectDate(widget.venueId, _fmt(date));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VenueDetailCubit, VenueDetailState>(
      listenWhen: (prev, curr) =>
          curr.bookingSuccess != prev.bookingSuccess ||
          curr.bookingError != prev.bookingError,
      listener: (context, state) {
        if (state.bookingSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Slot booked successfully!'),
              backgroundColor: Color(0xFF27AE60),
            ),
          );
          context.read<VenueDetailCubit>().clearBookingResult();
        }
        if (state.bookingError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.bookingError!),
              backgroundColor: Colors.red,
            ),
          );
          context.read<VenueDetailCubit>().clearBookingResult();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.venue?.name ?? 'Slots',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                if (state.venue != null)
                  Text(
                    state.venue!.sport,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          body: Column(
            children: [
              _DateRow(
                dates: _dates,
                selected: _selected,
                onTap: _onDateTap,
              ),
              Expanded(child: _SlotsBody(state: state, venueId: widget.venueId)),
            ],
          ),
        );
      },
    );
  }
}

class _DateRow extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime selected;
  final ValueChanged<DateTime> onTap;
  const _DateRow(
      {required this.dates, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: SizedBox(
        height: 64.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: dates.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (_, i) {
            final d = dates[i];
            final isSelected = d.day == selected.day &&
                d.month == selected.month &&
                d.year == selected.year;
            final isToday = d.day == DateTime.now().day &&
                d.month == DateTime.now().month;
            return GestureDetector(
              onTap: () => onTap(d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52.w,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6C63FF)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isToday ? 'Today' : DateFormat('EEE').format(d),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isSelected ? Colors.white70 : Colors.grey[500],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${d.day}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SlotsBody extends StatelessWidget {
  final VenueDetailState state;
  final String venueId;
  const _SlotsBody({required this.state, required this.venueId});

  @override
  Widget build(BuildContext context) {
    if (state.status == ScreenStatus.loading || state.isBooking) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == ScreenStatus.failure) {
      return Center(child: Text(state.errorMessage ?? 'Failed to load slots'));
    }
    if (state.slots.isEmpty) {
      return const Center(child: Text('No slots for this date'));
    }
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 2.2,
      ),
      itemCount: state.slots.length,
      itemBuilder: (_, i) => _SlotChip(
        slot: state.slots[i],
        onTap: () => _confirmBooking(context, state.slots[i], venueId),
      ),
    );
  }

  void _confirmBooking(
      BuildContext context, SlotModel slot, String venueId) {
    if (!slot.isAvailable) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Text('Book ${slot.startTime} – ${slot.endTime}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF)),
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<VenueDetailCubit>()
                  .bookSlot(venueId, slot.id);
            },
            child: const Text('Book', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  final SlotModel slot;
  final VoidCallback onTap;
  const _SlotChip({required this.slot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final available = slot.isAvailable;
    return GestureDetector(
      onTap: available ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: available ? const Color(0xFF6C63FF) : Colors.grey[200],
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            slot.startTime,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: available ? Colors.white : Colors.grey[400],
              decoration: available ? null : TextDecoration.lineThrough,
            ),
          ),
        ),
      ),
    );
  }
}
