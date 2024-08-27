import 'package:authentication/Screens/User%20Screens/user_home_screen.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap:(){
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        UserHomeScreen(navBarIndex: 0,)));
          },
          child: Icon(Icons.arrow_back_rounded,color: Colors.white,),
        ),
        backgroundColor: const Color.fromRGBO(248, 189, 48, 1.0),
        title: const Text(
          "Messages",
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
