import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:tflite_object_detection/home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 3,
      imageBackground: Image.asset('assets/splash_background.jpg').image,
      useLoader: true,
      loaderColor: Colors.white,
      loadingText: const Text(
        'Loading ...',
        style: TextStyle(color: Colors.white),
      ),
      navigateAfterSeconds: const HomePage(),
    );
  }
}
