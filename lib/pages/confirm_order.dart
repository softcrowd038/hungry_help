import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/pages/delivery_live_location.dart';
import 'package:quick_social/services/closest_informer_service.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';

class ConfirmOrder extends StatefulWidget {
  final String informerId;
  const ConfirmOrder({super.key, required this.informerId});

  @override
  State<StatefulWidget> createState() => _ConfirmOrder();
}

class _ConfirmOrder extends State<ConfirmOrder> {
  final ClosestInformerService _service = ClosestInformerService();
  Map<String, dynamic> closestInformerData = {};
  Map<String, dynamic> updateFields = {
    'status': 'confirmed',
  };

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      var data =
          await _service.getClosestInformerDetails(context, widget.informerId);

      if (data != null && data.isNotEmpty) {
        setState(() {
          closestInformerData = data[0];
        });
      } else {
        throw Exception('No data available or unexpected structure');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: closestInformerData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).size.height * 0.008,
                                left:
                                    MediaQuery.of(context).size.height * 0.015,
                                right:
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
                          Image.network(
                            '$imageBaseUrl${closestInformerData['imageurl']}',
                            scale: 1.0,
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.height * 0.50,
                            width: MediaQuery.of(context).size.width,
                          ),
                          Padding(
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.height * 0.015),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.place,
                                  color: Colors.red,
                                  size: MediaQuery.of(context).size.height *
                                      0.035,
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
                                            '${closestInformerData['count'] ?? 'N/A'} found / ${calculateDistance(closestInformerData['distance'])} away',
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
                            child: Text(
                              closestInformerData['description'] ??
                                  'No Description',
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.018,
                                  color: Colors.black),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _service.updateStatusInformer(
                                  closestInformerData['informer_uuid'],
                                  updateFields);
                              _service.updateStatusClosestInformer(
                                  widget.informerId, updateFields);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LiveLocationTracker(
                                        informerId: closestInformerData[
                                            'closest_uuid'])),
                              );
                            },
                            child: const ButtonWidget(
                              borderRadius: 0.06,
                              height: 0.06,
                              width: 1,
                              text: 'START DELIVERY',
                              textFontSize: 0.018,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
