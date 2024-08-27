import 'package:flutter/material.dart';

class CustomChat extends StatelessWidget {
  const CustomChat({super.key});

  @override

  Widget build(BuildContext context) {

    return ListTile(

      leading: CircleAvatar(
        radius: 25,
      ),
      title: Text("Brand Name",
        style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold
        ),
      ),

      subtitle: Text("How much is this product ? ",
        style: TextStyle(
          fontSize: 13,
        ),
      ),
    );
  }

}