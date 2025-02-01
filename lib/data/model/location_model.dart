import 'package:hive/hive.dart';

part 'location_model.g.dart';

@HiveType(typeId: 0)
class LocationModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final double lat;
  @HiveField(3)
  final double lng;
  @HiveField(4)
  final int color;

  LocationModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.color,
  });
}