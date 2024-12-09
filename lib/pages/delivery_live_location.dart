import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gMaps;
import 'package:quick_social/pages/home_page.dart';
import 'package:quick_social/provider/live_location_provider.dart';
import 'package:quick_social/services/closest_informer_service.dart';
import 'package:quick_social/widgets/capture_post_image.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';

class LiveLocationTracker extends StatefulWidget {
  final String informerId;
  const LiveLocationTracker({super.key, required this.informerId});

  @override
  LiveLocationTrackerState createState() => LiveLocationTrackerState();
}

class LiveLocationTrackerState extends State<LiveLocationTracker> {
  gMaps.GoogleMapController? mapController;
  bool _isTextVisible = false;
  // ignore: unused_field
  bool _showInitialMessage = true;
  bool _showCurrentAddress = false;
  late gMaps.LatLng destinationPosition;
  bool showDeliveryDoneButton = false;
  Set<gMaps.Marker> _markers = {};
  Set<gMaps.Polyline> _polylines = {};
  final ClosestInformerService _service = ClosestInformerService();
  Map<String, dynamic> closestInformerData = {};
  Map<String, dynamic> updateFields = {
    'status': 'delivered',
  };
  Map<String, dynamic> updateStatusFields = {
    'status': 'active',
  };
  gMaps.BitmapDescriptor markerIcon = gMaps.BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    fetchData();
    addCustomMarkerIcon();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false)
          .requestLocationPermissionAndGetCurrentLocation();
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showInitialMessage = false;
        });
      }
    });
  }

  Future<void> fetchData() async {
    try {
      var data =
          await _service.getClosestInformerDetails(context, widget.informerId);

      if (data != null && data.isNotEmpty) {
        setState(() {
          closestInformerData = data[0];

          destinationPosition = gMaps.LatLng(
            double.parse(closestInformerData['latitude'] ?? '0.0'),
            double.parse(closestInformerData['longitude'] ?? '0.0'),
          );
        });
      } else {
        throw Exception('No data available or unexpected structure');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  void addCustomMarkerIcon() {
    gMaps.BitmapDescriptor.asset(const ImageConfiguration(size: Size(40, 40)),
            'assets/images/maps-and-flags.png')
        .then((icon) {
      setState(() {
        markerIcon = icon;
      });
    });
  }

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('EEEE, MMMM d, yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String formatTime(String time) {
    try {
      DateFormat inputFormat = DateFormat('HH:mm:ss');
      DateFormat outputFormat = DateFormat('hh:mm a');
      DateTime parsedTime = inputFormat.parse(time);
      return outputFormat.format(parsedTime);
    } catch (e) {
      return 'Invalid Time';
    }
  }

  String calculateDistance(String distance) {
    try {
      final distanceValue = double.tryParse(distance) ?? 0.0;
      return distanceValue < 1
          ? '${(distanceValue * 1000).toStringAsFixed(0)} m'
          : '${distanceValue.toStringAsFixed(2)} km';
    } catch (e) {
      return 'Distance unavailable';
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(gMaps.GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _handleTap() {
    setState(() {
      _isTextVisible = false;
    });
  }

  void _handleDoubleTap() {
    setState(() {
      _isTextVisible = true;
      _showCurrentAddress = true;

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showCurrentAddress = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Consumer<LocationProvider>(
                builder: (context, locationProvider, _) {
                  gMaps.LatLng? currentPosition =
                      locationProvider.currentPosition;
                  String? currentAddress = locationProvider.currentAddress;

                  if (currentPosition != null &&
                      destinationPosition.latitude != 0.0 &&
                      destinationPosition.longitude != 0.0) {
                    double distance = Geolocator.distanceBetween(
                      currentPosition.latitude,
                      currentPosition.longitude,
                      destinationPosition.latitude,
                      destinationPosition.longitude,
                    );

                    if (distance < 60) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!showDeliveryDoneButton) {
                          setState(() {
                            showDeliveryDoneButton = true;
                          });
                        }
                      });
                    }

                    if (destinationPosition.latitude != 0.0 &&
                        destinationPosition.longitude != 0.0) {
                      _polylines = {
                        gMaps.Polyline(
                          polylineId: const gMaps.PolylineId('route'),
                          points: [currentPosition, destinationPosition],
                          color: Colors.blue,
                          width: 5,
                        )
                      };
                    }
                    _markers = {
                      gMaps.Marker(
                        markerId: const gMaps.MarkerId('current_location'),
                        position: currentPosition,
                        infoWindow: gMaps.InfoWindow(
                          title: 'Current Location',
                          snippet:
                              'Latitude: ${currentPosition.latitude}, Longitude: ${currentPosition.longitude}',
                        ),
                      ),
                      gMaps.Marker(
                        markerId: const gMaps.MarkerId('destination_location'),
                        position: destinationPosition,
                        infoWindow: gMaps.InfoWindow(
                          title: 'Destination',
                          snippet:
                              'Latitude: ${destinationPosition.latitude}, Longitude: ${destinationPosition.longitude}',
                        ),
                        icon: markerIcon,
                      ),
                    };

                    mapController?.moveCamera(
                        gMaps.CameraUpdate.newLatLng(currentPosition));
                  }

                  return GestureDetector(
                    onTap: _handleTap,
                    onDoubleTap: _handleDoubleTap,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          currentPosition == null
                              ? const Center(child: CircularProgressIndicator())
                              : gMaps.GoogleMap(
                                  onMapCreated: _onMapCreated,
                                  initialCameraPosition: gMaps.CameraPosition(
                                    target: currentPosition,
                                    zoom: 15,
                                  ),
                                  myLocationEnabled: true,
                                  compassEnabled: true,
                                  mapType: gMaps.MapType.normal,
                                  markers: _markers,
                                  polylines: _polylines,
                                ),
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            bottom: _isTextVisible ? 10.0 : -100.0,
                            left: 10.0,
                            right: 10.0,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: _isTextVisible ? 1.0 : 0.0,
                              child: _showCurrentAddress
                                  ? Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: currentAddress != null
                                          ? Text(
                                              currentAddress,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            )
                                          : const Text(
                                              'Location not available',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                    )
                                  : const SizedBox(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 0,
                child: Container(
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                                MediaQuery.of(context).size.height * 0.025),
                            topRight: Radius.circular(
                                MediaQuery.of(context).size.height * 0.025))),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Divider(
                            color: Colors.white,
                          ),
                          Padding(
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.height * 0.015),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height *
                                      0.075,
                                  width: MediaQuery.of(context).size.height *
                                      0.075,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          MediaQuery.of(context).size.height *
                                              0.075)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.height *
                                            0.075),
                                    child:
                                        closestInformerData['imageurl'] != null
                                            ? Image.network(
                                                'http://192.168.1.4:8080/${closestInformerData['imageurl']}',
                                                scale: 1.0,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.network(
                                                'https://cdn-icons-png.flaticon.com/512/681/681494.png',
                                                scale: 1.0,
                                                fit: BoxFit.cover,
                                              ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.height *
                                      0.015,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${closestInformerData['location'] ?? 'N/A'}',
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.020,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                        maxLines: 3,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            color: Colors.blue,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.010,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.008,
                                          ),
                                          Text(
                                            '${closestInformerData['count'] ?? 'N/A'} found',
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.016,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left:
                                    MediaQuery.of(context).size.height * 0.015,
                                bottom:
                                    MediaQuery.of(context).size.height * 0.015),
                            child: Row(
                              children: [
                                const Icon(Icons.directions_walk,
                                    color: Colors.red),
                                Text(
                                  ' Just ${calculateDistance(closestInformerData['distance'] ?? "no distance found")} away from you',
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.018,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left:
                                    MediaQuery.of(context).size.height * 0.015,
                                bottom:
                                    MediaQuery.of(context).size.height * 0.015),
                            child: Text(
                              closestInformerData['description'] ??
                                  'No Description',
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.018,
                                  color: Colors.black),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.height * 0.015),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatDate(
                                      closestInformerData['capture_date'] ??
                                          ''),
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.016),
                                ),
                                Text(
                                  formatTime(
                                      closestInformerData['capture_time'] ??
                                          'N/A'),
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.016),
                                ),
                              ],
                            ),
                          ),
                          const Divider()
                        ],
                      ),
                    )),
              ),
              Positioned(
                right: 15,
                bottom: 255,
                child: Row(
                  children: [
                    if (showDeliveryDoneButton)
                      GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (_) => GiffyDialog(
                                    giffy: Image.network(
                                        'https://www.forrest-recruitment.co.uk/wp-content/uploads/2021/03/new-post-gif.gif'),
                                    title: Text('ADD POST',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.022,
                                            fontWeight: FontWeight.w600)),
                                    entryAnimation: EntryAnimation.bottom,
                                    content: Text(
                                      'DO you want to add post?',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.018),
                                    ),
                                    actions: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                              onTap: () {
                                                _service.updateStatusInformer(
                                                    closestInformerData[
                                                        'informer_uuid'],
                                                    updateFields);
                                                _service
                                                    .updateStatusClosestInformer(
                                                        widget.informerId,
                                                        updateFields);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const CaptureImageOrVideoPage()));
                                              },
                                              child: Text(
                                                'Add post',
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.016),
                                              )),
                                          GestureDetector(
                                              onTap: () {
                                                _service.updateStatusInformer(
                                                    closestInformerData[
                                                        'informer_uuid'],
                                                    updateFields);
                                                _service
                                                    .updateStatusClosestInformer(
                                                        widget.informerId,
                                                        updateFields);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const HomePage()));
                                              },
                                              child: Text(
                                                'Not interested',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.016),
                                              )),
                                        ],
                                      )
                                    ],
                                  ));
                        },
                        child: const ButtonWidget(
                          borderRadius: 0.06,
                          height: 0.06,
                          width: 0.3,
                          text: 'DELIVER',
                          textFontSize: 0.018,
                        ),
                      ),
                    GestureDetector(
                      onTap: () {
                        _service.updateStatusInformer(
                            closestInformerData['informer_uuid'],
                            updateStatusFields);
                        _service.updateStatusClosestInformer(
                            widget.informerId, updateStatusFields);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()));
                      },
                      child: const ButtonWidget(
                        borderRadius: 0.06,
                        height: 0.06,
                        width: 0.3,
                        text: 'CANCEL',
                        textFontSize: 0.018,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
