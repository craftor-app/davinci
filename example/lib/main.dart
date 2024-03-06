import 'dart:typed_data';

import 'package:davinci/davinci.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: App(), debugShowCheckedModeBanner: false));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  ///1.create a globalkey variable
  GlobalKey imageKey = GlobalKey();
  Uint8List? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9C5D1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ///2. wrap the desired widget with Davinci widget

            Container(
              height: 150,
              width: double.infinity,
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      color: Colors.red,
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      color: Colors.yellow,
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff9795EF),
              ),
              onPressed: () async {
                ///If the widget was not in the widget tree or not present on the screen
                ///pass the widget that has to be converted into image.
                image = await DavinciCapture.offStage(
                    context: context, const PreviewWidget());
                setState(() {});
                print("done");
              },
              child: const Text('Capture widget off-stage'),
            ),
            if (image != null)
              Image.memory(
                image!,
                width: 400,
                height: 400,
              )
          ],
        ),
      ),
    );
  }
}

/// This widget is not mounted when the App is mounted.
class PreviewWidget extends StatelessWidget {
  const PreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.orange,
      child: const Center(
        child: Text(
          "This widget was not in widget tree",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
