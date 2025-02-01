// lib/data/model/place_model.dart

import 'package:hive/hive.dart';

part 'place_model.g.dart';

@HiveType(typeId: 1)
class Place {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String category;
  @HiveField(2)
  final double lat;
  @HiveField(3)
  final double lng;
  @HiveField(4)
  final String imageUrl;

  Place({
    required this.name,
    required this.category,
    required this.lat,
    required this.lng,
    required this.imageUrl,
  });
}