import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:geolocator/geolocator.dart';
import 'package:piano/piano.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi Instruments',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Multi Instruments'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterMidi flutterMidi = FlutterMidi();
  String path = 'assets/guitars.sf2';
  late Future<Position> position;

  @override
  void initState() {
    load(path);
    super.initState();
  }

  void load(String asset) async {
    flutterMidi.unmute(); // Optionally Unmute
    ByteData _byte = await rootBundle.load(asset);
    flutterMidi.prepare(sf2: _byte, name: path.replaceAll('assets/', ''));
  }

  Future<void> _makeCall(String num) async {
    Uri url = Uri(scheme: 'tel', path: num);
    await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            print('call');
            _makeCall('0592020838');
          },
          icon: Icon(Icons.phone),
        ),
        title: Text(widget.title),
        actions: [
          DropdownButton<String>(
            value: path,
            onChanged: (String? value) {
              print(value);
              setState(() {
                if (value != null) {
                  path = value;
                  load(value);
                }
              });
            },
            items: [
              DropdownMenuItem(
                child: Text('piano'),
                value: 'assets/Yamaha-Grand-Lite-SF-v1.1.sf2',
              ),
              DropdownMenuItem(
                child: Text('guitar'),
                value: 'assets/guitars.sf2',
              ),
              DropdownMenuItem(
                child: Text('flute'),
                value: 'assets/Expressive Flute SSO-v1.2.sf2',
              ),
            ],
          )
        ],
      ),
      body: InteractivePiano(
        keyWidth: 60,
        noteRange: NoteRange.forClefs([Clef.Bass, Clef.Alto, Clef.Treble]),
        onNotePositionTapped: (p) {
          print(p.pitch);
          flutterMidi.playMidiNote(midi: p.pitch);
        },
      ),
    );
  }
}
