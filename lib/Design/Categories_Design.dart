import 'package:flutter/material.dart';

import '../Screens/User Screens/user_search_screen.dart';

class CategoriesDesign extends StatelessWidget {
  final String imagePath;
  final String title;

  const CategoriesDesign(this.imagePath, this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen(title)),
            );
          },
          child: Container(
            // margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover, // Adjust the image aspect ratio to cover the container
              ),
            ),
            width: double.infinity, // Take the full available width
            // height: 120, // Set the desired height for the rectangle
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.black.withOpacity(0.5), // Adjust the opacity value here (0.5 for 50% opacity)
              ),
              child: Center( // Center the title vertically
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

