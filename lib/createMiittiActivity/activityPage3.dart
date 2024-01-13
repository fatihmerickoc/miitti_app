// ignore_for_file: unnecessary_null_comparison, prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as location;
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:miitti_app/constants/person_activity.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';

import '../constants/constants.dart';

class ActivityPage3 extends StatefulWidget {
  const ActivityPage3({
    Key? key,
    required this.activity,
    required this.onActivityDataChanged,
    required this.controller,
  }) : super(key: key);

  final PersonActivity activity;
  final Function(PersonActivity) onActivityDataChanged;
  final PageController controller;

  @override
  State<ActivityPage3> createState() => _ActivityPage3State();
}

class _ActivityPage3State extends State<ActivityPage3> {
  late MapboxMapController controller;
  final location.Location _location = location.Location();

  CameraPosition myCameraPosition = const CameraPosition(
    target: LatLng(60.166082, 24.939744),
    zoom: 16,
  );

  LatLng? markerCoordinates;

  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeLocationAndSave();
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

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            getSomeSpace(10),
            getMiittiActivityText(
                'Valitse tapaamispaikka liikuttamalla karttaa'),
            getSomeSpace(10),
            SizedBox(
              height: 400.h,
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
            Expanded(
              child: SizedBox(),
            ),
            MyElevatedButton(
              onPressed: () async {
                markerCoordinates = controller.cameraPosition!.target;

                if (markerCoordinates != null) {
                  double latitude = markerCoordinates!.latitude;
                  double longitude = markerCoordinates!.longitude;

                  widget.activity.activityLati = latitude;
                  widget.activity.activityLong = longitude;
                  widget.activity.activityAdress =
                      await getAddressFromCoordinates(latitude, longitude);

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
                      style: Styles.bodyTextStyle,
                    ),
            ),
            getSomeSpace(25),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text(
                "Peruuta",
                style: Styles.bodyTextStyle,
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
