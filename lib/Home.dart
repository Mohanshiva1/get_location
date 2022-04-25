import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    print(placemark);
    Placemark place = placemark[0];
    Name = '${place.name}';
    Street = '${place.street}';
    Locality = '${place.locality}';
    Subadministrative_area = '${place.subAdministrativeArea}';
    Administrative_area = '${place.administrativeArea}';
    Country = '${place.country}';
    Postal_Code = '${place.postalCode}';
    lat = "${position.latitude}";
    long = " ${position.longitude}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Center(
                child: Column(
                  children: [

                    SizedBox(
                      height: 10,
                    ),
                    Text("Address",style: TextStyle(fontSize: 30,fontWeight: FontWeight.w900),),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 180),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text("Lat"),
                            trailing: Text(lat),
                          ),
                          ListTile(
                            title: Text("Long "),
                            trailing: Text(long),
                          ),
                          ListTile(
                            title: Text("Name "),
                            trailing: Text('${Name}'),
                          ),
                          ListTile(
                            title: Text("Street "),
                            trailing: Text(Street),
                          ),
                          ListTile(
                            title: Text("Locality "),
                            trailing: Text(Locality),
                          ),
                          ListTile(
                            title: Text("Subadministrative_area "),
                            trailing: Text(Subadministrative_area),
                          ),
                          ListTile(
                            title: Text("Administrative_area "),
                            trailing: Text(Administrative_area),
                          ),
                          ListTile(
                            title: Text("Country "),
                            trailing: Text(Country),
                          ),
                          ListTile(
                            title: Text("Postal_code "),
                            trailing: Text(Postal_Code),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Position position = await _determinePosition();
                        print(position.latitude);
                        print(position.longitude);
                        setState(() {
                          GetAddressFromLatLong(position);
                          location =
                              'Lat: ${position.latitude}   long: ${position.longitude}';
                        });
                      },
                      child: Text("Get location"),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
