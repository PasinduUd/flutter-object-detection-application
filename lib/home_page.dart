import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:tflite_object_detection/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isWorking = false; // isWorking: Camera is busy
  String result = '';
  late CameraController cameraController;
  CameraImage? cameraImage;

  void loadModel() async {
    await Tflite.loadModel(
      model: 'assets/mobilenet_v1_1.0_224.tflite',
      labels: 'assets/mobilenet_v1_1.0_224.txt',
    );
  }

  void initializeCamera() {
    cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );
    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        // Start image stream
        cameraController.startImageStream((imageFromStream) {
          if (!isWorking) {
            isWorking = true;
            cameraImage = imageFromStream;
            runModelOnStreamFrames();
          }
        });
      });
    });
  }

  void runModelOnStreamFrames() async {
    if (cameraImage != null) {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: cameraImage!.planes.map((plane) => plane.bytes).toList(),
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2, // Number of results per object
        threshold: 0.1,
        asynch: true,
      );

      result = "";
      recognitions?.forEach((response) {
        result += response['label'] +
            " " +
            (response["confidence"] as double).toStringAsFixed(2) +
            "\n\n";
      });

      setState(() => result);
      isWorking = false;
    }
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() async {
    super.dispose();
    await Tflite.close();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/camera_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Center(
                      child: TextButton(
                        // FlatButton widget has been replaced by TextButton
                        onPressed: () {
                          initializeCamera();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 35),
                          height: 270,
                          width: 360,
                          child: cameraImage == null
                              ? const SizedBox(
                                  height: 270,
                                  width: 360,
                                  child: Icon(
                                    Icons.camera,
                                    color: Colors.blueAccent,
                                    size: 40,
                                  ),
                                )
                              : AspectRatio(
                                  aspectRatio:
                                      cameraController.value.aspectRatio,
                                  child: CameraPreview(cameraController),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 55.0),
                    child: SingleChildScrollView(
                      child: Text(
                        result,
                        style: const TextStyle(
                          fontSize: 30.0,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
