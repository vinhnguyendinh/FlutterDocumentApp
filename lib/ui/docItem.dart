import 'package:flutter/material.dart';
import 'package:documents/model/doc.dart';
import 'package:documents/util/utils.dart';

class DocItem extends StatelessWidget {
  final Doc doc;

  final Function docItemDidTap;

  DocItem({this.doc, this.docItemDidTap});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.white,
        elevation: 1,
        child: ListTile(
          leading: _circleTitle(),
          title: _title(),
          subtitle: _subTitle(),
          onTap: () {
            docItemDidTap();
          },
        ));
  }

  _circleTitle() {
    final expiryString = Val.getExpiryString(doc.expiration);

    return CircleAvatar(
      backgroundColor: expiryString != "0" ? Colors.blue : Colors.red,
      child: Text(doc.id.toString()),
    );
  }

  _title() {
    return Text(
      doc.title,
      style: TextStyle(
          fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
    );
  }

  _subTitle() {
    final expiryString = Val.getExpiryString(doc.expiration);
    final dayLeft = (expiryString != "1" && expiryString != "0")
        ? " days left"
        : " day left";

    return Text(Val.getExpiryString(doc.expiration) +
        dayLeft +
        "\nExp: " +
        DateUtils.convertToDateFull(doc.expiration));
  }
}
