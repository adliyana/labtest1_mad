import '../Controller/sqlite_db.dart';

class Bmi {

  static const String SQLiteTable = "bmi";

  String username;
  double weight;
  double height;
  String gender;
  String bmi_status;

  Bmi(this.username, this.weight, this.height, this.gender, this.bmi_status);

  Bmi.fromJson(Map<String, dynamic> json)
      : username = json['_Username'] as String,
        weight = double.parse(json['_Weight'].toString()),
        height = double.parse(json['_Height'].toString()),
        gender = json['_Gender'] as String,
        bmi_status = json['_Status'] as String;

  Map<String, dynamic> toJson() => {
    '_Username': username,
    '_Weight': weight,
    '_Height': height,
    '_Gender': gender,
    '_Status': bmi_status,
  };

  Future<bool> save() async {
    // Save to local SQLite
    await SQLiteDB().insert(SQLiteTable, toJson());
    // returning true always for local save
    return true;
  }

  static Future<List<Bmi>> loadAll() async {
    // Local SQLite
    List<Map<String, dynamic>> localResult = await SQLiteDB().queryAll(SQLiteTable);
    // Convert SQLite data to BmiCalc objects
    List<Bmi> result = localResult.map((item) => Bmi.fromJson(item)).toList();
    return result;
  }
}
