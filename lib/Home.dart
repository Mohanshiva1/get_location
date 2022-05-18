import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_location/map.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  var fbData;


  String location = 'Get';
  String address = 'Search';
  String name = '';
  String street = '';
  String isoCountryCode = '';
  String country = '';
  String postalCode = '';
  String administrativeArea = '';
  String subAdministrativeArea = '';
  String locality = '';
  String postalCodes = '';
  String lat = '';
  String long = '';


  var latval;
  var logval;


  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> getAddressFromLatLong(Position position) async {
    List<Placemark> placeMark =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    // print(placeMark);
    Placemark place = placeMark[0];
    name = '${place.name}';
    street = '${place.street}';
    locality = '${place.locality}';
    subAdministrativeArea = '${place.subAdministrativeArea}';
    administrativeArea = '${place.administrativeArea}';
    country = '${place.country}';
    postalCode = '${place.postalCode}';
    lat = "${position.latitude.toDouble()}" ;
    long = " ${position.longitude.toDouble()}";
    setState(() {
       latval = double.parse(lat);
       logval = double.parse(long);
       // print('-------------${logval.runtimeType}-----------------');
    });
  }



// put value......................
  final _auth = FirebaseDatabase.instance.ref().child("GPS");

  updateValue(){
    _auth.once().then((value) => {
      for (var element in value.snapshot.children){
        // print(element.key),
        fbData = element.key,
        // print(fbData),
        _auth.update({
          'f_latitude': latval,
          "f_longitude":logval ,
        }),
      }
    });
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.black12,
     body:
     SafeArea(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Center(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Address",
              style:
                  TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 180),
              child: Column(
                children: [
                  ListTile(
                    title: const Text("Lat",style: TextStyle(color: Colors.blue),),
                    trailing: Text(lat,style: const TextStyle(color: Colors.blue),),
                  ),
                  ListTile(
                    title: const Text("Long ",style: TextStyle(color: Colors.blue),),
                    trailing: Text(long,style: const TextStyle(color: Colors.blue),),
                  ),
                  ListTile(
                    title: const Text("Name ",style: TextStyle(color: Colors.blue),),
                    trailing: Text(name,style: const TextStyle(color: Colors.blue),),
                  ),
                  ListTile(
                    title:const Text("Street ",style: TextStyle(color: Colors.blue),),
                    trailing: Text(street,style: const TextStyle(color: Colors.blue),),
                  ),
                  ListTile(
                    title: const Text("Locality ",style:  TextStyle(color: Colors.blue),),
                    trailing: Text(locality,style: const TextStyle(color: Colors.blue),),
                  ),
                  ListTile(
                    title: const Text("SubAdministrative_area ",style: TextStyle(color: Colors.blue),),
                    trailing: Text(subAdministrativeArea,style: const TextStyle(color: Colors.blue),),
                  ),
                  ListTile(
                    title: const Text("Administrative_area ",style: TextStyle(color: Colors.blue),),
                    trailing: Text(administrativeArea,style: const TextStyle(color: Colors.blue),),
                  ),
                  ListTile(
                    title: const Text("Country ",style: TextStyle(color: Colors.blue),),
                    trailing: Text(country,style: const TextStyle(color: Colors.blue),),
                  ),
                  ListTile(
                    title: const Text("Postal_code ",style: TextStyle(color: Colors.blue),),
                    trailing: Text(postalCode,style: const TextStyle(color: Colors.blue),),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Position position = await _determinePosition();
                    // print(position.latitude);
                    // print(position.longitude);
                    setState(() {
                      getAddressFromLatLong(position);
                      location =
                      'Lat: ${position.latitude}   long: ${position.longitude}';
                    });
                  },
                  child: const Text("Get Address"),
                ),
                const SizedBox(
                  width: 100,
                ),
                ElevatedButton(onPressed: (){
                  setState(() {
                    updateValue();
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const MapScreen()));
                  });
                }, child: const Text("Map Location"))
              ],
            )

          ],
        ),
      ),

    ],
  ),
),
   );
  }
//
// Future<Position> _determinePosition() async {
//   bool serviceEnabled;
//   LocationPermission permission;
//
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//
//   if (!serviceEnabled) {
//     return Future.error('Location services are disabled');
//   }
//
//   permission = await Geolocator.checkPermission();
//
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//
//     if (permission == LocationPermission.denied) {
//       return Future.error("Location permission denied");
//     }
//   }
//
//   if (permission == LocationPermission.deniedForever) {
//     return Future.error('Location permissions are permanently denied');
//   }
//
//   Position position = await Geolocator.getCurrentPosition();
//
//   return position;
// }
}


