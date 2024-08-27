
import 'package:flutter/material.dart';

import '../Screens/User Screens/user_search_screen.dart';

class SearchShortcut extends StatelessWidget {
  String title;
  SearchShortcut(this.title, {super.key});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    SearchScreen(title)));
      },
      child: Container(
        height: MediaQuery.of(context).size.height*.04,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 198, 50, 1.0),
          border: Border.all(
            color: Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: Colors.white,
            ),
            Text(title!,
              style: const TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
