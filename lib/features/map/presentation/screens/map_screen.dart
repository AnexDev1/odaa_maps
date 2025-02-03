import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/utils/map_utils.dart';
import '../../../../core/widgets/custom_expansion_tile.dart';
import '../../../../data/model/place_model.dart';
import '../../../../providers/location_provider.dart';
import '../../../../providers/map_provider.dart';
import '../widgets/location_bottom_sheet.dart';
import '../widgets/map_stack.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  bool _isLocationLoading = false;
  bool _isDirectionLoading = false;
  String? _locationError;
  LatLng? _selectedPlaceLocation;
  List<LatLng> _routePoints = [];

  final List<Map<String, dynamic>> categories = [
    {
      'icon': Icons.local_cafe,
      'title': 'Cafes',
      'filter': (Place place) => place.category == 'Cafes',
    },
    {
      'icon': Icons.restaurant,
      'title': 'Restaurants',
      'filter': (Place place) => place.category == 'Restaurants',
    },
    {
      'icon': Icons.local_hospital,
      'title': 'Hospitals',
      'filter': (Place place) => place.category == 'Hospitals',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserLocation(
        context: context,
        setLoading: (loading) => setState(() => _isLocationLoading = loading),
        setError: (error) => setState(() => _locationError = error),
        moveMap: (location) {
          final mapController = ref.read(mapControllerProvider);
          mapController.move(location, 18.0);
        },
        addPlace: (place) {
          final locationsNotifier = ref.read(locationsProvider.notifier);
          locationsNotifier.addPlace(place);
        },
        updatePlace: (place) {
          final locationsNotifier = ref.read(locationsProvider.notifier);
          locationsNotifier.updatePlace(place);
        },
        mounted: mounted,
      );
    });
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
            ...categories.map((category) {
              return CustomExpansionTile(
                icon: category['icon'],
                title: category['title'],
                places: places.where(category['filter']).toList(),
                onTap: (location, name, imageUrl) {
                  _selectedPlaceLocation = location;
                  mapController.move(_selectedPlaceLocation!, 18.0);
                  showBottomDrawer(
                    context: context,
                    placeName: name,
                    imageUrl: imageUrl,
                    isDirectionLoading: _isDirectionLoading,
                    selectedPlaceLocation: _selectedPlaceLocation,
                    setLoading: (loading) => setState(() => _isDirectionLoading = loading),
                    showDirections: (destination) => showDirections(
                      destination: destination,
                      setLoading: (loading) => setState(() => _isDirectionLoading = loading),
                      setError: (error) => setState(() => _locationError = error),
                      setRoutePoints: (points) => setState(() => _routePoints = points),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
      body: MapStack(
        mapController: mapController,
        places: places,
        routePoints: _routePoints,
        isLocationLoading: _isLocationLoading,
        locationError: _locationError,
        onMarkerTap: (location) {
          _selectedPlaceLocation = location;
          showBottomDrawer(
            context: context,
            placeName: places.firstWhere((place) => place.lat == location.latitude && place.lng == location.longitude).name,
            imageUrl: places.firstWhere((place) => place.lat == location.latitude && place.lng == location.longitude).imageUrl,
            isDirectionLoading: _isDirectionLoading,
            selectedPlaceLocation: _selectedPlaceLocation,
            setLoading: (loading) => setState(() => _isDirectionLoading = loading),
            showDirections: (destination) => showDirections(
              destination: destination,
              setLoading: (loading) => setState(() => _isDirectionLoading = loading),
              setError: (error) => setState(() => _locationError = error),
              setRoutePoints: (points) => setState(() => _routePoints = points),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => fetchUserLocation(
          context: context,
          setLoading: (loading) => setState(() => _isLocationLoading = loading),
          setError: (error) => setState(() => _locationError = error),
          moveMap: (location) {
            final mapController = ref.read(mapControllerProvider);
            mapController.move(location, 18.0);
          },
          addPlace: (place) {
            final locationsNotifier = ref.read(locationsProvider.notifier);
            locationsNotifier.addPlace(place);
          },
          updatePlace: (place) {
            final locationsNotifier = ref.read(locationsProvider.notifier);
            locationsNotifier.updatePlace(place);
          },
          mounted: mounted,
        ),
        child: const Icon(Icons.my_location),
      ),
    );
  }
}