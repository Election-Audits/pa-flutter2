import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
    required this.pictureDir
  });

  final CameraDescription camera;
  final String pictureDir;

  @override
  TakePictureScreenState createState() => TakePictureScreenState(pictureDir);
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final String _pictureDir;

  TakePictureScreenState(this._pictureDir) : super();

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')), // TODO: translations for text elements
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!context.mounted) return;

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                  pictureDir: _pictureDir,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String pictureDir;

  const DisplayPictureScreen({super.key, required this.imagePath, required this.pictureDir});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            TextButton.icon(
              iconAlignment: IconAlignment.end,
              label: Text('cancel', style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(context).pop(); // go back to picture taking screen
              }, 
              icon: Icon(Icons.cancel, color: Colors.red)
            ),
            //
            TextButton.icon(
              iconAlignment: IconAlignment.start,
              label: Text('continue', style: TextStyle(color: Colors.green),),
              onPressed: ()async { // pop twice to go to pictures screen
                // move file to the right folder, and rename
                var file = File(imagePath);
                var fileParts = imagePath.split('.');
                var ext = fileParts[fileParts.length-1];
                await file.copy('$pictureDir/${DateTime.now().millisecondsSinceEpoch}.$ext');
                Navigator.of(context)..pop()..pop();
              }, 
              icon: Icon(Icons.check, color: Colors.green)
            ),
          ]),
          Image.file(File(imagePath)),
        ]),
    );
  }
}
