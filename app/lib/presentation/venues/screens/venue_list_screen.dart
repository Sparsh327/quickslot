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
      backgroundColor: const Color(0xFFF0F2F8),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(24.w, 56.h, 24.w, 24.h),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C63FF), Color(0xFF9747FF)],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $userName',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Pick a venue and book your slot',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.myBookings),
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(Icons.calendar_today_outlined,
                        color: Colors.white, size: 22.sp),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<VenuesCubit, ScreenState<List<VenueModel>>>(
              builder: (context, state) {
                if (state.isLoading || state.isInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.isFailure) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        SizedBox(height: 12.h),
                        Text(state.errorMessage ?? 'Failed to load venues'),
                        SizedBox(height: 12.h),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<VenuesCubit>().loadVenues(),
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
                  padding:
                      EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
                  itemCount: venues.length,
                  itemBuilder: (_, i) => _VenueCard(venue: venues[i]),
                );
              },
            ),
          ),
        ],
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
    final sportColor =
        isBadminton ? const Color(0xFF2980B9) : const Color(0xFF27AE60);
    final sportColorLight =
        isBadminton ? const Color(0xFF5DADE2) : const Color(0xFF2ECC71);
    final sportIcon =
        isBadminton ? Icons.sports_tennis : Icons.sports_soccer;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.venueDetail(venue.id)),
      child: Container(
        margin: EdgeInsets.only(bottom: 18.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: sportColor.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 72.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [sportColor, sportColorLight],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(width: 20.w),
                  Icon(sportIcon,
                      color: Colors.white.withValues(alpha: 0.25),
                      size: 48.sp),
                  const Spacer(),
                  Container(
                    margin: EdgeInsets.only(right: 16.w),
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      venue.sport,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    venue.description,
                    style: TextStyle(
                        fontSize: 13.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 13.sp, color: Colors.grey[400]),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          venue.address,
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.grey[500]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: sportColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'Book Slot',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: sportColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
}
