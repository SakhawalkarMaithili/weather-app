import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'searchscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

String apikey = '4940af0b41a777e09f122f662397bed4';
String temp = '0';
String humidity = '0';
String maxTemp = '0';
String minTemp = '0';
String cityName = 'Satara';
String savedCityName = '';
String sky = "";
List<String> savedCities = [savedCityName];

Future<http.Response> callApi(String city) async {
  print('Data api call is being done');
  var response = await http.get(
    Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apikey&units=metric'),
  );
  print(
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apikey&units=metric');
  print(response.body);
  return response;
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    final prefs = SharedPreferences.getInstance();
    prefs.then((prefs) {
      setState(() {
        cityName = prefs.getString('cityName') ?? 'Delhi';
        try {
          callApi(cityName).then((value) {
            var weatherData = jsonDecode(value.body);
            if (weatherData['coord'] != null) {
              setState(() {
                savedCityName = weatherData['name'].toString();
                print(weatherData['main']['temp']);
                cityName = weatherData['name'];
                temp = weatherData['main']['temp'].toString();
                humidity = weatherData['main']['humidity'].toString();
                maxTemp = weatherData['main']['temp_max'].toString();
                minTemp = weatherData['main']['temp_min'].toString();
                sky = weatherData['weather'][0]['description'];
              });
            } else {
              final snackBar = SnackBar(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                content: Text(weatherData['message'],
                    style: TextStyle(fontSize: 20, color: Colors.white)),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {},
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          });
        } catch (e) {
          final snackBar = SnackBar(
            content: const Text('Something went wrong'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          print(e);
        }
      });
    });

    super.initState();
  }

  void loadCity() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cityName = (prefs.getString('cityName') ?? 'Patna');
      print(cityName);
    });
  }

  Widget build(BuildContext context) {
    String msg = "City saved";

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text('Weather app'),
        actions: [
          IconButton(
              onPressed: () async {
                var city = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
                try {
                  var res = await callApi(city);
                  var weatherData = jsonDecode(res.body);
                  if (weatherData['coord'] != null) {
                    setState(() {
                      cityName = weatherData['name'].toString();
                      temp = weatherData['main']['temp'].toString();
                      humidity = weatherData['main']['humidity'].toString();
                      maxTemp = weatherData['main']['temp_max'].toString();
                      minTemp = weatherData['main']['temp_min'].toString();
                      sky = weatherData['weather'][0]['description'];
                    });
                  } else {
                    final snackBar = SnackBar(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      content: Text(weatherData['message'],
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                } catch (e) {
                  final snackBar = SnackBar(
                    content: const Text('Something went wrong'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  print(e);
                }
              },
              icon: Icon(Icons.search))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$temp°',
              style: TextStyle(
                  fontSize: 100,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          Text('C',
              style: TextStyle(
                  fontSize: 100,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          Container(
            height: 30,
          ),
          Text(cityName.toUpperCase(),
              style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3)),
          Container(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    sky,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Humidity = $humidity %',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Max = $maxTemp°C',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Min = $minTemp °C',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip:
            (savedCities.contains(cityName)) ? "Remove from saved" : "Save",
        onPressed: () {
          setState(() {
            print(cityName);
            if (!savedCities.contains(cityName)) {
              savedCities.add(cityName);
              msg = "City saved";
            } else {
              savedCities.remove(cityName);
              msg = "City removed from saved";
            }
            final snackBar = SnackBar(
              content: Text(msg),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            print(savedCities);
          });
        },
        backgroundColor: Colors.black87,
        child: Icon(
          Icons.favorite,
          color: (savedCities.contains(cityName)) ? Colors.red : Colors.white,
        ),
      ),
    );
  }
}
