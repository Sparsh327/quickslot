import '../../data/models/slot_model.dart';
import '../../data/models/venue_model.dart';

abstract class VenueRepository {
  Future<List<VenueModel>> getVenues();
  Future<({VenueModel venue, List<SlotModel> slots})> getVenueSlots(
    String venueId,
    String date,
  );
}
