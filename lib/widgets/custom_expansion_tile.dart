import 'package:flutter/material.dart';

class CustomExpansionTile extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded; // Add initiallyExpanded parameter
  final Function(bool)? onExpansionChanged; // Add onExpansionChanged callback

  const CustomExpansionTile({
    Key? key,
    required this.title,
    required this.children,
    this.initiallyExpanded = false, // Provide a default value
    this.onExpansionChanged, // Optional callback
  }) : super(key: key);

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.fromLTRB(15, 4, 15, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            widget.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0D0A35),
            ),
          ),
          children: widget.children,
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: widget.initiallyExpanded, // Set initiallyExpanded
          onExpansionChanged: widget.onExpansionChanged, // Pass the callback
        ),
      ),
    );
  }
}
