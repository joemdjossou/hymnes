import 'package:flutter/material.dart';

class Slide {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;

  Slide({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
  });

  Widget toWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(16.0), // Adjust the radius as needed
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Shadow color
                    blurRadius: 8, // Blur radius
                    offset: Offset(0, 4), // Offset for the shadow
                  ),
                ],
              ),
              clipBehavior: Clip
                  .antiAlias, // Ensures the image respects the border radius
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
