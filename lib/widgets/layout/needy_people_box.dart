import 'package:flutter/material.dart';
import 'package:quick_social/pages/confirm_order.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';

class NeedyPeopleBox extends StatefulWidget {
  final String text;
  final IconData icon;
  final double textFontSize;
  final double height;
  final double width;
  final String informerUUID;
  final String distance;
  final String imageUrl;
  const NeedyPeopleBox(
      {super.key,
      required this.text,
      required this.icon,
      required this.textFontSize,
      required this.height,
      required this.width,
      required this.informerUUID,
      required this.distance,
      required this.imageUrl});

  @override
  State<StatefulWidget> createState() => _NeedyPeopleBox();
}

class _NeedyPeopleBox extends State<NeedyPeopleBox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.0080),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.height * 0.0080),
            child: Container(
                height: MediaQuery.of(context).size.height * 0.075,
                width: MediaQuery.of(context).size.height * 0.075,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.height * 0.075)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.height * 0.075),
                  child: Image.network(
                    'http://192.168.1.3:8080/${widget.imageUrl}',
                    fit: BoxFit.cover,
                  ),
                )),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.0080,
                      left: MediaQuery.of(context).size.height * 0.0080),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height *
                            widget.textFontSize),
                    maxLines: 2,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.0080,
                          left: MediaQuery.of(context).size.height * 0.0080),
                      child: Icon(
                        Icons.circle,
                        color: Colors.blue,
                        size: MediaQuery.of(context).size.height * 0.0080,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.0080,
                          left: MediaQuery.of(context).size.height * 0.0080),
                      child: Text(
                        () {
                          try {
                            final distanceValue =
                                double.tryParse(widget.distance) ?? 0.0;
                            return distanceValue < 1
                                ? '${(distanceValue * 1000).toStringAsFixed(0)} m'
                                : '${distanceValue.toStringAsFixed(2)} km';
                          } catch (e) {
                            return 'Distance unavailable';
                          }
                        }(),
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.014,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ConfirmOrder(
                            informerId: widget.informerUUID,
                          )));
            },
            child: const ButtonWidget(
                text: 'HELP',
                textFontSize: 0.012,
                height: 0.04,
                width: 0.16,
                borderRadius: 0.04),
          )
        ],
      ),
    );
  }
}
