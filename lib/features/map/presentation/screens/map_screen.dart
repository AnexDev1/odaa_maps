import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../data/model/place_model.dart';
import '../../../../providers/location_provider.dart';
import '../../../../providers/map_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  bool _isLocationLoading = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserLocation();
    });
  }

  Future<void> _fetchUserLocation() async {
    if (!mounted) return;

    setState(() {
      _isLocationLoading = true;
      _locationError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDisabledAlert();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          setState(() => _locationError = 'Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showEnableLocationSettingsDialog();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      final mapController = ref.read(mapControllerProvider);
      mapController.move(
        LatLng(position.latitude, position.longitude),
        18.0,
      );

      final locationsNotifier = ref.read(locationsProvider.notifier);
      final places = ref.read(locationsProvider);
      final userLocationIndex = places.indexWhere((place) => place.name == 'Your Location');

      if (userLocationIndex == -1) {
        locationsNotifier.addPlace(
          Place(
            name: 'Your Location',
            category: 'User',
            lat: position.latitude,
            lng: position.longitude,
            imageUrl: '',
          ),
        );
      } else {
        locationsNotifier.updatePlace(
          Place(
            name: 'Your Location',
            category: 'User',
            lat: position.latitude,
            lng: position.longitude,
            imageUrl: '',
          ),
        );
      }
    } catch (e) {
      setState(() => _locationError = 'Failed to get location: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLocationLoading = false);
      }
    }
  }

  void _showLocationServiceDisabledAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text('Please enable location services to use this feature'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Geolocator.openLocationSettings(),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showEnableLocationSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text('Please enable location permissions in app settings'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Geolocator.openAppSettings(),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showBottomDrawer(BuildContext context, String placeName) {
    if (placeName == 'Your Location') {
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
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
                          'https://randomwordgenerator.com/img/picture-generator/5ee7d540435bb10ff3d8992cc12c30771037dbf85254784a722d73d5944c_640.jpg',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 10),
                        Image.network(
                          'https://randomwordgenerator.com/img/picture-generator/5ee7d540435bb10ff3d8992cc12c30771037dbf85254784a722d73d5944c_640.jpg',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapController = ref.watch(mapControllerProvider);
    final places = ref.watch(locationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Odaa Maps - Jimma'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Categories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: const Icon(Icons.local_cafe),
                title: const Text('Cafes'),
                children: places
                    .where((place) => place.category == 'Cafes')
                    .map((place) => ListTile(
                  title: Text(place.name),
                  onTap: () {
                    Navigator.pop(context);
                    mapController.move(
                      LatLng(place.lat, place.lng),
                      18.0,
                    );
                  },
                ))
                    .toList(),
              ),
            ),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: const Icon(Icons.restaurant),
                title: const Text('Restaurants'),
                children: places
                    .where((place) => place.category == 'Restaurants')
                    .map((place) => ListTile(
                  title: Text(place.name),
                  onTap: () {
                    Navigator.pop(context);
                    mapController.move(
                      LatLng(place.lat, place.lng),
                      18.0,
                    );
                  },
                ))
                    .toList(),
              ),
            ),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: const Icon(Icons.local_hospital),
                title: const Text('Hospitals'),
                children: places
                    .where((place) => place.category == 'Hospitals')
                    .map((place) => ListTile(
                  title: Text(place.name),
                  onTap: () {
                    Navigator.pop(context);
                    mapController.move(
                      LatLng(place.lat, place.lng),
                      18.0,
                    );
                  },
                ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: const LatLng(7.6735, 36.8340),
              initialZoom: 18.0,
              onMapReady: () => _fetchUserLocation(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/satellite-streets-v12/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiYW5leGRldiIsImEiOiJjbHp6YzZ1ZzQxOHh0Mm1zYW5oNmdhZHRkIn0.EXzK4hcp09SCCv2e0bwXsg',
              ),
              MarkerLayer(
                markers: places.map((place) {
                  return Marker(
                    width: 80.0,
                    height: 80.0,
                    point: LatLng(place.lat, place.lng),
                    child: CustomMarker(
                      position: LatLng(place.lat, place.lng),
                      color: Colors.blue, // Customize the color as needed
                      label: place.name,
                      onTap: () => _showBottomDrawer(context, place.name),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          if (_isLocationLoading)
            const Center(child: CircularProgressIndicator()),
          if (_locationError != null)
            Positioned(
              top: 20,
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
                            _locationError!,
                            style: const TextStyle(color: Colors.white)
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() => _locationError = null),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchUserLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

class CustomMarker extends StatelessWidget {
  final LatLng position;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const CustomMarker({
    required this.position,
    required this.color,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            color: color,
            size: 40.0,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}