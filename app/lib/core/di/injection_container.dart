import 'package:get_it/get_it.dart';

import '../../core/services/user_session.dart';
import '../../data/data_sources/remote/api_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../data/repositories/venue_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/venue_repository.dart';
import '../../presentation/auth/cubit/auth_cubit.dart';
import '../../presentation/my_bookings/cubit/my_bookings_cubit.dart';
import '../../presentation/venue_detail/cubit/venue_detail_cubit.dart';
import '../../presentation/venues/cubit/venues_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  // Session
  getIt.registerLazySingleton<UserSession>(() => UserSession());

  // Network
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt()));

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt()));
  getIt.registerLazySingleton<VenueRepository>(
      () => VenueRepositoryImpl(getIt()));
  getIt.registerLazySingleton<BookingRepository>(
      () => BookingRepositoryImpl(getIt()));

  // Cubits (factories — fresh instance per screen)
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt()));
  getIt.registerFactory<VenuesCubit>(() => VenuesCubit(getIt()));
  getIt.registerFactory<VenueDetailCubit>(
      () => VenueDetailCubit(getIt(), getIt()));
  getIt.registerFactory<MyBookingsCubit>(
      () => MyBookingsCubit(getIt(), getIt()));
}
