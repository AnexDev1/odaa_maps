import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/model/place_model.dart';
import '../data/initial_data.dart';

final locationsProvider = StateNotifierProvider<LocationsNotifier, List<Place>>((ref) {
  return LocationsNotifier();
});

class LocationsNotifier extends StateNotifier<List<Place>> {
  LocationsNotifier() : super(initialPlaces);

  void addPlace(Place place) {
    state = [...state, place];
  }

  void updatePlace(Place place) {
    state = [
      for (final p in state)
        if (p.name == place.name) place else p,
    ];
  }
}