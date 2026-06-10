import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/screen_state.dart';
import '../../../core/services/user_session.dart';
import '../../../data/models/booking_model.dart';
import '../../../domain/repositories/booking_repository.dart';

class MyBookingsCubit extends Cubit<ScreenState<List<BookingModel>>> {
  final BookingRepository _repo;
  final UserSession _session;

  MyBookingsCubit(this._repo, this._session) : super(const ScreenState());

  Future<void> loadBookings() async {
    final uid = _session.userId;
    if (uid == null) return;
    emit(const ScreenState(status: ScreenStatus.loading));
    try {
      final bookings = await _repo.getUserBookings(uid);
      emit(ScreenState(status: ScreenStatus.success, data: bookings));
    } catch (e) {
      emit(ScreenState(status: ScreenStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _repo.cancelBooking(bookingId);
      await loadBookings();
    } catch (e) {
      emit(ScreenState(status: ScreenStatus.failure, errorMessage: e.toString()));
    }
  }
}
