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
import 'package:flutter_template/utils/ea-utils.dart';
import 'package:flutter_template/controller/result.dart';



class PicturesPage extends ConsumerStatefulWidget {

  @override
  _PicturesPageState createState() => _PicturesPageState();
}


class _PicturesPageState extends ConsumerState<PicturesPage> {

  @override
  void initState() {
    super.initState();
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
          // FutureBuilder(
          //   future: electionsQueryDone, 
          //   builder: (context, snapshot) {
          //     if (!snapshot.hasData) {
          //       return LoadingDialog(
          //         showContent: false,
          //         backgroundColor: Colors.black38,
          //         loadingView: SpinKitCircle(color: Colors.white),
          //       );
          //     } else if (snapshot.hasError) {
          //       debugPrint('Futurebuilder error getting electoral area options');
          //       return Text(I18n.of(context)!.somethingWentWrong);
          //     }
          //     // return loaded data
          //     return Column(
          //       children: [
          //         _electionDropdown( underline: Container() ),
          //       ],
          //     );
          //   }
          // ),

          (_electionDropdownState == electionDropdownStates.hidden) ? SizedBox.shrink() 
          : (_electionDropdownState == electionDropdownStates.pending) ? LoadingDialog(showContent: false,
            backgroundColor: Colors.black38, loadingView: SpinKitCircle(color: Colors.white))
          : Column(
            children: [_electionDropdown( underline: Container() )]
          ),

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
    onChanged: (Election? newValue) {
      setState(() {
        _selectedElection = newValue;
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

}


// enum for election dropdown state
enum electionDropdownStates {
  hidden, // hide until polling station chosen
  pending, // querying backend for elections
  shown // display
}
