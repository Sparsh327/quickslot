import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/screen_state.dart';
import '../../../core/services/user_session.dart';
import '../../../core/di/injection_container.dart';
import '../../../data/models/venue_model.dart';
import '../cubit/venues_cubit.dart';
import '../../../router/app_routes.dart';

class VenueListScreen extends StatelessWidget {
  const VenueListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = getIt<UserSession>().userName ?? '';
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QuickSlot',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            Text(
              'Hi, $userName',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined,
                color: Color(0xFF6C63FF)),
            tooltip: 'My Bookings',
            onPressed: () => context.push(AppRoutes.myBookings),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: BlocBuilder<VenuesCubit, ScreenState<List<VenueModel>>>(
        builder: (context, state) {
          if (state.isLoading || state.isInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 12.h),
                  Text(state.errorMessage ?? 'Failed to load venues'),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () => context.read<VenuesCubit>().loadVenues(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final venues = state.data ?? [];
          if (venues.isEmpty) {
            return const Center(child: Text('No venues available'));
          }
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: venues.length,
            itemBuilder: (_, i) => _VenueCard(venue: venues[i]),
          );
        },
      ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  final VenueModel venue;
  const _VenueCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    final isBadminton = venue.sport == 'Badminton';
    return GestureDetector(
      onTap: () => context.push(AppRoutes.venueDetail(venue.id)),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    venue.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isBadminton
                        ? const Color(0xFFE8F4FD)
                        : const Color(0xFFE8F8F0),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    venue.sport,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: isBadminton
                          ? const Color(0xFF2980B9)
                          : const Color(0xFF27AE60),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              venue.description,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 14.sp, color: Colors.grey),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    venue.address,
                    style:
                        TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
