import 'package:another_background_location/another_background_location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Location? retrievedLocation;

  String latitude = 'waiting...';
  String longitude = 'waiting...';
  String altitude = 'waiting...';
  String accuracy = 'waiting...';
  String bearing = 'waiting...';
  String speed = 'waiting...';
  String time = 'waiting...';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Background Location Service'),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              Text('STREAM INFO: '),
              StreamBuilder(
                stream: BackgroundLocation().receivetest,
                // initialData: PeripheralState.unknown,
                builder:
                    (BuildContext context, AsyncSnapshot<Location> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        locationData('Latitude: ${snapshot.data!.latitude}'),
                        locationData('Longitude: ${snapshot.data!.longitude}'),
                        locationData('Altitude: ${snapshot.data!.altitude}'),
                        locationData('Accuracy: ${snapshot.data!.accuracy}'),
                        locationData('Bearing: ${snapshot.data!.bearing}'),
                        locationData('Speed: ${snapshot.data!.speed}'),
                        locationData('Time: ${snapshot.data!.time}'),
                      ],
                    );
                  } else {
                    return Text('No data received yet!');
                  }

                },
              ),

              Text('Callback INFO: '),
              locationData('Latitude: $latitude'),
              locationData('Longitude: $longitude'),
              locationData('Altitude: $altitude'),
              locationData('Accuracy: $accuracy'),
              locationData('Bearing: $bearing'),
              locationData('Speed: $speed'),
              locationData('Time: $time'),

              Text('Onclick INFO: '),
              locationData('Latitude: ${retrievedLocation?.latitude}'),
              locationData('Longitude: ${retrievedLocation?.longitude}'),
              locationData('Altitude: ${retrievedLocation?.altitude}'),
              locationData('Accuracy: ${retrievedLocation?.accuracy}'),
              locationData('Bearing: ${retrievedLocation?.bearing}'),
              locationData('Speed: ${retrievedLocation?.speed}'),
              locationData('Time: ${retrievedLocation?.time}'),
              ElevatedButton(
                  onPressed: () async {
                    await BackgroundLocation().setAndroidNotification(
                      title: 'Background service is running',
                      message: 'Background location in progress',
                      icon: '@mipmap/ic_launcher',
                    );
                    //await BackgroundLocation.setAndroidConfiguration(1000);
                    await BackgroundLocation().startLocationService();
                    BackgroundLocation().getLocationUpdates((location) {
                      setState(() {
                        latitude = location.latitude.toString();
                        longitude = location.longitude.toString();
                        accuracy = location.accuracy.toString();
                        altitude = location.altitude.toString();
                        bearing = location.bearing.toString();
                        speed = location.speed.toString();
                        time = DateTime.fromMillisecondsSinceEpoch(
                                location.time!.toInt())
                            .toString();
                      });
                      print('''\n
                        Latitude:  $latitude
                        Longitude: $longitude
                        Altitude: $altitude
                        Accuracy: $accuracy
                        Bearing:  $bearing
                        Speed: $speed
                        Time: $time
                      ''');
                    });
                  },
                  child: Text('Start Location Service')),
              ElevatedButton(
                  onPressed: () {
                    BackgroundLocation().stopLocationService();
                  },
                  child: Text('Stop Location Service')),
              ElevatedButton(
                  onPressed: () async {
                    final location = await BackgroundLocation().getCurrentLocation();
                    setState(() {
                      retrievedLocation = location;
                    });
                  },
                  child: Text('Get Current Location')),
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(37.42796133580664, -122.085749655962),
                  zoom: 14.4746,
                ),
                onMapCreated: (GoogleMapController controller) {
                  // _controller.complete(controller);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget locationData(String data) {
    return Text(
      data,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  void dispose() {
    BackgroundLocation().stopLocationService();
    super.dispose();
  }
}
