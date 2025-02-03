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
      return _BottomSheetContent(
        placeName: placeName,
        imageUrl: imageUrl,
        isDirectionLoading: isDirectionLoading,
        selectedPlaceLocation: selectedPlaceLocation,
        setLoading: setLoading,
        showDirections: showDirections,
      );
    },
  );
}

class _BottomSheetContent extends StatefulWidget {
  final String placeName;
  final String imageUrl;
  final bool isDirectionLoading;
  final LatLng? selectedPlaceLocation;
  final Function(bool) setLoading;
  final Function(LatLng) showDirections;

  const _BottomSheetContent({
    required this.placeName,
    required this.imageUrl,
    required this.isDirectionLoading,
    required this.selectedPlaceLocation,
    required this.setLoading,
    required this.showDirections,
  });

  @override
  __BottomSheetContentState createState() => __BottomSheetContentState();
}

class __BottomSheetContentState extends State<_BottomSheetContent> {
  late bool isDirectionLoading;

  @override
  void initState() {
    super.initState();
    isDirectionLoading = widget.isDirectionLoading;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.placeName,
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
                      widget.imageUrl,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.selectedPlaceLocation != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: isDirectionLoading ? null : () async {
                  setState(() {
                    isDirectionLoading = true;
                  });
                  await widget.showDirections(widget.selectedPlaceLocation!);
                  setState(() {
                    isDirectionLoading = false;
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
  }
}