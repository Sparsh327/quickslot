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
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Slot booked successfully!'),
                ],
              ),
              backgroundColor: const Color(0xFF27AE60),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          context.read<VenueDetailCubit>().clearBookingResult();
        }
        if (state.bookingError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(state.bookingError!),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          context.read<VenueDetailCubit>().clearBookingResult();
        }
      },
      builder: (context, state) {
        final isBadminton = state.venue?.sport == 'Badminton';
        final sportColor =
            isBadminton ? const Color(0xFF2980B9) : const Color(0xFF27AE60);
        final sportColorLight =
            isBadminton ? const Color(0xFF5DADE2) : const Color(0xFF2ECC71);

        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F8),
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 50.h, 0, 0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [sportColor, sportColorLight],
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.venue?.name ?? 'Slots',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                    color: Colors.white,
                                  ),
                                ),
                                if (state.venue != null)
                                  Text(
                                    state.venue!.sport,
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.white
                                            .withValues(alpha: 0.8)),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _DateRow(
                      dates: _dates,
                      selected: _selected,
                      onTap: _onDateTap,
                      activeColor: sportColor,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _SlotsBody(
                  state: state,
                  venueId: widget.venueId,
                  accentColor: sportColor,
                ),
              ),
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
  final Color activeColor;

  const _DateRow({
    required this.dates,
    required this.selected,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
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
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isToday ? 'Today' : DateFormat('EEE').format(d),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isSelected
                          ? activeColor
                          : Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? activeColor : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SlotsBody extends StatelessWidget {
  final VenueDetailState state;
  final String venueId;
  final Color accentColor;

  const _SlotsBody({
    required this.state,
    required this.venueId,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (state.status == ScreenStatus.loading || state.isBooking) {
      return Center(
        child: CircularProgressIndicator(color: accentColor),
      );
    }
    if (state.status == ScreenStatus.failure) {
      return Center(
          child: Text(state.errorMessage ?? 'Failed to load slots'));
    }
    if (state.slots.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 56.sp,
                color: Colors.grey[300]),
            SizedBox(height: 12.h),
            Text('No slots for this date',
                style:
                    TextStyle(fontSize: 15.sp, color: Colors.grey[500])),
          ],
        ),
      );
    }

    final available =
        state.slots.where((s) => s.isAvailable).length;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
          child: Row(
            children: [
              Text(
                'Available Slots',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '$available open',
                  style: TextStyle(
                      fontSize: 11.sp,
                      color: accentColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
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
              accentColor: accentColor,
              onTap: () =>
                  _confirmBooking(context, state.slots[i], venueId),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmBooking(
      BuildContext context, SlotModel slot, String venueId) {
    if (!slot.isAvailable) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)),
        title: const Text('Confirm Booking'),
        content: Text('Book ${slot.startTime} – ${slot.endTime}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<VenueDetailCubit>().bookSlot(venueId, slot.id);
            },
            child:
                const Text('Book', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  final SlotModel slot;
  final VoidCallback onTap;
  final Color accentColor;

  const _SlotChip({
    required this.slot,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final available = slot.isAvailable;
    return GestureDetector(
      onTap: available ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: available
              ? LinearGradient(
                  colors: [accentColor, accentColor.withValues(alpha: 0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: available ? null : Colors.grey[200],
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: available
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            slot.startTime,
            style: TextStyle(
              fontSize: 12.sp,
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
