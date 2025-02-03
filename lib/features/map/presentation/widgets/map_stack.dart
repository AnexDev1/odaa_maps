// lib/features/map/presentation/widgets/map_stack.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/custom_marker.dart';
import '../../../../providers/map_provider.dart';
import '../../../../data/model/place_model.dart';

class MapStack extends StatefulWidget {
  final MapController mapController;
  final List<Place> places;
  final List<LatLng> routePoints;
  final bool isLocationLoading;
  final String? locationError;
  final Function(LatLng) onMarkerTap;

  const MapStack({
    required this.mapController,
    required this.places,
    required this.routePoints,
    required this.isLocationLoading,
    required this.locationError,
    required this.onMarkerTap,
    super.key,
  });

  @override
  _MapStackState createState() => _MapStackState();
}

class _MapStackState extends State<MapStack> {
  final TextEditingController _destinationController = TextEditingController();
  List<Place> _filteredPlaces = [];

  @override
  void initState() {
    super.initState();
    _destinationController.addListener(_filterPlaces);
  }

  void _filterPlaces() {
    final query = _destinationController.text.toLowerCase();
    if (query.isNotEmpty) {
      setState(() {
        _filteredPlaces = widget.places.where((place) {
          return place.name.toLowerCase().contains(query);
        }).toList();
      });
    } else {
      setState(() {
        _filteredPlaces.clear();
      });
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: const LatLng(7.6735, 36.8340),
            initialZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/satellite-streets-v12/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiYW5leGRldiIsImEiOiJjbHp6YzZ1ZzQxOHh0Mm1zYW5oNmdhZHRkIn0.EXzK4hcp09SCCv2e0bwXsg',
            ),
            MarkerLayer(
              markers: widget.places.map((place) {
                return Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(place.lat, place.lng),
                  child: CustomMarker(
                    position: LatLng(place.lat, place.lng),
                    color: Colors.blue, // Customize the color as needed
                    label: place.name,
                    onTap: () => widget.onMarkerTap(LatLng(place.lat, place.lng)),
                  ),
                );
              }).toList(),
            ),
            if (widget.routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routePoints,
                    color: Colors.blue,
                    strokeWidth: 4.0,
                  ),
                ],
              ),
          ],
        ),
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Column(
            children: [
              TextField(
                controller: _destinationController,
                decoration: InputDecoration(
                  hintText: 'Enter Destination',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (_filteredPlaces.isNotEmpty)
                Container(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: Column(
                    children: _filteredPlaces.map((place) {
                      return Container(
                        color: Colors.grey[200],
                        child: ListTile(
                          title: Text(
                            place.name,
                            style: TextStyle(color: Colors.black),
                          ),
                          onTap: () {
                            _destinationController.text = place.name;
                            setState(() {
                              _filteredPlaces.clear();
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
        if (widget.isLocationLoading)
          const Center(child: CircularProgressIndicator()),
        if (widget.locationError != null)
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Material(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          widget.locationError!,
                          style: const TextStyle(color: Colors.white)
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => {},
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}