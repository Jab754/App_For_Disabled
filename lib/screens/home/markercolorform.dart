import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mynotes/services/auth.dart';

class MarkerColorForm extends StatefulWidget {
  final String markerKey;

  const MarkerColorForm({required this.markerKey});

  @override
  _MarkerColorFormState createState() => _MarkerColorFormState();
}

class _MarkerColorFormState extends State<MarkerColorForm> {
  String? _color;

  Future<void> _updateMarkerColor() async {
    if (_color != null) {
      final DatabaseReference markerRef =
          FirebaseDatabase.instance.ref().child('marker').child(widget.markerKey);

      try {
        await markerRef.update({'color': _color});
        Navigator.pop(context);
      } catch (e) {
        print('Error updating marker color: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location review page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("How will you rate this location for disabled people:"),
            RadioListTile<String>(
              title: const Text('Red'),
              value: 'red',
              groupValue: _color,
              onChanged: (value) {
                setState(() {
                  _color = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Green'),
              value: 'green',
              groupValue: _color,
              onChanged: (value) {
                setState(() {
                  _color = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Yellow'),
              value: 'yellow',
              groupValue: _color,
              onChanged: (value) {
                setState(() {
                  _color = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: _updateMarkerColor,
              child: const Text('Update Location Color'),
            ),
          ],
        ),
      ),
    );
  }
}

