import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';

final mapControllerProvider = Provider<MapController>((ref) {
  return MapController();
});