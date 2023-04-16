import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteResponse {
  const RouteResponse();

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    return RouteResponse();
  }
}

void main() {
  runApp(const AggieCommuteApp());
}

class AggieCommuteApp extends StatelessWidget {
  const AggieCommuteApp({super.key});

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    ;
    return MaterialColor(color.value, swatch);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aggie Commute',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: createMaterialColor(const Color(0xff500000)),
        fontFamily: GoogleFonts.oswald().fontFamily,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: createMaterialColor(const Color(0xff500000)),
        fontFamily: GoogleFonts.oswald().fontFamily,
      ),
      home: const MyHomePage(title: '=Aggie Commute'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String commuteSource = "";
  String commuteDestination = "";
  TimeOfDay commuteTime = TimeOfDay.now();
  DateTime commuteDate = DateTime.now();

  String createHttpRequestBody() {
    return jsonEncode(<String, String>{
      'source': commuteSource,
      'destination': commuteDestination,
      'time': commuteTime.format(context),
      'date': commuteDate.toIso8601String(),
    });
  }

  void displayRouteRequest() {
    String requestBody = createHttpRequestBody();
    requestBody = requestBody
        .replaceAll(RegExp(r'{'), '{\n')
        .replaceAll(RegExp(r','), ',\n')
        .replaceAll(RegExp(r'}'), '\n}');

    debugPrint(requestBody);

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('HTTP Request Body'),
        content: Text(requestBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<RouteResponse> sendRouteRequest() async {
    final requestBody = createHttpRequestBody();

    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/albums'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: requestBody,
    );

    if (response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return RouteResponse.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to send request.');
    }
  }

  void setCommuteSource(String userSource) {
    setState(() {
      commuteSource = userSource;
    });
  }

  void setCommuteDestination(String userDestination) {
    setState(() {
      commuteDestination = userDestination;
    });
  }

  void setCommuteTime() async {
    final userTime = await showTimePicker(
      context: context,
      initialTime: commuteTime,
    );
    if (userTime != null && userTime != commuteTime) {
      setState(() {
        commuteTime = userTime;
      });
    }
  }

  void setCommuteDate() async {
    final userDate = await showDatePicker(
        context: context,
        initialDate: commuteDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
    if (userDate != null && userDate != commuteDate) {
      setState(() {
        commuteDate = userDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 140.00, //set your height
          flexibleSpace: SafeArea(
              child: Container(
            color: Theme.of(context).primaryColor, // set your color
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu,
                              color: Colors.white, size: 35),
                          onPressed: () => {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.bug_report_sharp,
                              color: Colors.white, size: 35),
                          onPressed: displayRouteRequest,
                        ),
                        const Spacer(),
                        Row(children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(widget.title,
                                    style: GoogleFonts.oswald(
                                      textStyle:
                                          const TextStyle(color: Colors.white),
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.italic,
                                    )),
                                const IconButton(
                                  icon: Icon(Icons.directions_bus_filled,
                                      color: Colors.white, size: 35),
                                  onPressed: null,
                                ),
                              ])
                        ]),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.calendar_month_outlined,
                              color: Colors.white, size: 35),
                          onPressed: () async {
                            setCommuteDate();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.access_time,
                              color: Colors.white, size: 35),
                          onPressed: () async {
                            setCommuteTime();
                          },
                        ),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                            flex: 3,
                            child: TextFormField(
                              onChanged: setCommuteSource,
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                icon: const Icon(Icons.my_location,
                                    color: Colors.white),
                                hintText: '   Where do you want to start from?',
                                labelText: 'Source',
                                filled: true,
                                fillColor:
                                    Theme.of(context).secondaryHeaderColor,
                              ),
                              onSaved: (String? value) {
                                // This optional block of code can be used to run
                                // code when the user saves the form.
                              },
                              validator: (String? value) {
                                return (value != null)
                                    ? 'Do not use the @ char.'
                                    : null;
                              },
                            )),
                        Flexible(
                            flex: 3,
                            child: TextFormField(
                              onChanged: setCommuteDestination,
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                icon: const Icon(Icons.map_outlined,
                                    color: Colors.white),
                                hintText: '   Where do you want to go?',
                                labelText: 'Destination',
                                filled: true,
                                fillColor:
                                    Theme.of(context).secondaryHeaderColor,
                              ),
                              onSaved: (String? value) {
                                // This optional block of code can be used to run
                                // code when the user saves the form.
                              },
                              validator: (String? value) {
                                return (value != null)
                                    ? 'Do not use the @ char.'
                                    : null;
                              },
                            )),
                        Flexible(
                          flex: 1,
                          child: IconButton(
                            icon: const Icon(Icons.fork_right, size: 35),
                            color: Colors.white,
                            onPressed: () async {
                              sendRouteRequest();
                            },
                          ),
                        ),
                      ])
                ]),
          ))),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Stack(children: [
        FlutterMap(
          options: MapOptions(
            center: LatLng(30.61221, -96.34149),
            zoom: 15,
          ),
          nonRotatedChildren: [
            AttributionWidget.defaultWidget(
              source: 'OpenStreetMap contributors',
              onSourceTapped: null,
            ),
          ],
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
          ],
        ),
      ])),
    );
  }
}
