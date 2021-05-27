import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pix_epoc/core/controllers/matera_controller.dart';
import 'package:pix_epoc/data/models/matera/matera_model.dart';
import 'package:pix_epoc/pix_epoc.dart';

void main() {
  runApp(MyApp());
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
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

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
  MateraModel matera;
  Pix pix;
  bool isLoading = false;
  MateraModel _matera = MateraModel(
    apiKey: "6420986D-7B7E-4B40-8B86-900BE3CA1F1A",
    secretKey: "69D45BAF-EC9E-4F9D-94D0-595A80EED657",
    mediatorAccount: "B4249C4F-40B8-497F-90AF-5BBC85D44E8D",
  );

  MateraController _materaController = Pix.materaInstance;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    Image _img;

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Gerar Qrcodes"),
      ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Gerar Qrcodes:',
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                try {
                  await _materaController.addProvider(_matera, debug: true);
                  await _materaController.addAccount('744A359A-8863-5EE1-B505-3B5F3CBF6F22');
                  _materaController.configureGateway(fee: 1.4, feeType: FeeType.percentage, maxFee: 1);
                  String valor = ((Random().nextDouble() * 100) * 3).toStringAsFixed(2);
                  await _materaController.generateQrCode(value: double.parse(valor), comment: "OI", expiration: Duration(minutes: 3), urlCallback: 'http://marcus-pc.din.epoc.com.br:8226/pix.php');
                  setState(() {
                    isLoading = false;
                  });
                } catch (e) {
                  print(e);
                }
              },
              child: Text("Qrcode Matera"),
            ),
            (isLoading)
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : (_materaController?.transaction?.imageContent == null)
                    ? Container()
                    : Column(
                        children: [
                          Text(_materaController.transaction.externalIdentifier),
                          Text(_materaController.transaction.totalAmount.toString()),
                          _materaController.convertImage(_materaController.transaction.imageContent),
                        ],
                      ),
          ],
        ),
      ),
    );
  }
}
