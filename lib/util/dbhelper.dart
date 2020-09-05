import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:async';
import 'dart:io';

import 'package:documents/model/doc.dart';

class DBHelper {
  // Tables
  static String tblDocs = "docs";

  // Fields of the 'docs' table.
  String docId = "id";
  String docTitle = "title";
  String docExpiration = "expiration";
  String fqYear = "fqYear";
  String fqHalfYear = "fqHalfYear";
  String fqQuarter = "fqQuarter";
  String fqMonth = "fqMonth";

  // Singleton
  static final DBHelper _dbHelper = DBHelper._internal();

  // Factory constructor
  DBHelper._internal();

  factory DBHelper() {
    return _dbHelper;
  }

  // Database entry point
  static Database _db;

  Future<Database> get db async {
    if (_db == null) {
      _db = await initializeDb();
    }

    return _db;
  }

  // Intialize the database
  Future<Database> initializeDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "/docexpire.db";
    var db = await openDatabase(path, version: 1, onCreate: _createDb);
    return db;
  }

  // Create database table
  void _createDb(Database db, int version) async {
    await db.execute("CREATE TABLE $tblDocs ($docId INTEGER PRIMARY KEY, " +
        "$docTitle TEXT, " +
        "$docExpiration TEXT, " +
        "$fqYear INTEGER, $fqHalfYear INTEGER, $fqQuarter INTEGER, " +
        "$fqMonth INTEGER)");
  }

  // Insert new doc
  Future<int> insertDoc(Doc doc) async {
    try {
      Database db = await this.db;
      var result = await db.insert(tblDocs, doc.toMap());
      return result;
    } catch (err) {
      print('Insert doc: ' + err.toString());
      return null;
    }
  }

  // Get the list of docs
  Future<List> getDocs() async {
    try {
      Database db = await this.db;
      var result = await db
          .rawQuery("SELECT * FROM $tblDocs ORDER BY $docExpiration ASC");
      return result;
    } catch (err) {
      print('Get docs: ' + err.toString());
      return null;
    }
  }

  // Get a Doc based on the id
  Future<List> getDoc(int id) async {
    try {
      Database db = await this.db;
      var result = await db
          .rawQuery("SELECT * FROM $tblDocs WHERE $docId = ${id.toString()}");
      return result;
    } catch (err) {
      print('Get doc with id: ' + err.toString());
      return null;
    }
  }

  // Get a Doc based on the String payload.
  Future<List> getDocFromStr(String payload) async {
    List<String> payloadList = payload.split("|");
    if (payloadList.length == 2) {
      try {
        Database db = await this.db;
        var result = await db.rawQuery(
            "SELECT * FROM $tblDocs WHERE $docId = " +
                payloadList[0] +
                "AND $docExpiration = " +
                payloadList[1]);
        return result;
      } catch (err) {
        print('Get doc from string: ' + err.toString());
        return null;
      }
    } else {
      return null;
    }
  }

  // Get the number of docs.
  Future<int> getDocCounts() async {
    try {
      Database db = await this.db;
      var result = Sqflite.firstIntValue(
          await db.rawQuery("SELECT COUNT(*) FROM $tblDocs"));
      return result;
    } catch (err) {
      print('Get doc from string: ' + err.toString());
      return null;
    }
  }

  // Get the max document id available on the database.
  Future<int> getMaxId() async {
    try {
      Database db = await this.db;
      var result = Sqflite.firstIntValue(
          await db.rawQuery("SELECT MAX($docId) FROM $tblDocs"));
      return result;
    } catch (err) {
      print('Get max id: ' + err.toString());
      return null;
    }
  }

  // Update doc based on id
  Future<int> updateDoc(Doc doc) async {
    try {
      Database db = await this.db;
      var result = await db.update(tblDocs, doc.toMap(),
          where: "$docId = ?", whereArgs: [doc.id]);
      return result;
    } catch (err) {
      print('Update doc: ' + err.toString());
      return null;
    }
  }

  // Delete doc based on id
  Future<int> deleteDoc(int id) async {
    try {
      Database db = await this.db;
      var result =
          await db.delete(tblDocs, where: "$docId = ?", whereArgs: [id]);
      return result;
    } catch (err) {
      print('Delete doc: ' + err.toString());
      return null;
    }
  }

  // Delete all docs.
  Future<int> deleteRows(String tableName) async {
    try {
      Database db = await this.db;
      var result = await db.delete(tableName);
      return result;
    } catch (err) {
      print('Delete rows: ' + err.toString());
      return null;
    }
  }
}
