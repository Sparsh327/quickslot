import '../../data/models/booking_model.dart';

abstract class BookingRepository {
  Future<List<BookingModel>> getUserBookings(String userId);
  Future<void> createBooking(String slotId);
  Future<void> cancelBooking(String bookingId);
}
