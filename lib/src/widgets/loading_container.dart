import 'package:flutter/material.dart';

class LoadingContainer extends StatelessWidget {
  Widget build(context) {
    return Column(
      children: [
        ListTile(
          title: buildBox(),
          subtitle: buildBox(),
        ),
        Divider(height: 8.0),
      ]
    );
  }

  Widget buildBox() {
    return Container(
      color: Colors.grey[350],
      height: 24.0,
      width: 150.0,
      margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
    );
  }
}