// ignore_for_file: unnecessary_null_comparison, prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as location;
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:miitti_app/data/commercial_spot.dart';
import 'package:miitti_app/data/person_activity.dart';
import 'package:miitti_app/utils/auth_provider.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:miitti_app/widgets/my_elevated_button.dart';
import 'package:provider/provider.dart';

class AP3Location extends StatefulWidget {
  const AP3Location({
    super.key,
    required this.activity,
    required this.onActivityDataChanged,
    required this.controller,
  });

  final PersonActivity activity;
  final Function(PersonActivity) onActivityDataChanged;
  final PageController controller;

  @override
  State<AP3Location> createState() => _AP3LocationState();
}

class _AP3LocationState extends State<AP3Location> {
  late MapboxMapController controller;
  final location.Location _location = location.Location();

  CameraPosition myCameraPosition = const CameraPosition(
    target: LatLng(60.166082, 24.939744),
    zoom: 16,
  );

  LatLng? markerCoordinates;

  bool isLoading = false;

  List<CommercialSpot> spots = [];
  int selectedSpot = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeLocationAndSave();
    fetchSpots();
  }

  void initializeLocationAndSave() async {
    bool? serviceEnabled;
    PermissionStatus? permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
    }

    LocationData locationData = await _location.getLocation();
    LatLng currentLatLng =
        LatLng(locationData.latitude!, locationData.longitude!);

    setState(() {
      myCameraPosition = CameraPosition(
        target: currentLatLng,
        zoom: 16,
      );
    });

    if (controller != null) {
      controller
          .animateCamera(CameraUpdate.newCameraPosition(myCameraPosition));
    }
  }

  void fetchSpots() {
    AuthProvider ap = Provider.of<AuthProvider>(context, listen: false);

    ap.fetchCommercialSpots().then((value) {
      setState(() {
        spots = value;
      });
    });
  }

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            getSomeSpace(20),
            getMiittiActivityText(
                'Valitse tapaamispaikka liikuttamalla karttaa'),
            getSomeSpace(10),
            SizedBox(
              height: 340.w,
              width: 350.w,
              child: Stack(
                children: [
                  MapboxMap(
                    styleString: MapboxStyles.MAPBOX_STREETS,
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: true,
                    trackCameraPosition: true,
                    compassEnabled: false,
                    gestureRecognizers: {
                      Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer())
                    },
                    myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
                    initialCameraPosition: myCameraPosition,
                    //if map is moved, and selected spot > -1, selected spot is set to -1
                    onCameraIdle: () {
                      for (int i = 0; i < spots.length; i++) {
                        bool onSpot = (spots[i].lati -
                                        controller
                                            .cameraPosition!.target.latitude)
                                    .abs() <
                                0.0002 &&
                            (spots[i].long -
                                        controller
                                            .cameraPosition!.target.longitude)
                                    .abs() <
                                0.0002;
                        if (onSpot) {
                          setState(() {
                            selectedSpot = i;
                          });
                          return;
                        }
                      }

                      setState(() {
                        selectedSpot = -1;
                      });
                    },
                  ),
                  Center(
                    child: Image.asset(
                      'images/location.png',
                      height: 65.h,
                    ),
                  ),
                ],
              ),
            ),
            getSomeSpace(20),
            spots.isNotEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 20.w),
                      Text(
                        "Valitse MiittiSpot:",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                            fontFamily: "Rubik"),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            spots.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: spots.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                            onTap: () => setState(() {
                                  selectedSpot = index;
                                  controller.animateCamera(
                                      CameraUpdate.newLatLngZoom(
                                          LatLng(spots[index].lati,
                                              spots[index].long),
                                          16));
                                }),
                            child:
                                spots[index].getWidget(index == selectedSpot));
                      },
                    ),
                  )
                : Expanded(child: SizedBox()),
            MyElevatedButton(
              width: 340.w,
              height: 60.h,
              onPressed: () async {
                markerCoordinates = controller.cameraPosition!.target;

                if (markerCoordinates != null) {
                  double latitude = markerCoordinates!.latitude;
                  double longitude = markerCoordinates!.longitude;

                  widget.activity.activityLati = latitude;
                  widget.activity.activityLong = longitude;
                  widget.activity.activityAdress = selectedSpot > -1
                      ? spots[selectedSpot].address
                      : await getAddressFromCoordinates(latitude, longitude);

                  widget.onActivityDataChanged(widget.activity);

                  widget.controller.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.linear,
                  );
                } else {
                  showSnackBar(
                      context,
                      'Tapaamispaikka ei voi olla tyhjä, yritä uudeelleen',
                      Colors.red.shade800);
                }
              },
              child: isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      "Seuraava",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        fontFamily: "Rubik",
                      ),
                    ),
            ),
            getSomeSpace(20),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text(
                "Peruuta",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                  fontFamily: "Rubik",
                ),
              ),
            ),
            getSomeSpace(20),
          ],
        ),
      ),
    );
  }

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      setState(() {
        isLoading == true;
      });
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks != null && placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String address = placemark.subLocality!.isEmpty
            ? '${placemark.locality}'
            : '${placemark.subLocality}, ${placemark.locality}';
        setState(() {
          isLoading == false;
        });
        return address;
      } else {
        setState(() {
          isLoading == false;
        });
        return "Suomi";
      }
    } catch (e) {
      setState(() {
        isLoading == false;
      });
      return "Suomi";
    }
  }
}
