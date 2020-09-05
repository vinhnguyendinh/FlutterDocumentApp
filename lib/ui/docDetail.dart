import 'dart:math';

import 'package:documents/model/doc.dart';
import 'package:documents/model/alert.dart';

import 'package:documents/ui/alertItem.dart';
import 'package:documents/util/utils.dart';
import 'package:documents/util/dbhelper.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

const menuDelete = "Delete";
List<String> detailMenuOptions = [menuDelete];

class DocDetail extends StatefulWidget {
  final Doc doc;

  DocDetail({this.doc});

  @override
  _DocDetailState createState() => _DocDetailState();
}

class _DocDetailState extends State<DocDetail> {
  final DBHelper _dbHelper = DBHelper();

  final _formKey = GlobalKey<FormState>();
  final int daysAhead = 5475;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController expireDateController =
      MaskedTextController(mask: '2000-00-00');

  List<Alert> alertList = [
    Alert(title: "Alert before 1.5 and 1 year", isSelected: false),
    Alert(title: "Alert before 6 months", isSelected: false),
    Alert(title: "Alert before 3 months", isSelected: false),
    Alert(title: "Alert before 1 month or less", isSelected: false),
  ];

  @override
  void initState() {
    super.initState();
    setupInit();
  }

  void setupInit() {
    titleController.text = widget.doc.title != null ? widget.doc.title : "";
    expireDateController.text =
        widget.doc.expiration != null ? widget.doc.expiration : "";
    alertList[0].isSelected =
        widget.doc.fqYear != null ? Val.intToBool(widget.doc.fqYear) : false;
    alertList[1].isSelected = widget.doc.fqQuarter != null
        ? Val.intToBool(widget.doc.fqQuarter)
        : false;
    alertList[2].isSelected = widget.doc.fqQuarter != null
        ? Val.intToBool(widget.doc.fqQuarter)
        : false;
    alertList[3].isSelected =
        widget.doc.fqMonth != null ? Val.intToBool(widget.doc.fqMonth) : false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _documentName(context),
                _dateExpire(context),
                SizedBox(height: 20),
                _alertList(),
                SizedBox(height: 50),
                _saveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _appBar() {
    final titleStr = widget.doc.id == -1 ? "New Document" : widget.doc.title;

    return AppBar(
      title: Text(titleStr),
      centerTitle: true,
      actions: widget.doc.id == -1
          ? []
          : [
              PopupMenuButton(onSelected: (value) {
                selectMenuOption(value);
              }, itemBuilder: (context) {
                return detailMenuOptions
                    .map(
                      (option) => PopupMenuItem(
                        value: option,
                        child: Text(option),
                      ),
                    )
                    .toList();
              })
            ],
    );
  }

  void selectMenuOption(String value) async {
    switch (value) {
      case menuDelete:
        if (widget.doc.id != -1) {
          await _dbHelper.deleteDoc(widget.doc.id);
          Navigator.pop(context, true);
        }
        break;

      default:
        break;
    }
  }

  _documentName(BuildContext context) {
    return TextFormField(
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 ]"))
      ],
      validator: (value) => Val.validateTitle(value),
      controller: titleController,
      style: Theme.of(context).textTheme.bodyText1,
      decoration: InputDecoration(
          hintText: 'Enter the document name',
          labelText: 'Document name',
          icon: Icon(
            Icons.text_fields,
            color: Colors.grey,
          )),
    );
  }

  _dateExpire(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            validator: (value) => Val.validateExpireDate(value),
            controller: expireDateController,
            style: Theme.of(context).textTheme.bodyText1,
            maxLength: 10,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: 'Enter date (i.e. ' +
                    DateUtils.daysAheadAsString(daysAhead) +
                    ')',
                labelText: 'Expire date',
                icon: Icon(
                  Icons.calendar_today,
                  color: Colors.grey,
                )),
          ),
        ),
        IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () {
              _chooseDatePicker(context, expireDateController.text);
            })
      ],
    );
  }

  void _chooseDatePicker(BuildContext context, String initialDateString) {
    var now = DateTime.now();
    var initialDate = DateUtils.convertToDate(initialDateString) ?? now;
    print('year = ${now.year}');
    initialDate = initialDate.year > now.year && initialDate.isAfter(now)
        ? initialDate
        : now;

    DatePicker.showDatePicker(context,
        currentTime: initialDate,
        showTitleActions: true,
        locale: LocaleType.en, onConfirm: (date) {
      String expireDateString = DateUtils.ftDateAsString(date);
      setState(() {
        expireDateController.text = expireDateString;
      });
    });
  }

  _alertList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: alertList.length,
      itemBuilder: (context, index) {
        final alertItem = alertList[index];
        return AlertItem(
          title: alertItem.title,
          isSelected: alertItem.isSelected,
          switchDidChanged: (value) {
            setState(() {
              alertItem.isSelected = value;
            });
          },
        );
      },
    );
  }

  _saveButton() {
    return RaisedButton(
        color: Colors.pinkAccent,
        textColor: Colors.white,
        child: Text('Save'),
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            // Add new doc
            if (widget.doc.id == -1) {
              // Get max id
              int maxId = await _dbHelper.getMaxId();
              Doc doc = Doc.withId(
                  id: maxId ?? 1,
                  title: titleController.text,
                  expiration: expireDateController.text,
                  fqYear: Val.boolToInt(alertList[0].isSelected),
                  fqHalfYear: Val.boolToInt(alertList[1].isSelected),
                  fqQuarter: Val.boolToInt(alertList[2].isSelected),
                  fqMonth: Val.boolToInt(alertList[3].isSelected));

              // Insert doc to database
              await _dbHelper.insertDoc(doc);

              Navigator.pop(context, true);
            } else {
              // Update doc
              Doc doc = Doc.withId(
                  id: widget.doc.id,
                  title: titleController.text,
                  expiration: expireDateController.text,
                  fqYear: Val.boolToInt(alertList[0].isSelected),
                  fqHalfYear: Val.boolToInt(alertList[1].isSelected),
                  fqQuarter: Val.boolToInt(alertList[2].isSelected),
                  fqMonth: Val.boolToInt(alertList[3].isSelected));

              // Update doc to database
              await _dbHelper.updateDoc(doc);

              Navigator.pop(context, true);
            }
          }
        });
  }
}
