import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_location/map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  var fbData;


  String location = 'Get';
  String Address = 'Search';
  String Name = '';
  String Street = '';
  String ISO_Country_Code = '';
  String Country = '';
  String Postal_code = '';
  String Administrative_area = '';
  String Subadministrative_area = '';
  String Locality = '';
  String Postal_Code = '';
  String lat = '';
  String long = '';


  var latval ;
  var logval ;


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

  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    // print(placemark);
    Placemark place = placemark[0];
    Name = '${place.name}';
    Street = '${place.street}';
    Locality = '${place.locality}';
    Subadministrative_area = '${place.subAdministrativeArea}';
    Administrative_area = '${place.administrativeArea}';
    Country = '${place.country}';
    Postal_Code = '${place.postalCode}';
    lat = "${position.latitude.toDouble()}" ;
    long = " ${position.longitude.toDouble()}";
    setState(() {
       latval = double.parse(lat);
       logval = double.parse(long);
       // print('-------------${logval.runtimeType}-----------------');
    });
  }



// put value......................
  final _auth = FirebaseDatabase.instance.reference().child("GPS");

  UpdateValue(){
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
              margin: EdgeInsets.symmetric(horizontal: 180),
              child: Column(
                children: [
                  ListTile(
                    title: Text("Lat",style: TextStyle(color: Colors.blue),),
                    trailing: Text(lat,style: TextStyle(color: Colors.blue),),
                  ),
                  ListTile(
                    title: Text("Long ",style: TextStyle(color: Colors.blue),),
                    trailing: Text(long,style: TextStyle(color: Colors.blue),),
                  ),
                  ListTile(
                    title: Text("Name ",style: TextStyle(color: Colors.blue),),
                    trailing: Text(Name,style: TextStyle(color: Colors.blue),),
                  ),
                  ListTile(
                    title: Text("Street ",style: TextStyle(color: Colors.blue),),
                    trailing: Text(Street,style: TextStyle(color: Colors.blue),),
                  ),
                  ListTile(
                    title: Text("Locality ",style: TextStyle(color: Colors.blue),),
                    trailing: Text(Locality,style: TextStyle(color: Colors.blue),),
                  ),
                  ListTile(
                    title: Text("Subadministrative_area ",style: TextStyle(color: Colors.blue),),
                    trailing: Text(Subadministrative_area,style: TextStyle(color: Colors.blue),),
                  ),
                  ListTile(
                    title: Text("Administrative_area ",style: TextStyle(color: Colors.blue),),
                    trailing: Text(Administrative_area,style: TextStyle(color: Colors.blue),),
                  ),
                  ListTile(
                    title: Text("Country ",style: TextStyle(color: Colors.blue),),
                    trailing: Text(Country,style: TextStyle(color: Colors.blue),),
                  ),
                  ListTile(
                    title: Text("Postal_code ",style: TextStyle(color: Colors.blue),),
                    trailing: Text(Postal_Code,style: TextStyle(color: Colors.blue),),
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
                      GetAddressFromLatLong(position);
                      location =
                      'Lat: ${position.latitude}   long: ${position.longitude}';
                    });
                  },
                  child: Text("Get Address"),
                ),
                SizedBox(
                  width: 100,
                ),
                ElevatedButton(onPressed: (){
                  setState(() {
                    UpdateValue();
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>MapScreen()));
                  });
                }, child: Text("Map Location"))
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


