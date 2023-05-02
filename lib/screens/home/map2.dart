import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController? _mapController;

  // Variables for holding the start and end points of the route
  late LatLng startPoint;
  late LatLng endPoint;

  // Variable for holding the route polyline
  List<LatLng> routePolyline = [];

  @override
  void initState() {
    super.initState();

    // Set the start and end points
    startPoint = LatLng(19.04449176, 72.81998919); // Fr crce
    endPoint = LatLng(19.08778816, 72.83112538); // SNDT

    // Fetch the route from OSRM
    fetchRoute();
  }

  // Fetch the route from OSRM
  void fetchRoute() async {
  String url =
      "https://router.project-osrm.org/route/v1/driving/${startPoint.longitude},${startPoint.latitude};${endPoint.longitude},${endPoint.latitude}?steps=true&geometries=geojson";
  http.Response response = await http.get(Uri.parse(url));
  Map<String, dynamic> data = json.decode(response.body);

  // Parse the route polyline from the response
  Map<String, dynamic> route = data['routes'][0];
  List<dynamic> geometry = route['geometry']['coordinates'];
  routePolyline = geometry.map((point) {
    List<double> coords = point.cast<double>();
    return LatLng(coords[1], coords[0]);
  }).toList();

  print('Route polyline: $routePolyline');

  // Force the widget to redraw
  setState(() {});
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: startPoint,
          zoom: 16.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePolyline,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40.0,
                height: 40.0,
                color: Colors.black,
                point: startPoint,
                builder: (ctx) => Icon(Icons.location_on),
              ),
              Marker(
                width: 40.0,
                height: 40.0,
                color: Colors.black,
                point: endPoint,
                builder: (ctx) => Icon(Icons.location_on),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
