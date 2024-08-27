import 'package:flutter/material.dart';

class OrderItemWidget extends StatelessWidget {
  final String imageUrl;
  final String itemName;
  final double itemPrice;
  final int quantity;
  final String color;
  final String size;

  const OrderItemWidget({
    required this.imageUrl,
    required this.itemName,
    required this.itemPrice,
    required this.quantity,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item name
                Text(
                  itemName!,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                // Item price
                Text(
                  'Price: ${itemPrice.toStringAsFixed(2)} EGP',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 4),
                // Item quantity
                Text(
                  'Quantity: $quantity',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 4),
                // Item Size
                Text(
                  'Size: $size',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 4),
                // Item color
                Text(
                  'Color: $color',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
