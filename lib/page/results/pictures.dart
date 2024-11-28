// view pictures of PSRDs, button to take more pics

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_template/core/utils/toast.dart';
import 'package:flutter_template/core/widget/loading_dialog.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:camera/camera.dart';
import 'package:flutter_template/page/results/take-picture.dart';
import 'package:flutter_template/core/utils/path.dart';
import 'package:flutter_template/utils/ea-utils.dart';
import 'package:flutter_template/controller/result.dart';
import 'package:flutter_template/utils/sputils.dart';



class PicturesPage extends ConsumerStatefulWidget {

  @override
  _PicturesPageState createState() => _PicturesPageState();
}


class _PicturesPageState extends ConsumerState<PicturesPage> {

  @override
  void initState() {
    super.initState();
    readPictureDir();
    stationsQueryDone = getPollingStations();
  }

  ResultController _resultController = ResultController(); // get functions

  // for future builders. Set when done with query for polling stations (electoral areas), elections done
  Future<String>? stationsQueryDone;
  //Future<String>? electionsQueryDone;
  var _electionDropdownState = electionDropdownStates.hidden;

  // polling station/electoral area dropdown
  ElectoralArea? _selectedStation;
  List<DropdownMenuItem<ElectoralArea>> _stationChoices = [];

  // election dropdown
  Election? _selectedElection;
  List<DropdownMenuItem<Election>> _electionChoices = [];

  String? pictureDir; // directory where pictures of PSRDs are kept
  // list of images of PSRDs
  List<String> picturePaths = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context)!.pictures) ),
      body: SizedBox.expand(
        child: Column(children: [
          // selector/ dropdown for polling station
          FutureBuilder(
            future: stationsQueryDone,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return LoadingDialog(
                  showContent: false,
                  backgroundColor: Colors.black38,
                  loadingView: SpinKitCircle(color: Colors.white),
                );
              } else if (snapshot.hasError) {
                debugPrint('Futurebuilder error getting electoral area options');
                return Text(I18n.of(context)!.somethingWentWrong);
              }
              
              // return loaded data
              return Column(
                children: [
                  _stationDropdown( underline: Container() ),
                ],
              );
              
            }
          ),
          // selector for election
          (_electionDropdownState == electionDropdownStates.hidden) ? SizedBox.shrink() 
          : (_electionDropdownState == electionDropdownStates.pending) ? LoadingDialog(showContent: false,
            backgroundColor: Colors.black38, loadingView: SpinKitCircle(color: Colors.white))
          : Column(
            children: [_electionDropdown( underline: Container() )]
          ),

          // Carousel View for pictures
          (picturePaths.length == 0) ? SizedBox.shrink() :
          //Expanded(
          ConstrainedBox(constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              //itemExtent: 100,
              shrinkWrap: true,
              itemCount: picturePaths.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Image.file(File(picturePaths[index])) //Image.asset(picturePaths[index]);
                );
              }
            ),
          ),

          //
          Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(),),
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

    var spf = await SPUtils.init();
    // set name of picture directory
    // first check if already in shared prefs
    var pictureDir_0 = await spf!.getString('pictureDir');
    var appDocDir = await PathUtils.getDocumentsDirPath();
    pictureDir = (pictureDir_0 != null) ? pictureDir_0 : '$appDocDir/pictures/${DateTime.now().millisecondsSinceEpoch}';
    debugPrint('pictureDir: $pictureDir');

    // save current polling station and election to shared prefs
    
    try {
      await spf.setString('stationId', _selectedStation!.id);
      await spf.setString('electionId', _selectedElection!.id);
      await spf.setString('pictureDir', pictureDir!);
    } catch (exc) {
      debugPrint('cameraPress exc: $exc');
      ToastUtils.error(I18n.of(context)!.selectStationElection);
      return;
    }

    // create directory
    await Directory(pictureDir!).create(recursive: true);

    // go to camera screen
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return TakePictureScreen(camera: firstCamera, pictureDir: pictureDir!);
      }
    ));

    await readPictureDir(); // add new pictures
  }


  // dropdown with list of electoral areas. Populated after query
  Widget _stationDropdown({Widget? underline, Widget? icon, TextStyle? style,
    TextStyle? hintStyle, Color? dropdownColor, Color? iconEnabledColor,
  }) => DropdownButton<ElectoralArea>(
    value: _selectedStation,
    underline: underline,
    icon: icon,
    dropdownColor: dropdownColor,
    style: style,
    iconEnabledColor: iconEnabledColor, 
    onChanged: (ElectoralArea? newValue) {
      setState(() {
        _selectedStation = newValue;
        _electionDropdownState = electionDropdownStates.pending; // show pending dialog for elections dropdown
      });
      getStationElections(); // get election types for this station
    },
    hint: Text( I18n.of(context)!.selectElectoralArea('electoral area') ),
    items: _stationChoices
  );


  // dropdown with list of elections
  Widget _electionDropdown({Widget? underline, Widget? icon, TextStyle? style,
    TextStyle? hintStyle, Color? dropdownColor, Color? iconEnabledColor,
  }) => DropdownButton<Election>(
    value: _selectedElection,
    underline: underline,
    icon: icon,
    dropdownColor: dropdownColor,
    style: style,
    iconEnabledColor: iconEnabledColor, 
    onChanged: (Election? newValue) async {
      // first remove pictureDir from shared prefs, election changed
      var spf = await SPUtils.init();
      await spf!.remove('pictureDir');
      // update election widget
      setState(() {
        _selectedElection = newValue;
        picturePaths = []; // remove pictures from list view
      });
    },
    hint: Text( I18n.of(context)!.selectElection ),
    items: _electionChoices
  );


  Future<String> getPollingStations() async {
    var stationsRet = await _resultController.getMyStations(context);
    debugPrint('stationsRet pictures.dart: $stationsRet');
    List<DropdownMenuItem<ElectoralArea>> stations = [];

    for (var station in stationsRet) {
      stations.add( new DropdownMenuItem(value: station, 
        child: Text(station.name)
      ));
    }

    setState((){
      _stationChoices = stations;
    });

    return "done";
  }


  Future getStationElections() async {
    var electionsRet = await _resultController.getStationElections(context, _selectedStation!.id);
    List<DropdownMenuItem<Election>> elections = [];

    for (var election in electionsRet) {
      elections.add( new DropdownMenuItem(value: election,
        child: Text(election.type))
      );
    }

    setState((){
      _electionDropdownState = electionDropdownStates.shown;
      _electionChoices = elections;
    });
  }

  // read directory containing pictures
  Future<void> readPictureDir() async {
    debugPrint('readPictureDir called...');
    if (pictureDir == null) {
      var spf = await SPUtils.init();
      pictureDir = await spf?.getString('pictureDir');
      debugPrint('pictureDir: $pictureDir');
      if (pictureDir == null) return;
    }

    // read directory
    final dir = Directory(pictureDir!);
    final List<FileSystemEntity> entities = await dir.list().toList();
    debugPrint('entities: $entities');
    List<String> files = [];
    for (var entity in entities) {
      files.add(entity.path);
    }
    debugPrint('pictures: $files');
    debugPrint('number of pictures: ${files.length}');

    setState((){
      picturePaths = files;
    });
  }

}


// enum for election dropdown state
enum electionDropdownStates {
  hidden, // hide until polling station chosen
  pending, // querying backend for elections
  shown // display
}
