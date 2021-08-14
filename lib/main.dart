import 'dart:io';
import 'dart:async';

import 'package:coockie_clicker/cookie_building.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esense_flutter/esense.dart';

void main() {
  MyApp myapp = MyApp();
  runApp(myapp);
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double totalCookies = 1000000.0;
  int cookiesPerSecond = 0;
  Timer? timer;

  CookieBuilding cursor = CookieBuilding("cursor", 10, 1);
  CookieBuilding grandma = CookieBuilding("grandma", 100, 5);
  CookieBuilding mine = CookieBuilding("mine", 12000, 100);
  CookieBuilding factory = CookieBuilding("factory", 130000, 750);

  void clickCookie() {
    setState(() {
      totalCookies++;
    });
  }

  void cookiesByCps() {
    setState(() {
      totalCookies += (cookiesPerSecond / 100);
    });
  }

  void buyItem(CookieBuilding building) {
    setState(() {
      if (totalCookies > building.cost) {
        totalCookies -= building.cost;
        cookiesPerSecond += building.cps;
        building.buildingBought();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _connectToESense();
    timer =
        Timer.periodic(Duration(milliseconds: 10), (Timer t) => cookiesByCps());
  }

  @override
  void dispose() {
    timer?.cancel();
    _pauseListenToSensorEvents();
    ESenseManager.disconnect();
    super.dispose();
  }

  String _deviceName = 'Unknown';
  double _voltage = -1;
  String _deviceStatus = '';
  bool sampling = false;
  String _event = '';
  SensorEvent acceleration = SensorEvent();
  String _button = 'not pressed';

  // the name of the eSense device to connect to -- change this to your own device.
  String eSenseName = 'eSense-0278';

  Future<void> _connectToESense() async {
    bool con = false;

    // if you want to get the connection events when connecting, set up the listener BEFORE connecting...
    ESenseManager.connectionEvents.listen((event) {
      print('CONNECTION event: $event');

      // when we're connected to the eSense device, we can start listening to events from it
      if (event.type == ConnectionType.connected) _listenToESenseEvents();

      setState(() {
        switch (event.type) {
          case ConnectionType.connected:
            _deviceStatus = 'connected';
            break;
          case ConnectionType.unknown:
            _deviceStatus = 'unknown';
            break;
          case ConnectionType.disconnected:
            _deviceStatus = 'disconnected';
            break;
          case ConnectionType.device_found:
            _deviceStatus = 'device_found';
            break;
          case ConnectionType.device_not_found:
            _deviceStatus = 'device_not_found';
            break;
        }
      });
    });

    con = await ESenseManager.connect(eSenseName);

    setState(() {
      _deviceStatus = con ? 'connecting' : 'connection failed';
    });
  }

  void _listenToESenseEvents() async {
    ESenseManager.eSenseEvents.listen((event) {
      print('ESENSE event: $event');

      setState(() {
        switch (event.runtimeType) {
          case DeviceNameRead:
            _deviceName = (event as DeviceNameRead).deviceName;
            break;
          case BatteryRead:
            _voltage = (event as BatteryRead).voltage;
            break;
          case ButtonEventChanged:
            _button = (event as ButtonEventChanged).pressed
                ? 'pressed'
                : 'not pressed';
            clickCookie();
            break;
          case AccelerometerOffsetRead:
            // TODO

            break;
          case AdvertisementAndConnectionIntervalRead:
            // TODO
            break;
          case SensorConfigRead:
            // TODO
            break;
        }
      });
    });

    _getESenseProperties();
  }

  void _getESenseProperties() async {
    // get the battery level every 10 secs
    Timer.periodic(Duration(seconds: 10),
        (timer) async => await ESenseManager.getBatteryVoltage());

    // wait 2, 3, 4, 5, ... secs before getting the name, offset, etc.
    // it seems like the eSense BTLE interface does NOT like to get called
    // several times in a row -- hence, delays are added in the following calls
    Timer(
        Duration(seconds: 2), () async => await ESenseManager.getDeviceName());
    Timer(Duration(seconds: 3),
        () async => await ESenseManager.getAccelerometerOffset());
    Timer(
        Duration(seconds: 4),
        () async =>
            await ESenseManager.getAdvertisementAndConnectionInterval());
    Timer(Duration(seconds: 5),
        () async => await ESenseManager.getSensorConfig());
  }

  StreamSubscription? subscription;
  void _startListenToSensorEvents() async {
    // subscribe to sensor event from the eSense device
    subscription = ESenseManager.sensorEvents.listen((event) {
      print('SENSOR event: $event');

      setState(() {
        _event = event.toString();
        acceleration = event;


          if (event.accel[0] > -1000) {
            clickCookie();

        }
      });
    });
    setState(() {
      sampling = true;
    });
  }

  void _pauseListenToSensorEvents() async {
    subscription?.cancel();
    setState(() {
      sampling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    //Don't let the phone rotate
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    //Hide phone status bar
    SystemChrome.setEnabledSystemUIOverlays([]);

    return Scaffold(
      //appBar: AppBar(

      //  title: Text('Cookie Clicker'),
      //   centerTitle: true,
      //),

      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                'Your total cookies: ',
                style: TextStyle(
                  fontSize: 30.0,
                ),
              ),
            ),
            Container(
              child: Text(
                totalCookies.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              child: Container(
                color: Colors.white,
                width: 500,
                height: 500,
                padding: EdgeInsets.zero,
                child: FloatingActionButton(
                  onPressed: () {
                    clickCookie();
                  },
                  child: Image.asset(
                    'assets/cookie_cut.jpg',
                  ),
                  elevation: 0.0,
                  highlightElevation: 0.0,
                ),
              ),
            ),
            Container(
              child: Text(
                '  CPS: ',
                style: TextStyle(
                  fontSize: 40,
                ),
              ),
            ),
            Container(
              child: Text(
                '$cookiesPerSecond',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25.0, 0, 0, 0),
            child: FloatingActionButton(
              //showDialog with connect info
              onPressed: () {
                print('$_event');

                _startListenToSensorEvents();
                showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                          elevation: 16,
                          child: ListView(shrinkWrap: true, children: <Widget>[
                            Center(
                              child: Text(
                                'Connection Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            ListView(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              children: [
                                Text('eSense Device Status: \t$_deviceStatus'),
                                Text('eSense Device Name: \t$_deviceName'),
                                Text('eSense Battery Level: \t$_voltage'),
                                Text('eSense Button Event: \t$_button'),
                                Text(''),
                                Text('$_event'),
                              ],
                            ),
                          ]));
                    });
              },
              child: Icon(Icons.sync),
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    elevation: 16,
                    child: Container(
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          //SizedBox(height: 200),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                'Shop',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 50,
                                ),
                              ),
                            ),
                          ),

                          //SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  buyItem(cursor);
                                },
                                child: Text(
                                  'Cursor ' + cursor.cost.toString(),
                                  style: TextStyle(color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  elevation: 0.0,
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  buyItem(grandma);
                                },
                                child: Text(
                                  'Granny ' + grandma.cost.toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  elevation: 0.0,
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  buyItem(mine);
                                },
                                child: Text(
                                  'Cookie Mine ' + mine.cost.toString(),
                                  style: TextStyle(color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  elevation: 0.0,
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  buyItem(factory);
                                },
                                child: Text(
                                  'Cookie Factory ' + factory.cost.toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  elevation: 0.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            tooltip: 'Buy new tools to get more cookies',
            child: Icon(Icons.shopping_bag_outlined),
          )
        ],
      ),
    );
  }
}
