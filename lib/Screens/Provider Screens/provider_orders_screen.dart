import 'package:authentication/Screens/Provider%20Screens/provider_chats_screen.dart';
import 'package:authentication/Screens/Provider%20Screens/provider_home_screen.dart';
import 'package:authentication/Screens/Provider%20Screens/provider_settings.dart';
import 'package:authentication/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/provider_nav_bar.dart';


class ProviderOrdersTab extends StatefulWidget {
  final int navBarIndex;

  const ProviderOrdersTab({super.key, required this.navBarIndex});

  @override
  State<ProviderOrdersTab> createState() => ProviderOrdersTabState();
}

class ProviderOrdersTabState extends State<ProviderOrdersTab> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.navBarIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Orders"),
      ),
      bottomNavigationBar: ProviderBottomNavigationBarWrapper(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          // Handle navigation based on the index
          switch (index) {
            case 0:
              // Navigate to Home screen
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProviderHomeScreen(navBarIndex: 0)));
              //Navigator.pushReplacementNamed(context, '/userHome');
              break;
            case 1:
              // Navigate to Profile screen
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProviderChatsTab(navBarIndex: 1)));
              //Navigator.pushReplacementNamed(context, '/userProfile');
              break;
            case 2:
              // Navigate to Favorites screen
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProviderSettingsTab(navBarIndex: 2)));
              //Navigator.pushReplacementNamed(context, '/userFavorites');
              break;
            case 3:
              // Navigate to Cart screen
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProviderOrdersTab(navBarIndex: 3)));
              //Navigator.pushReplacementNamed(context, '/userCart');
              break;
          }
        },
      ),
      body: const ProviderOrdersTabContent(), // Replace with your actual content
    );
  }
}

class ProviderOrdersTabContent extends StatefulWidget {
  const ProviderOrdersTabContent({super.key});

  @override
  State<ProviderOrdersTabContent> createState() => _ProviderOrdersTabContentState();
}

class _ProviderOrdersTabContentState extends State<ProviderOrdersTabContent> {
  late String userId;
  
  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('pageID', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No orders found.'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final orderData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final orderId = snapshot.data!.docs[index].id;
              return OrderItem(orderId: orderId, orderData: orderData);
            },
          );
        },
      ),
    );
  }
}

class OrderItem extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderItem({Key? key, required this.orderId, required this.orderData}) : super(key: key);

  Future<void> updateOrderStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'status': newStatus});
      showToast(message: 'Order status updated successfully.');
    } catch (error) {
      showToast(message: 'Error updating order status: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.black; // Default color
    if (orderData['status'] == 'pending') {
      statusColor = Colors.orange;
    } else if (orderData['status'] == 'rejected') {
      statusColor = Colors.red;
    } else if (orderData['status'] == 'accepted') {
      statusColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID : $orderId', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4,),
                Text('Date : ${orderData['date']}', style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey)),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text('Status: ', style: TextStyle(color: Colors.black)),
                Text('${orderData['status']}', style: TextStyle(color: statusColor)),
              ],
            ),
          ),
          Divider(),
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(orderData['userID']).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox.shrink();
              }
              if (!snapshot.hasData) {
                return SizedBox.shrink();
              }
              final providerData = snapshot.data!.data() as Map<String, dynamic>;
              final providerName = providerData['username'] ?? 'Unknown';
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Customer Name : $providerName'),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 200, // Adjust as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: orderData['items']?.length ?? 0,
              itemBuilder: (context, index) {
                final item = orderData['items'][index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        item['postDetails']['imageUrl'],
                        width: MediaQuery.of(context).size.width * .2, // Adjust as needed
                        height: MediaQuery.of(context).size.width * .2, // Adjust as needed
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 8),
                      Text('Item: ${item['postDetails']['itemName']}'),
                      Text('Quantity: ${item['quantity']}'),
                      Text('Color: ${item['selectedColor']}'),
                      Text('Size: ${item['selectedSize']}'),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: orderData['status'] == 'pending'
                    ? () => updateOrderStatus('accepted')
                    : null,
                child: Container(
                  width: 150,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: orderData['status'] == 'pending' ? Colors.green : Colors.grey, // Green color if pending, grey if not
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white, // Text color is white
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              GestureDetector(
                onTap: orderData['status'] == 'pending'
                    ? () => updateOrderStatus('rejected')
                    : null,
                child: Container(
                  width: 150,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: orderData['status'] == 'pending' ? Colors.red : Colors.grey, // Red color if pending, grey if not
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Reject',
                    style: TextStyle(
                      color: Colors.white, // Text color is white
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15,)

        ],
      ),
    );
  }
}
