// lib/core/utils/bottom_drawer.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

void showBottomDrawer({
  required BuildContext context,
  required String placeName,
  required String imageUrl,
  required bool isDirectionLoading,
  required LatLng? selectedPlaceLocation,
  required Function(bool) setLoading,
  required Function(LatLng) showDirections,
}) {
  if (placeName == 'Your Location') {
    return;
  }
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SizedBox(
            height: 300,
            width: double.infinity,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    placeName,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                          vertical: 10.0
                      ),
                      child: Row(
                        children: [
                          Image.network(
                            imageUrl,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (selectedPlaceLocation != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: isDirectionLoading ? null : () async {
                        setState(() {
                          setLoading(true);
                        });
                        await showDirections(selectedPlaceLocation);
                        setState(() {
                          setLoading(false);
                        });
                      },
                      child: isDirectionLoading
                          ? const Text('Loading Directions...')
                          : const Text('Show Directions'),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}