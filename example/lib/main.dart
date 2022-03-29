import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_avif/flutter_avif.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget encoderOutput = Container();
  Widget encoderOutput2 = Container();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: [
            IconButton(
              icon: const Icon(Icons.repeat_outlined),
              tooltip: 'Encode Demo',
              onPressed: () async {
                final bytes = await rootBundle.load("assets/vettel.gif");
                final avifBytes = await encodeAvif(bytes.buffer.asUint8List());
                setState(() {
                  encoderOutput = AvifImage.memory(
                    avifBytes,
                    height: 200,
                    fit: BoxFit.contain,
                  );
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.repeat_outlined),
              tooltip: 'Encode Demo 2',
              onPressed: () async {
                final bytes = await rootBundle.load("assets/keyboard.png");
                final avifBytes = await encodeAvif(bytes.buffer.asUint8List());
                setState(() {
                  encoderOutput2 = AvifImage.memory(
                    avifBytes,
                    height: 200,
                    fit: BoxFit.contain,
                  );
                });
              },
            ),
          ],
        ),
        body: ListView(
          children: [
            AvifImage.asset(
              "assets/vettel.avif",
              height: 200,
              fit: BoxFit.contain,
            ),
            AvifImage.asset(
              "assets/hato.avif",
              height: 200,
              fit: BoxFit.contain,
            ),
            AvifImage.network(
              "https://ezgif.com/images/format-demo/butterfly.avif",
              height: 200,
              fit: BoxFit.contain,
            ),
            encoderOutput,
            encoderOutput2,
          ],
        ),
      ),
    );
  }
}
