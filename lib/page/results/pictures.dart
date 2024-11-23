// view pictures of PSRDs, button to take more pics

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_template/core/widget/loading_dialog.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:camera/camera.dart';
import 'package:flutter_template/page/results/take-picture.dart';
import 'package:flutter_template/core/utils/path.dart';



class PicturesPage extends ConsumerStatefulWidget {

  @override
  _PicturesPageState createState() => _PicturesPageState();
}


class _PicturesPageState extends ConsumerState<PicturesPage> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context)!.pictures) ),
      body: SizedBox.expand(
        child: Column(children: [
          // TODO: Carousel View
          Text(I18n.of(context)!.takePictures),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: IconButton(
              iconSize: 150,
              onPressed: () {
                handleCameraPress(context); // launch camera page
              }, 
              icon: const Icon(Icons.photo_camera) 
            )
            // ElevatedButton(
            //   child: ImageIcon(image) //Icon(Icons.photo_camera),
            //   onPressed: () {
            //   },
            // )
          )
        ])
      )
        
    );
  }


  // handle camera press
  Future<void> handleCameraPress(BuildContext context) async {
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();
    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;

    // create directory
    var appDocDir = await PathUtils.getDocumentsDirPath();
    var pictureDir = '$appDocDir/pictures/${DateTime.now().millisecondsSinceEpoch}';
    debugPrint('pictureDir: $pictureDir');
    //var exists = await Directory('pictures/$pictureDir');
    await Directory(pictureDir).create(recursive: true);

    // go to camera screen
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return TakePictureScreen(camera: firstCamera, pictureDir: pictureDir);
      }
    ));
  }

}
