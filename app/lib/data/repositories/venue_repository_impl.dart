import '../../domain/repositories/venue_repository.dart';
import '../data_sources/remote/api_client.dart';
import '../models/slot_model.dart';
import '../models/venue_model.dart';
import '../../values/network_constants.dart';

class VenueRepositoryImpl implements VenueRepository {
  final ApiClient _api;
  const VenueRepositoryImpl(this._api);

  @override
  Future<List<VenueModel>> getVenues() async {
    final response = await _api.get(NetworkConstants.venues);
    final list = response.data['data'] as List<dynamic>;
    return list.map((e) => VenueModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<({VenueModel venue, List<SlotModel> slots})> getVenueSlots(
    String venueId,
    String date,
  ) async {
    final response = await _api.get(
      NetworkConstants.venueSlots(venueId),
      queryParameters: {'date': date},
    );
    final body = response.data['data'] as Map<String, dynamic>;
    final venue = VenueModel.fromJson(body['venue'] as Map<String, dynamic>);
    final slots = (body['slots'] as List<dynamic>)
        .map((e) => SlotModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return (venue: venue, slots: slots);
  }
}
