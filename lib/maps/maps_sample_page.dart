import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_app/data/markers_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  List<MarkersModel> markersList = [];
  List<Marker> markers = <Marker>[];
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    addCustomIcon();
    getMarkers();
    super.initState();
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/images/loc2.png")
        .then((value) {
      setState(() {
        markerIcon = value;
      });
    });
  }

  Future<void> getMarkers() async {
    final String response = await rootBundle.loadString('assets/markers.json');
    final data = await json.decode(response);
    final List<dynamic> marks = data['result'];
    setState(() {
      markersList =
          marks.map((dynamic item) => MarkersModel.fromJson(item)).toList();

      for (final marker in markersList) {
        markers.add(Marker(
          markerId: MarkerId(marker.markerId!),
          position: LatLng(marker.latitude!, marker.longitude!),
          icon: markerIcon,
        ));
      }
    });
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR" + error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  placesAutoCompleteTextField() {
    return Container(
      color: Colors.red,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: searchController,
        googleAPIKey: "AIzaSyBdiu2pTHPeBJ4RxgDJuA0hVk89iLJIdnc",
        inputDecoration: const InputDecoration(
          hintText: "Search your location",
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        debounceTime: 400,
        countries: ["us", "ph"],
        isLatLngRequired: false,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          print("placeDetails" + prediction.lat.toString());
        },

        itemClick: (Prediction prediction) {
          searchController.text = prediction.description ?? "";
          searchController.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0));
        },
        seperatedBuilder: Divider(),
        // OPTIONAL// If you want to customize list view item builder
        itemBuilder: (context, index, Prediction prediction) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(
                  width: 7,
                ),
                Expanded(child: Text("${prediction.description ?? ""}"))
              ],
            ),
          );
        },

        isCrossBtnShown: true,

        // default 600 ms ,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // GoogleMap(
          //   initialCameraPosition: _kGooglePlex,
          //   myLocationEnabled: true,
          //   onMapCreated: (GoogleMapController controller) {
          //     _controller.complete(controller);
          //   },
          //   markers: Set.of(markers),
          // ),
          Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Positioned(top: 10, child: placesAutoCompleteTextField())
          // Center(
          //     child: TextButton(
          //   child: const Text('Get My Location'),
          //   onPressed: () async {
          //     getUserCurrentLocation().then((value) async {
          //       print(value.latitude.toString() +
          //           " " +
          //           value.longitude.toString());

          //       markers.add(Marker(
          //         markerId: MarkerId("2"),
          //         position: LatLng(value.latitude, value.longitude),
          //         icon: markerIcon,
          //       ));

          //       CameraPosition cameraPosition = new CameraPosition(
          //         target: LatLng(value.latitude, value.longitude),
          //         zoom: 14,
          //       );

          //       final GoogleMapController controller = await _controller.future;
          //       controller.animateCamera(
          //           CameraUpdate.newCameraPosition(cameraPosition));
          //       setState(() {});
          //     });
          //   },
          // )),
        ],
      ),
    );
  }
}
