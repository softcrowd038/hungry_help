import 'package:flutter/material.dart';
import 'package:quick_social/pages/confirm_order.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';

class NeedyPeopleBox extends StatefulWidget {
  final String text;
  final IconData icon;
  final double textFontSize;
  final double height;
  final double width;
  const NeedyPeopleBox(
      {super.key,
      required this.text,
      required this.icon,
      required this.textFontSize,
      required this.height,
      required this.width});

  @override
  State<StatefulWidget> createState() => _NeedyPeopleBox();
}

class _NeedyPeopleBox extends State<NeedyPeopleBox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: MediaQuery.of(context).size.height * widget.height,
        width: MediaQuery.of(context).size.height * widget.width,
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                  spreadRadius: 1,
                  color: Colors.black.withOpacity(0.2))
            ],
            borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.height * 0.015)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              widget.icon,
              size: MediaQuery.of(context).size.height * 0.030,
              color: Colors.red,
            ),
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.0080),
                child: Text(
                  widget.text,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height *
                          widget.textFontSize),
                  maxLines: 2,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ConfirmOrder()));
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
      ),
    );
  }
}
