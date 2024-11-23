// take pictures of documents

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_template/core/widget/loading_dialog.dart';
import 'package:flutter_template/generated/i18n.dart';



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
                // launch camera page
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

}
