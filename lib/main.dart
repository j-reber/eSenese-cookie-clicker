import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  MyApp myapp = MyApp();
  runApp(myapp);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _totalCookies = 0;
  int _cookiesPerSecond = 0;
  final double priceIncrement = 1.15;
  int _cursor = 15;
  int _grandma = 100;
  int _mine = 12000;
  int _factory = 130000;

  void _clickCookie() {
    setState(() {
      _totalCookies++;
    });
  }

  void _buyItem(int price) {
    setState(() {
      if (_totalCookies > price) {
        _totalCookies -= price;
        _cookiesPerSecond += 15;
      }
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
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
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
                '$_totalCookies',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              child: Container(
                color: Colors.grey,
                width: 500,
                height: 500,
                padding: EdgeInsets.zero,
                child: FloatingActionButton(
                  onPressed: () {
                    _clickCookie();
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
                '$_cookiesPerSecond',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //TODO: Add window to buy items

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
                              _buyItem(_cursor);
                            },
                            child: Text(
                              'Cursor $_cursor',
                              style: TextStyle(color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _buyItem(_grandma);
                            },
                            child: Text(
                              'Granny $_grandma',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _buyItem(_mine);
                            },
                            child: Text(
                              'Cookie Mine $_mine',
                              style: TextStyle(color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _buyItem(_factory);
                            },
                            child: Text(
                              'Cookie Factory $_factory',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
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
      ),
    );
  }
}
