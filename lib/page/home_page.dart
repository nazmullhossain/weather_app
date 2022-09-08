
import 'dart:convert';
import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    _determinePosition();
    // TODO: implement initState
    super.initState();
  }

Position ? position;
  var lat;
  var lon;
  Map<String,dynamic>? weatherMap;
  Map<String,dynamic>? forecastMap;
 _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    position=await Geolocator.getCurrentPosition();
    lat = position!.latitude;
    lon = position!.longitude;
    fetchWeatherData();
    // lat=position!.latitude;
    // long=position!.longitude;
    print("Postion is ${position!.latitude} ${position!.longitude}");
    print("hellow");
  }

  fetchWeatherData()async{
    String weatherApi =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=b510656fee5e075dcf3e676d9f978fa2';
    String forecastApi =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=b510656fee5e075dcf3e676d9f978fa2';

    var weatherResponse=await http.get(Uri.parse(weatherApi));
    var forecastResponse=await http.get(Uri.parse(forecastApi));
      setState((){
        weatherMap=Map<String,dynamic>.from(jsonDecode(weatherResponse.body));
        forecastMap=Map<String,dynamic>.from(jsonDecode(forecastResponse.body));
      });
  print('pppppppppppppp${weatherResponse.body}');
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: weatherMap==null?Center(child: CircularProgressIndicator()): Container(
        padding: EdgeInsets.all(25.0),
        child: Column(
          children: [
            Text("${Jiffy(DateTime.now()).format("MMM do yy, h:mm")}"),
            Text("${weatherMap!["name"]}"),
            Text("${weatherMap!["main"]['temp']-32*5/9}")
            // "${(weatherMap!["main"]["temp"] - 273).toStringAsFixed(0)}°C",
          ],
        ),
      )
    );
  }
}
