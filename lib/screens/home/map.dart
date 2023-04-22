import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mynotes/services/auth.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

final Map<String, Color> colorMap = {
  'yellow': Colors.yellow,
  'red': Colors.red,
  'green': Colors.green,
  // Add more colors as needed
};

class _MapScreenState extends State<MapScreen> {
  final databaseReference = FirebaseDatabase.instance.ref();
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    loadMarkers();
  }

  void loadMarkers() {
    databaseReference.child("marker").onValue.listen((event) {
      markers.clear();

      Map<dynamic, dynamic>? map;
      final dynamic value = event.snapshot.value;
      if (value != null && value is Map) {
        map = value;
      }

      map?.forEach((key, value) {
        double lat = double.parse(value['Lat'].toString());
        double lng = double.parse(value['Long'].toString());
        String name = value['Name'];
        String colorString = value['color'].toString();
        Color color = colorMap[colorString] ?? Colors.red;
        Marker marker = Marker(
          point: LatLng(lat, lng),
          color: color,
          builder: (ctx) => Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on),
          ),
        );
        markers.add(marker);
      });
      setState(() {});
    });
  }
  final AuthService _auth = new AuthService();

  @override
  Widget build(BuildContext context) {

    final SignOut = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Theme.of(context).primaryColor,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () async {
           await _auth.signOut();
        },
        child: Text(
          "Log out",
          style: TextStyle(color: Theme.of(context).primaryColorLight),
          textAlign: TextAlign.center,
        ),
      ),
    );
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(19.0466824, 72.8204226),
          zoom: 16.0,
        ),
        nonRotatedChildren: [
          AttributionWidget.defaultWidget(
            source: 'OpenStreetMap contributors',
            onSourceTapped: null,
          ),
        ],
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.first.mynotes',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
      // Container(child:SignOut),
    );
  }
}