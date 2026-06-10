import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/screen_state.dart';
import '../../../data/models/venue_model.dart';
import '../../../domain/repositories/venue_repository.dart';

class VenuesCubit extends Cubit<ScreenState<List<VenueModel>>> {
  final VenueRepository _repo;

  VenuesCubit(this._repo) : super(const ScreenState());

  Future<void> loadVenues() async {
    emit(const ScreenState(status: ScreenStatus.loading));
    try {
      final venues = await _repo.getVenues();
      emit(ScreenState(status: ScreenStatus.success, data: venues));
    } catch (e) {
      emit(ScreenState(status: ScreenStatus.failure, errorMessage: e.toString()));
    }
  }
}
