import 'package:hive/hive.dart';

import '../model/location_model.dart';

class LocationRepository {
  final Box<LocationModel> _box;

  LocationRepository(this._box);

  List<LocationModel> getLocations() => _box.values.toList();

  Future<void> addLocation(LocationModel location) async {
    await _box.put(location.id, location);
  }

  Future<void> removeLocation(String id) async {
    await _box.delete(id);
  }
}