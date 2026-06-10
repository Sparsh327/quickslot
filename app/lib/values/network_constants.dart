class NetworkConstants {
  static const String baseUrl = 'https://quickslot-58qg.onrender.com';

  static const String users = '/users';
  static const String venues = '/venues';
  static String venueSlots(String id) => '/venues/$id/slots';
  static const String bookings = '/bookings';
  static String userBookings(String id) => '/users/$id/bookings';
  static String bookingById(String id) => '/bookings/$id';
}
