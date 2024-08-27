import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  String imagepath1;
  PostWidget(this.imagepath1) ;


  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Image.asset(imagepath1),
            IconButton(
              onPressed: (){},
              icon: CircleAvatar(
                backgroundColor: Colors.black,
                child:
                Icon(Icons.favorite ,
                  color: Color.fromRGBO(255, 198, 50, 1),
                ),
              ),
            ) ,
          ],
        ),
      ],
    );
  }
}
