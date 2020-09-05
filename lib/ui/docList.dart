import 'package:documents/ui/docDetail.dart';
import 'package:flutter/material.dart';
import 'package:documents/ui/docItem.dart';

import 'package:documents/model/doc.dart';
import 'package:documents/util/dbhelper.dart';

const menuReset = "Reset Local Data";
List<String> menuOptions = [menuReset];

class DocList extends StatefulWidget {
  @override
  _DocListState createState() => _DocListState();
}

class _DocListState extends State<DocList> {
  List<Doc> _docList = [];
  DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();

    getData();
  }

  void getData() async {
    await _dbHelper.initializeDb();

    final docMaps = await _dbHelper.getDocs();

    docMaps.forEach((element) {
      print(element);
    });

    this.setState(() {
      if (docMaps.isNotEmpty) {
        _docList = docMaps.map((docMap) => Doc.fromObject(docMap)).toList();
      } else {
        _docList = [];
      }
    });
  }

  void navigateToDetail({Doc doc}) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return DocDetail(doc: doc);
    }));

    if (result == true) {
      getData();
    }
  }

  void selectMenuOption(String value) async {
    switch (value) {
      case menuReset:
        await resetData();
        break;

      default:
        break;
    }
  }

  Future resetData() async {
    final result = await _dbHelper.initializeDb();

    if (result != null) {
      await _dbHelper.deleteRows(DBHelper.tblDocs);
      getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _appBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: _docListWidget(),
      ),
      floatingActionButton: _addButton(),
    );
  }

  _appBar() {
    return AppBar(
      title: Text('DocExpire'),
      centerTitle: true,
      elevation: 0,
      actions: [
        PopupMenuButton(onSelected: (value) {
          selectMenuOption(value);
        }, itemBuilder: (context) {
          return menuOptions
              .map((option) => PopupMenuItem(
                  value: option,
                  child: ListTile(
                    leading: Icon(Icons.replay),
                    title: Text(option),
                  )))
              .toList();
        })
      ],
    );
  }

  _docListWidget() {
    return ListView.builder(
      itemCount: _docList.length,
      itemBuilder: (context, index) {
        final docItem = _docList[index];
        return DocItem(
            doc: docItem,
            docItemDidTap: () {
              navigateToDetail(doc: docItem);
            });
      },
    );
  }

  _addButton() {
    return FloatingActionButton(
      onPressed: () {
        navigateToDetail(
            doc: Doc.withId(
                id: -1,
                title: '',
                expiration: '',
                fqYear: 1,
                fqHalfYear: 1,
                fqQuarter: 1,
                fqMonth: 1));
      },
      child: Icon(Icons.add),
    );
  }
}
