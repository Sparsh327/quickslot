import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injection_container.dart';
import '../presentation/auth/cubit/auth_cubit.dart';
import '../presentation/auth/screens/user_select_screen.dart';
import '../presentation/my_bookings/cubit/my_bookings_cubit.dart';
import '../presentation/my_bookings/screens/my_bookings_screen.dart';
import '../presentation/venue_detail/cubit/venue_detail_cubit.dart';
import '../presentation/venue_detail/screens/venue_detail_screen.dart';
import '../presentation/venues/cubit/venues_cubit.dart';
import '../presentation/venues/screens/venue_list_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.userSelect,
    routes: [
      GoRoute(
        path: AppRoutes.userSelect,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<AuthCubit>()..loadUsers(),
          child: const UserSelectScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.venues,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<VenuesCubit>()..loadVenues(),
          child: const VenueListScreen(),
        ),
      ),
      GoRoute(
        path: '/venues/:venueId',
        builder: (context, state) {
          final venueId = state.pathParameters['venueId']!;
          return BlocProvider(
            create: (_) => getIt<VenueDetailCubit>(),
            child: VenueDetailScreen(venueId: venueId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.myBookings,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<MyBookingsCubit>()..loadBookings(),
          child: const MyBookingsScreen(),
        ),
      ),
    ],
  );
}
