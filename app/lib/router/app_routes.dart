class AppRoutes {
  static const String userSelect = '/';
  static const String venues = '/venues';
  static const String myBookings = '/my-bookings';

  static String venueDetail(String venueId) => '/venues/$venueId';
}
