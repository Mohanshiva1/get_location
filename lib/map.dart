import 'dart:async';
import 'dart:ffi';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final database = FirebaseDatabase.instance.reference().child("GPS");

  Timer? _timer;

  var fbData;

  double latvalue = 0;
  double longvalue = 0;

  GoogleMapController? googleMapController;
  Set<Marker> markers = {};

  CurrentLocation() async {
    await database.once().then((value) {
      fbData = value.snapshot.value;
      // print(fbData);
      setState(() {
        googleMapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(fbData['f_latitude'], fbData['f_longitude']),
                zoom: 14),
          ),
        );
      });
    });

    setState(() {
      markers.clear();
      markers.add(Marker(
          markerId: MarkerId('currentLocation'),
          position: LatLng(fbData['f_latitude'], fbData['f_longitude'])));
    });
  }

  // getValue() {
  //   database.once().then((value) {
  //     fbData = value.snapshot.value;
  //     print(fbData['log']);
  //     print(fbData['lat']);
  //     setState(() {
  //       lat = fbData['lat'].toString();
  //       log = fbData['log'].toString();
  //       print(lat);
  //       print(log);
  //       // latvalue = lat as double;
  //       // longvalue = log as double;
  //       // print(longvalue);
  //     });
  //   });
  // }

  // CameraPosition initialCameraPosition =
  //     CameraPosition(target: LatLng(latvalue,longvalue), zoom: 14);

  ////.........Get Current location............

  // Future<Position> _determinePosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     await Geolocator.openLocationSettings();
  //     return Future.error('Location services are disabled.');
  //   }
  //
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }
  //   return await Geolocator.getCurrentPosition();
  // }

  @override
  void initState() {
    googleMapController;
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        CurrentLocation();
        print('..................................');
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              child: Expanded(
                child: GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  compassEnabled: true,
                  mapToolbarEnabled: true,
                  // liteModeEnabled: true,

                  initialCameraPosition: CameraPosition(
                      target: LatLng(latvalue, longvalue), zoom: 34),
                  markers: markers,
                  // zoomControlsEnabled: true,
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) {
                    googleMapController = controller;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
