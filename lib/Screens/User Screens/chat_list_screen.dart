import 'package:flutter/material.dart';
import '../../Data_Classes/ChatData.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  static List<ChatModel> pepoleData = [
    ChatModel('lib/assets/FollowingListshops/SmileShop.png', 'SmileShop',
        'HM ?', '.22h'),
    ChatModel('lib/assets/FollowingListshops/You&meShop.png', 'You&meShop',
        'The order did not arrive yet ', '.1 Day'),
    ChatModel('lib/assets/FollowingListshops/S-Mart.png', 'S-Mart',
        'Check your number of order and send it', '.18h'),
  ];
  List<ChatModel> display = List.from(pepoleData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chats",
          style: TextStyle(fontSize: 35),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        itemCount: display.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(
                    display[index].imagePath!,
                  )),
              title: Text(
                display[index].name!,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
              subtitle: Text(
                display[index].message!,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w300),
              ),
              trailing: Text(
                display[index].time!,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: Colors.black),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(
          color: Colors.white,
        ),
      ),
    );
  }
}
