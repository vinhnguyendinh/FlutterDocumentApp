import 'package:flutter/material.dart';

class AlertItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function(bool) switchDidChanged;

  AlertItem({this.title, this.isSelected, this.switchDidChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: Colors.black),
            ),
          ),
          Switch(
              value: isSelected,
              onChanged: (value) {
                switchDidChanged(value);
              })
        ],
      ),
    );
  }
}
