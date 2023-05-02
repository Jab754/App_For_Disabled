import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:mynotes/services/auth.dart';
import 'package:http/http.dart' as http;
import 'package:mynotes/screens/home/markercolorform.dart';

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
  MapController? _mapController;
  List<Marker> markers = [];
  List<LatLng> routePolyline = [];
  late LatLng startPoint;
  late LatLng? endPoint;
  bool _showUserLocation = false;
  final loc.Location _location = loc.Location();
  loc.PermissionStatus _permissionStatus = loc.PermissionStatus.denied;
  StreamSubscription<loc.LocationData>? _locationSubscription;
  Marker? _liveLocationMarker;
  LatLng? _liveUserLocation;
  bool isRoutingEnabled = false;

  @override
  void initState() {
    super.initState();
    loadMarkers();
    checkLocationPermission();
    _mapController = MapController();
    startPoint = LatLng(19.04449176, 72.81998919); // Fr crce
    endPoint = null;
    fetchRoute();
  }

  void resetRoute() {
    setState(() {
      routePolyline.clear();
      endPoint = null;
      isRoutingEnabled = false;
    });
  }

  void fetchRoute() async {
    if (_liveUserLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Allow location access"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      startPoint = _liveUserLocation!;
      isRoutingEnabled = true;
      String url =
          "https://router.project-osrm.org/route/v1/driving/${startPoint.longitude},${startPoint.latitude};${endPoint?.longitude},${endPoint?.latitude}?steps=true&geometries=geojson";
      http.Response response = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(response.body);

      // Parse the route polyline from the response
      Map<String, dynamic> route = data['routes'][0];
      List<dynamic> geometry = route['geometry']['coordinates'];
      routePolyline = geometry.map((point) {
        List<double> coords = point.cast<double>();
        return LatLng(coords[1], coords[0]);
      }).toList();
    }

    print('Route polyline: $routePolyline');

    // Force the widget to redraw
    setState(() {});
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
            child: IconButton(
              icon: const Icon(Icons.location_on),
              color: Colors.black,
              onPressed: () {
                showModalBottomSheet(
                  context: ctx,
                  builder: (BuildContext context) {
                    return Container(
                      height: 200.0,
                      child: ListView(
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.directions_car),
                            title: const Text('Get directions by car'),
                            onTap: () {
                              endPoint = LatLng(lat, lng);
                              fetchRoute();
                              Navigator.pop(context);
                              // Do something
                            },
                          ),
                          Text(
                            name,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 18),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MarkerColorForm(markerKey: key)),
                              );
                              // show form here
                            },
                            child: const Text('Review this location'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
        markers.add(marker);
      });
      setState(() {});
    });
  }

  void checkLocationPermission() async {
    _permissionStatus = await _location.hasPermission();
    if (_permissionStatus == loc.PermissionStatus.granted) {
      _locationSubscription =
          _location.onLocationChanged.listen((loc.LocationData locationData) {
        if (_showUserLocation) {
          _liveUserLocation =
              LatLng(locationData.latitude!, locationData.longitude!);
          if (_liveLocationMarker != null) {
            if (endPoint != null) {
              fetchRoute();
            }
            markers.remove(_liveLocationMarker);
          }
          _liveLocationMarker = Marker(
            point: LatLng(locationData.latitude!, locationData.longitude!),
            color: Colors.blue,
            builder: (ctx) => Container(
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person),
            ),
          );
          markers.add(_liveLocationMarker!);
          setState(() {});
        }
      });
    } else {
      _permissionStatus = await _location.requestPermission();
      if (_permissionStatus == loc.PermissionStatus.granted) {
        checkLocationPermission();
      }
    }
  }

  void toggleUserLocation() {
    setState(() {
      _showUserLocation = !_showUserLocation;
      if (_showUserLocation) {
        _locationSubscription?.resume();
        if (_liveUserLocation != null) {
          // center the map to user's live location
          MapController().move(_liveUserLocation!, 16.0);
        }
      } else {
        _liveUserLocation = null;
        markers.remove(_liveLocationMarker);
        _locationSubscription?.pause();
      }
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
      appBar: AppBar(
        title: const Text('Wheel guide'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              toggleUserLocation();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
            },
          )
        ],
      ),

      body: FlutterMap(
        options: MapOptions(
          center: startPoint,
          zoom: 16,
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
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePolyline,
                color: Colors.blue,
                strokeWidth: 5.0,
              ),
            ],
          ),
          MarkerLayer(markers: markers),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleUserLocation,
        child: Icon(_showUserLocation
            ? Icons.location_searching
            : Icons.location_disabled_sharp),
      ),
      bottomNavigationBar: isRoutingEnabled
          ? SizedBox(
              width: 30,
              height: 40,
              child: ElevatedButton(
                onPressed: resetRoute,
                child: Text('End Routing', style: TextStyle(fontSize: 16)),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  elevation: MaterialStateProperty.all(0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            )
          : null,
      // Container(child:SignOut),
    );
  }
}
