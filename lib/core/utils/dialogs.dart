// lib/utils/dialogs.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void showLocationServiceDisabledAlert(BuildContext context) {
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

void showEnableLocationSettingsDialog(BuildContext context) {
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