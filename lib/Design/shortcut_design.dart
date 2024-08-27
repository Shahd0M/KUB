import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class  ShortcutDesign extends StatelessWidget {
  String? imagePath;
  String? title;
  ShortcutDesign(this.imagePath,this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width*.25,
      height: MediaQuery.of(context).size.height*.30,
      margin: const EdgeInsets.only(right: 3, left: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage(imagePath!),
          fit: BoxFit.fill,
        ),
        color: const Color.fromRGBO(13, 10, 83, 1.0),
      ),
    );
  }
}
