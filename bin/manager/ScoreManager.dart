import 'package:path/path.dart';
import 'dart:io';
import 'dart:convert';
import 'sql_manager.dart';

String myPath = dirname(Platform.script.toFilePath());

class ScoresManage {
  File file;
  File awards_file;
  File getUpTime_file;
  File version;
  File order;
  File identification_file;
  File image;
  String imagePath;
  String versionPath;
  String scorePath;
  String awardPath;
  String getUpTimePath;
  String orderPath;
  String identificationPath;
  Sql sql;
  Map awards;

  ScoresManage() {
    sql = Sql();
    this.scorePath = myPath + r'/../data/scores.txt';
    this.awardPath = myPath + r'/../data/awards.txt';
    this.getUpTimePath = myPath + r'/../data/getUpTime.txt';
    this.versionPath = myPath + r'/../data/version.txt';
    this.orderPath = myPath + r'/../data/order.txt';
    try {
      this.file = new File(scorePath);
      this.awards_file = new File(awardPath);
      this.getUpTime_file = new File(getUpTimePath);
      this.version = new File(versionPath);
      this.order = new File(orderPath);
    } catch (e) {}
  }

  void init() async {
    await sql.connect();
  }

  Future getIdentification(String username) async {
    this.identificationPath =
        myPath + r'/../data/' + username + '/identyfication.txt';
    var result = identification_file.readAsString();
    if (result == null)
      return '{}';
    else
      return result;
  }

  void updateAwards() {
    awards_file.writeAsString(json.encode(''));
  }

  Future<List> get_orders() async {
    var temp = await order.readAsLines();
    List result = List();
    for (int i = 0; i < temp.length; i++) {
      result.add(jsonDecode(temp[i]));
    }
    return result;
  }

  Future<bool> save_image(
      String filename, var content, String date, String time) async {
    this.imagePath = myPath +
        r'/../image/' +
        date +
        '_Sign_in' +
        filename.substring(filename.lastIndexOf('.'));
    print(imagePath);
    //获取上一次打卡时间
    String last_date = await sql.getLastSignInDate();
    if (last_date != date) {
      bool flag = await sql.insertSignInInfo(date, imagePath, time);
      if (flag == true) {
        image = File(imagePath);
        image.writeAsBytesSync(content);
        sql.updateSignInDays();
        sql.updatePersistant_sign_in_days(last_date);
        sql.updateMax_persistant_sign_in_days();
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<String> getUp() async {
    var tmp = await sql.getLastGetUpDate();
    var yesterday = DateTime.parse(tmp);
    var today = DateTime.now();
    if (today.day == yesterday.day &&
        today.month == yesterday.month &&
        today.year == yesterday.year) {
      return "REPEAT";
    } else if ((today.hour >= 5 && today.hour <= 6) ||
        (today.hour == 7 && today.minute >= 0 && today.minute <= 40)) {
      await updateScores(1);
      await sql.insertGetUpInfo(today.toString());
      return "SUCCEED";
    } else {
      return "WRONG TIME";
    }
  }

  Future<String> getScores() async {
    try {
      int scores = await sql.getGetUpDays();
      print(scores);
      return scores.toString();
    } catch (e) {
      print(e);
      return '';
    }
  }

  void updateOrders(var save) {
    order.writeAsString(jsonEncode(save) + '\n', mode: FileMode.append);
  }

  void updateScores(int cnt) async {
    sql.updateGetUpDays();
  }

  Future<String> getSignInDays() async {
    try {
      int scores = await sql.getSignInDays();
      print(scores);
      return scores.toString();
    } catch (e) {
      print(e);
      return '';
    }
  }

  void updateSignInDays(var save) {
    sql.updateSignInDays();
  }
}
