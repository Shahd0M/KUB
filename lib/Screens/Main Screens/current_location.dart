// ignore_for_file: avoid_print

import 'package:authentication/main.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class CurrentLocation extends StatefulWidget {
  const CurrentLocation({super.key});

  @override
  CurrentLocationState createState() => CurrentLocationState();
}

class CurrentLocationState extends State<CurrentLocation> {
  late GoogleMapController googleMapController;
  String confirmedLocationAddress = '';
  static const CameraPosition initialCameraPosition = CameraPosition(target: LatLng(37.42796133580664, -122.085749655962), zoom: 14);

  Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User current location"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            markers: markers,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
            },
          ),
          Positioned(
            bottom: 75,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () async {
                Position? position = await determinePosition();
                googleMapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: LatLng(position!.latitude, position.longitude), zoom: 14),
                  ),
                );
                markers.clear();
                markers.add(Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: LatLng(position.latitude, position.longitude),
                ));
                List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

                // Extract the address components
                Placemark placemark = placemarks.first;
                confirmedLocationAddress = '${placemark.street}, ${placemark.subLocality}, ${placemark.locality},${placemark.postalCode},${placemark.country}';
              },
              label: const Text(
                "Current Location",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              icon: const Icon(Icons.location_history, color: Colors.white),
              backgroundColor: const Color(0xFF0D0A35),
            ),
          ),
          Positioned(
            bottom: 137,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).pop();
              },
              label: const Text(
                "Cancel",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              icon: const Icon(Icons.cancel, color: Colors.white),
              backgroundColor: const Color(0xFF0D0A35),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 13),
              width: 300,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  print('Confirmed Location Address: $confirmedLocationAddress');
                  if (confirmedLocationAddress.isNotEmpty) {
                    Navigator.of(context).pop(confirmedLocationAddress);
                    
                  } else {
                    showToast(message: "Please Choose a location for your address");
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFFFC632)), // Set your desired background color
                ),
                child: const Text(
                  "Confirm Location",
                  style: TextStyle(fontSize: 28, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Position?> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // If not enabled, prompt the user to enable location services
      bool enableService = await Geolocator.openLocationSettings();

      if (!enableService) {
        // User declined to enable location services
        return Future.error('Location services are disabled');
      }
    }

    // Check location permission
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Request location permission
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // User denied location permission
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // User denied location permission permanently
      return Future.error('Location permissions are permanently denied');
    }

    // Get the current position
    try {
      Position position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      // Handle other location-related errors
      print('Error getting location: $e');
      return null;
    }
  }
}
