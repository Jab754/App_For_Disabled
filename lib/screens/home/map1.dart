import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart' show rootBundle;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final databaseReference = FirebaseDatabase.instance.ref();
  List<Marker> markers = [];
  List<Marker> filteredMarkers = [];

  String _searchText = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadMarkers();
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        setState(() {
          _searchText = '';
          filteredMarkers = markers;
        });
      } else {
        setState(() {
          _searchText = _searchController.text;
        });
      }
    });
  }

  void loadMarkers() async {
    final String jsonString =
        await rootBundle.loadString("./assests/markers.json");
    final jsonData = json.decode(jsonString);

    markers = List<Marker>.from(jsonData.map((m) => Marker(
          color: Colors.blue,
          point: LatLng(m['Lat'], m['Long']),
          builder: (ctx) => Container(
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on),
          ),
        )));

    setState(() {
      filteredMarkers = markers;
    });
  }

  void filterMarkers(String query) {
    final List<Marker> searchResult = markers
        .where((marker) =>
            marker.point
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            marker.builder(context).toString().toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      filteredMarkers = searchResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: filterMarkers,
        ),
      ),
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
          MarkerLayer(markers: filteredMarkers),
        ],
      ),
    );
  }
}