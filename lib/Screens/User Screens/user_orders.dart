import 'package:authentication/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserOrdersScreen extends StatefulWidget {
  const UserOrdersScreen({Key? key}) : super(key: key);

  @override
  _UserOrdersScreenState createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userID', isEqualTo: userId)
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


  Future<void> deleteOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
      showToast( message: 'Order canceled successfully.');
    } catch (error) {
      showToast( message: 'Error deleting order: $error');
      // Handle error accordingly, such as showing an error message to the user.
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
            future: FirebaseFirestore.instance.collection('providers').doc(orderData['pageID']).get(),
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
                child: Text('Page Name: $providerName'),
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          item['postDetails']['imageUrl'],
                          width: MediaQuery.of(context).size.width * 0.3, // Adjust as needed
                          height: MediaQuery.of(context).size.height * 0.1, // Adjust as needed
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 8),
                        Text('Item: ${item['postDetails']['itemName']}'),
                        Text('Quantity: ${item['quantity']}'),
                        Text('Color: ${item['selectedColor']}'),
                        Text('Size: ${item['selectedSize']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (orderData['status'] == 'pending')
            GestureDetector(
                onTap: () {
                  deleteOrder(orderId);
                },
                child: Container(
                  margin: EdgeInsets.fromLTRB(20,10,20,10),
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF0D0A35),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete,
                        color:Color.fromRGBO(255, 198, 50, 1.0),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Cancel Order',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(255, 198, 50, 1.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}


