import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/voice_service.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  GoogleMapController? _mapController;
  final VoiceService _voiceService = VoiceService();

  // Default to a central location (e.g., city center) if location not found
  final LatLng _center = const LatLng(37.7749, -122.4194);

  @override
  void initState() {
    super.initState();
    _voiceService.speak(
      "Navigation started. Showing your location on the map.",
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Navigation")),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(target: _center, zoom: 11.0),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
