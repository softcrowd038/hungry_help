import 'package:flutter/material.dart';

class ButtonWidget extends StatefulWidget {
  final String text;
  final double textFontSize;
  final double height;
  final double width;
  final double borderRadius;

  const ButtonWidget({
    super.key,
    required this.text,
    required this.textFontSize,
    required this.height,
    required this.width,
    required this.borderRadius,
  });
  @override
  State<StatefulWidget> createState() => _ButonWidget();
}

class _ButonWidget extends State<ButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.012),
      child: GestureDetector(
        child: Container(
          height: MediaQuery.of(context).size.height * widget.height,
          width: MediaQuery.of(context).size.width * widget.width,
          decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.height * widget.borderRadius)),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize:
                      MediaQuery.of(context).size.height * widget.textFontSize),
            ),
          ),
        ),
      ),
    );
  }
}
