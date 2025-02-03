// lib/core/widgets/custom_expansion_tile.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../../data/model/place_model.dart';

class CustomExpansionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Place> places;
  final Function(LatLng, String, String) onTap;

  const CustomExpansionTile({
    required this.icon,
    required this.title,
    required this.places,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title),
        children: places.map((place) {
          return ListTile(
            title: Text(place.name),
            onTap: () {
              Navigator.pop(context);
              onTap(LatLng(place.lat, place.lng), place.name, place.imageUrl);
            },
          );
        }).toList(),
      ),
    );
  }
}