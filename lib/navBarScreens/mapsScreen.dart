// ignore_for_file: prefer_const_constructors, no_leading_underscores_for_local_identifiers, prefer_const_literals_to_create_immutables, unused_field, prefer_final_fields, sort_child_properties_last, unused_local_variable, unnecessary_null_comparison
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:miitti_app/commercialScreens/comact_detailspage.dart';
import 'package:miitti_app/constants/ad_banner.dart';
import 'package:miitti_app/constants/commercial_activity.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/constants/constants_anonymousDialog.dart';
import 'package:miitti_app/constants/constants_customButton.dart';
import 'package:miitti_app/constants/constants_styles.dart';
import 'package:miitti_app/constants/miitti_activity.dart';
import 'package:miitti_app/constants/person_activity.dart';
import 'package:miitti_app/createMiittiActivity/activity_details_page.dart';
import 'package:miitti_app/helpers/activity.dart';
import 'package:miitti_app/mapFilter.dart';
import 'package:miitti_app/onboardingScreens/onboarding.dart';
import 'package:miitti_app/provider/auth_provider.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';
import 'package:provider/provider.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final Location _location = Location();

  List<MiittiActivity> _activities = [];
  List<AdBanner> _ads = [];

  CameraPosition myCameraPosition = CameraPosition(
    target: LatLng(60.1699, 24.9325),
    zoom: 12,
    bearing: 0,
  );

  late MapboxMapController controller;

  int showOnMap = 0;

  bool isAnonymous = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeLocationAndSave();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initializeLocationAndSave() async {
    bool? _serviceEnabled;
    PermissionStatus? _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        //Show user a red dialog about opening the service
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        //Show user a red dialog about opening the  location
      }
    }

    // Get the current user location
    LocationData _locationData = await _location.getLocation();
    LatLng currentLatLng =
        LatLng(_locationData.latitude!, _locationData.longitude!);

    myCameraPosition = CameraPosition(
      target: currentLatLng,
      zoom: 12,
      tilt: 0,
      bearing: 0,
    );

    if (controller != null) {
      controller
          .animateCamera(CameraUpdate.newCameraPosition(myCameraPosition));
    }
  }

  void fetchActivities() async {
    AuthProvider ap = Provider.of<AuthProvider>(context, listen: false);
    List<MiittiActivity> activities = await ap.fetchActivities();
    setState(() {
      isAnonymous = ap.isAnonymous;
      _activities = activities.reversed.toList();
    });
    addGeojsonCluster(controller, _activities);
  }

  void fetchAd() async {
    AuthProvider provider = Provider.of<AuthProvider>(context, listen: false);
    List<AdBanner> ad = await provider.fetchAds();
    setState(() {
      _ads = ad;
    });
    if (_ads.isNotEmpty) {
      provider.addAdView(_ads[0].uid);
    }
  }

  static Future<void> addGeojsonCluster(
    MapboxMapController controller,
    List<MiittiActivity> myActivities,
  ) async {
    final List<Map<String, dynamic>> features = myActivities.map((activity) {
      return {
        "type": "Feature",
        "properties": {
          "id": activity.activityUid,
          'activityCategory':
              'images/${Activity.solveActivityId(activity.activityCategory)}.png',
        },
        "geometry": {
          "type": "Point",
          "coordinates": [
            activity.activityLong,
            activity.activityLati,
            0.0,
          ],
        }
      };
    }).toList();

    final Map<String, dynamic> geoJson = {
      "type": "FeatureCollection",
      "crs": {
        "type": "name",
        "properties": {"name": "urn:ogc:def:crs:OGC:1.3:CRS84"}
      },
      "features": features,
    };

    await controller.addSource(
      "activities",
      GeojsonSourceProperties(
        data: geoJson,
        cluster: true,
      ),
    );

    await controller.addSymbolLayer(
      "activities",
      'activities-symbols',
      SymbolLayerProperties(
        iconImage: [
          Expressions.caseExpression,
          [
            Expressions.boolean,
            [Expressions.has, 'point_count'],
            false
          ],
          'images/circlebackground.png',
          [Expressions.get, 'activityCategory'],
        ],
        iconSize: [
          Expressions.caseExpression,
          [
            Expressions.boolean,
            [Expressions.has, 'point_count'],
            false
          ],
          0.85.r,
          0.8.r,
        ],
        iconAllowOverlap: true,
        symbolSortKey: 10.0,
      ),
    );

    await controller.addSymbolLayer(
      "activities",
      "activities-count",
      SymbolLayerProperties(
        textField: [Expressions.get, 'point_count_abbreviated'],
        textColor: '#FFFFFF',
        textFont: ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
        textSize: [
          Expressions.step,
          [Expressions.get, 'point_count'],
          22.sp,
          5,
          24.sp,
          10,
          26.sp
        ],
      ),
    );
  }

  goToActivityDetailsPage(MiittiActivity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => activity is PersonActivity
            ? ActivityDetailsPage(
                myActivity: activity,
              )
            : ComActDetailsPage(myActivity: activity as CommercialActivity),
      ),
    );
  }

  void _onFeatureTapped({required LatLng coordinates}) {
    double zoomLevel = controller.cameraPosition!.zoom;
    int places = getPlaces(zoomLevel);

    double roundedLatitude =
        double.parse(coordinates.latitude.toStringAsFixed(places));
    double roundedLong =
        double.parse(coordinates.longitude.toStringAsFixed(places));

    for (MiittiActivity activity in _activities) {
      double roundedActivityLatitude =
          double.parse(activity.activityLati.toStringAsFixed(places));
      double roundedActivityLong =
          double.parse(activity.activityLong.toStringAsFixed(places));

      if (roundedActivityLatitude == roundedLatitude &&
          roundedActivityLong == roundedLong) {
        if (!isAnonymous) {
          goToActivityDetailsPage(activity);
        } else {
          showSnackBar(
              context,
              'Et ole vielä viimeistellyt profiiliasi, joten\n et voi käyttää vielä sovelluksen kaikkia ominaisuuksia.',
              ConstantStyles.orange);
        }
      }
    }
  }

  _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
    controller.onFeatureTapped.add(
        (id, point, coordinates) => _onFeatureTapped(coordinates: coordinates));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        showOnMap == 1
            ? showOnList(isAnonymous)
            : MapboxMap(
                styleString: MapboxStyles.MAPBOX_STREETS,
                myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
                onMapCreated: _onMapCreated,
                onMapClick: (point, latLng) =>
                    _onFeatureTapped(coordinates: latLng),
                onStyleLoadedCallback: () => fetchActivities(),
                initialCameraPosition: myCameraPosition,
                trackCameraPosition: true,
                tiltGesturesEnabled: false,
                myLocationEnabled: true,
                rotateGesturesEnabled: false,
              ),
        SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              createMainToggleSwitch(
                text1: 'Näytä kartalla',
                text2: 'Näytä listalla',
                initialLabelIndex: showOnMap,
                onToggle: (index) {
                  setState(
                    () {
                      showOnMap = index!;
                      if (index == 1) {
                        fetchAd();
                      }
                    },
                  );
                },
              ),
              GestureDetector(
                onTap: () async {
                  Map<String, dynamic>? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapFilter(),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      fetchActivities();
                    });
                  }
                },
                child: Container(
                  height: 60.h,
                  width: 60.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.lightRedColor,
                        AppColors.orangeColor,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.edit_location_alt,
                    color: Colors.white,
                    size: 30.r,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget showOnList(bool isAnonymous) {
    return Container(
      margin: EdgeInsets.only(top: 60.h),
      child: ListView.builder(
        itemCount: _activities.length + (_ads.isNotEmpty ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if (index == 1 && _ads.isNotEmpty) {
            return _ads[0].getWidget(context); // Display ad widget at index 1
          } else {
            int activityIndex =
                _ads.isNotEmpty && index > 1 ? index - 1 : index;
            MiittiActivity activity = _activities[activityIndex];
            String activityAddress = activity.activityAdress;

            List<String> addressParts = activityAddress.split(',');
            String cityName = addressParts[0].trim();

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              margin: EdgeInsets.all(10.0.w),
              child: Container(
                height: 150.h,
                decoration: BoxDecoration(
                  color: AppColors.wineColor,
                  border: Border.all(color: AppColors.purpleColor, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  children: [
                    Activity.getSymbol(activity),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              activity.activityTitle,
                              overflow: TextOverflow.ellipsis,
                              style: Styles.activityNameTextStyle,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                color: AppColors.lightPurpleColor,
                              ),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(
                                  activity.timeString,
                                  overflow: TextOverflow.ellipsis,
                                  style: Styles.sectionSubtitleStyle,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Icon(
                                Icons.location_on_outlined,
                                color: AppColors.lightPurpleColor,
                              ),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(
                                  cityName,
                                  overflow: TextOverflow.ellipsis,
                                  style: Styles.sectionSubtitleStyle,
                                ),
                              ),
                            ],
                          ),
                          MyElevatedButton(
                            width: 250.w,
                            height: 40.h,
                            onPressed: () {
                              if (!isAnonymous) {
                                goToActivityDetailsPage(activity);
                              } else {
                                showSnackBar(
                                    context,
                                    'Et ole vielä viimeistellyt profiiliasi, joten\n et voi käyttää vielä sovelluksen kaikkia ominaisuuksia.',
                                    ConstantStyles.orange);
                              }
                            },
                            child: Text(
                              "Näytä enemmän",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontFamily: 'Rubik',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  int getPlaces(double zoomLevel) {
    final zoomToDecimalPlaces = {
      20.0: 9, // Very close view, high precision
      19.0: 8,
      18.0: 7,
      17.0: 6,
      16.0: 5,
      15.0: 4,
      14.0: 3, // Medium zoom level
      13.0: 2,
      12.0: 2,
      11.0: 2,
      10.0: 2,
      9.0: 1, // Medium to high zoom level
      8.0: 1,
      7.0: 1,
      6.0: 1,
      5.0: 0, // Lower zoom level, less precision
      4.0: 0,
      3.0: 0,
    };

    return zoomToDecimalPlaces[zoomLevel.roundToDouble()] ?? 0;
  }
}
