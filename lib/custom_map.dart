import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_map_caching/flutter_map_tile_caching.dart'; // For tile caching

class CustomMap extends StatelessWidget {
  final MapController mapController = MapController();
  static const LatLng jimmaCenter = LatLng(7.6735, 36.8340);

  final List<Map<String, dynamic>> locations = [
    {
      'name': 'Jimma University',
      'position': LatLng(7.6667, 36.8333),
      'color': Colors.blue,
    },
    {
      'name': 'Jimma Museum',
      'position': jimmaCenter,
      'color': Colors.red,
    },
  ];

  CustomMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Map of Jimma, Oromia'),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: jimmaCenter,
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            // tileProvider: CachedTileProvider(), // Enable caching
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.jimma_map',
          ),
          MarkerLayer(
            markers: locations.map((location) {
              return Marker(
                width: 40.0,
                height: 40.0,
                point: location['position'],
                child: Icon(
                  Icons.location_on,
                  color: location['color'],
                  size: 40.0,
                ),
              );
            }).toList(),
          ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.my_location),
        onPressed: () => mapController.move(jimmaCenter, 13.0),
      ),
    );
  }
}