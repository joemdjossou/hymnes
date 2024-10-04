import 'package:flutter/material.dart';

class Slide {
  String title;
  String description;
  String pathImage;
  Color backgroundColor;
  Slide({
    required this.title,
    required this.description,
    required this.pathImage,
    required this.backgroundColor,
  });

  Widget toWidget() {
    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(pathImage),
          Text(title),
          Text(description),
        ],
      ),
    );
  }
}
