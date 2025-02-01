import 'package:hive/hive.dart';

import '../model/location_model.dart';

class HiveBoxes {
  static const String locations = 'locations_box';

  static Future<void> initialize() async {
    await Hive.openBox<LocationModel>(locations);
  }
}