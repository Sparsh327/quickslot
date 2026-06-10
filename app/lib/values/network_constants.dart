class NetworkConstants {
  // Android emulator → host machine localhost.
  // Change to your machine's LAN IP when testing on a physical device.
  static const String baseUrl = 'http://10.0.2.2:3000';

  static const String users = '/users';
  static const String venues = '/venues';
  static String venueSlots(String id) => '/venues/$id/slots';
  static const String bookings = '/bookings';
  static String userBookings(String id) => '/users/$id/bookings';
  static String bookingById(String id) => '/bookings/$id';
}
