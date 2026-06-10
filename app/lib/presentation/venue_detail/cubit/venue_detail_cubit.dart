import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../../core/presentation/screen_state.dart';
import '../../../data/models/slot_model.dart';
import '../../../data/models/venue_model.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../domain/repositories/venue_repository.dart';

class VenueDetailState extends Equatable {
  final ScreenStatus status;
  final VenueModel? venue;
  final List<SlotModel> slots;
  final String selectedDate;
  final String? errorMessage;

  // Booking sub-state
  final bool isBooking;
  final String? bookingError;   // non-null → show error snackbar
  final bool bookingSuccess;    // true → show success snackbar (reset after read)

  const VenueDetailState({
    this.status = ScreenStatus.initial,
    this.venue,
    this.slots = const [],
    required this.selectedDate,
    this.errorMessage,
    this.isBooking = false,
    this.bookingError,
    this.bookingSuccess = false,
  });

  VenueDetailState copyWith({
    ScreenStatus? status,
    VenueModel? venue,
    List<SlotModel>? slots,
    String? selectedDate,
    String? errorMessage,
    bool? isBooking,
    String? bookingError,
    bool? bookingSuccess,
    bool clearBookingError = false,
  }) {
    return VenueDetailState(
      status: status ?? this.status,
      venue: venue ?? this.venue,
      slots: slots ?? this.slots,
      selectedDate: selectedDate ?? this.selectedDate,
      errorMessage: errorMessage ?? this.errorMessage,
      isBooking: isBooking ?? this.isBooking,
      bookingError: clearBookingError ? null : bookingError ?? this.bookingError,
      bookingSuccess: bookingSuccess ?? this.bookingSuccess,
    );
  }

  @override
  List<Object?> get props => [
        status, venue, slots, selectedDate, errorMessage,
        isBooking, bookingError, bookingSuccess,
      ];
}

class VenueDetailCubit extends Cubit<VenueDetailState> {
  final VenueRepository _venueRepo;
  final BookingRepository _bookingRepo;

  VenueDetailCubit(this._venueRepo, this._bookingRepo)
      : super(VenueDetailState(selectedDate: _todayString()));

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadSlots(String venueId, String date) async {
    emit(state.copyWith(status: ScreenStatus.loading, selectedDate: date));
    try {
      final result = await _venueRepo.getVenueSlots(venueId, date);
      emit(state.copyWith(
        status: ScreenStatus.success,
        venue: result.venue,
        slots: result.slots,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ScreenStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void selectDate(String venueId, String date) => loadSlots(venueId, date);

  Future<void> bookSlot(String venueId, String slotId) async {
    emit(state.copyWith(isBooking: true, clearBookingError: true, bookingSuccess: false));
    try {
      await _bookingRepo.createBooking(slotId);
      emit(state.copyWith(isBooking: false, bookingSuccess: true));
      // Refresh slot grid to reflect new BOOKED status
      await loadSlots(venueId, state.selectedDate);
    } on ConflictFailure catch (e) {
      emit(state.copyWith(isBooking: false, bookingError: e.message));
      await loadSlots(venueId, state.selectedDate);
    } catch (e) {
      emit(state.copyWith(isBooking: false, bookingError: e.toString()));
    }
  }

  void clearBookingResult() {
    emit(state.copyWith(clearBookingError: true, bookingSuccess: false));
  }
}
