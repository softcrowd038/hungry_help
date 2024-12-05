import 'package:flutter/material.dart';

class RoleBox extends StatefulWidget {
  final String text;
  final IconData icon;
  final double textFontSize;
  final double height;
  final double width;
  const RoleBox(
      {super.key,
      required this.text,
      required this.icon,
      required this.textFontSize,
      required this.height,
      required this.width});

  @override
  State<StatefulWidget> createState() => _RoleBox();
}

class _RoleBox extends State<RoleBox> {
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
                  blurRadius: 8,
                  spreadRadius: 3,
                  color: Colors.grey.withOpacity(0.4))
            ],
            borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.height * 0.015)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: MediaQuery.of(context).size.height * 0.080,
            ),
            Text(
              widget.text,
              style: TextStyle(
                  fontSize:
                      MediaQuery.of(context).size.height * widget.textFontSize),
            )
          ],
        ),
      ),
    );
  }
}
