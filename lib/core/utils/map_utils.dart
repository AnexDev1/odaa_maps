// lib/core/utils/map_utils.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

import '../../data/model/place_model.dart';
import 'dialogs.dart';

Future<void> fetchUserLocation({
  required BuildContext context,
  required Function(bool) setLoading,
  required Function(String?) setError,
  required Function(LatLng) moveMap,
  required Function(Place) addPlace,
  required Function(Place) updatePlace,
  required bool mounted,
}) async {
  if (!mounted) return;

  setLoading(true);
  setError(null);

  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showLocationServiceDisabledAlert(context);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setError('Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showEnableLocationSettingsDialog(context);
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    moveMap(LatLng(position.latitude, position.longitude));

    final userLocation = Place(
      name: 'Your Location',
      category: 'User',
      lat: position.latitude,
      lng: position.longitude,
      imageUrl: '',
    );

    addPlace(userLocation);
    updatePlace(userLocation);
  } catch (e) {
    setError('Failed to get location: ${e.toString()}');
  } finally {
    if (mounted) {
      setLoading(false);
    }
  }
}

Future<void> showDirections({
  required LatLng destination,
  required Function(bool) setLoading,
  required Function(String?) setError,
  required Function(List<LatLng>) setRoutePoints,
}) async {
  setLoading(true);

  try {
    final currentPosition = await Geolocator.getCurrentPosition();
    final origin = LatLng(currentPosition.latitude, currentPosition.longitude);

    final url = 'http://router.project-osrm.org/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final route = data['routes'][0]['geometry']['coordinates'] as List;
      final points = route.map((point) => LatLng(point[1], point[0])).toList();

      setRoutePoints(points);
    } else {
      setError('Failed to get directions');
    }
  } catch (e) {
    setError('Failed to get directions: ${e.toString()}');
  } finally {
    setLoading(false);
  }
}