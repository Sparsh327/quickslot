import '../../domain/repositories/booking_repository.dart';
import '../data_sources/remote/api_client.dart';
import '../models/booking_model.dart';
import '../../values/network_constants.dart';

class BookingRepositoryImpl implements BookingRepository {
  final ApiClient _api;
  const BookingRepositoryImpl(this._api);

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    final response = await _api.get(NetworkConstants.userBookings(userId));
    final body = response.data['data'] as Map<String, dynamic>;
    final list = body['bookings'] as List<dynamic>;
    return list.map((e) => BookingModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> createBooking(String slotId) async {
    await _api.post(NetworkConstants.bookings, data: {'slotId': slotId});
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await _api.delete(NetworkConstants.bookingById(bookingId));
  }
}
