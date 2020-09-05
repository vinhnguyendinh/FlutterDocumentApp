import 'package:documents/util/utils.dart';

class Doc {
  int id;
  String title;
  String expiration;

  int fqYear;
  int fqHalfYear;
  int fqQuarter;
  int fqMonth;

  Doc(
      {this.title,
      this.expiration,
      this.fqYear,
      this.fqHalfYear,
      this.fqQuarter,
      this.fqMonth});

  Doc.withId(
      {this.id,
      this.title,
      this.expiration,
      this.fqYear,
      this.fqHalfYear,
      this.fqQuarter,
      this.fqMonth});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map['title'] = title;
    map['expiration'] = expiration;
    map['fqYear'] = fqYear;
    map['fqHalfYear'] = fqHalfYear;
    map['fqQuarter'] = fqQuarter;
    map['fqMonth'] = fqMonth;

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  Doc.fromObject(dynamic object) {
    this.id = object['id'];
    this.title = object['title'];
    this.expiration = DateUtils.trimDate(object['expiration']);
    this.fqYear = object['fqYear'];
    this.fqHalfYear = object['fqHalfYear'];
    this.fqQuarter = object['fqQuarter'];
    this.fqMonth = object['fqMonth'];
  }
}
