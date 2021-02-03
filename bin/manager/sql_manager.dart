import 'package:mysql1/mysql1.dart';

class Sql {
  MySqlConnection db;
  ConnectionSettings settings;
  Sql({this.settings}) {
    if (this.settings == null) {
      this.settings = ConnectionSettings(
          host: 'localhost',
          port: 3306,
          user: 'lsh',
          db: 'get_up_early',
          password: 'lsh2xmz..');
    }
  }
  //链接数据库
  void connect() async {
    db = await MySqlConnection.connect(settings);
  }

//插入早起签到信息
  Future<bool> insertGetUpInfo(
      String date) async {
    var result = await db.query(
        "insert into get_up (date) values (?);",
        [date]);
    if (result.affectedRows == 0) {
      return false;
    } else {
      return true;
    }
  }

  //插入签到打卡信息
  Future<bool> insertSignInInfo(
      String date, String imagePath, String time) async {
    var result = await db.query(
        "insert into sign_in (date,image,time) values (?,?,?);",
        [date, imagePath, time]);
    if (result.affectedRows == 0) {
      return false;
    } else {
      return true;
    }
  }

  //获取上一次的打卡签到日期
  Future<String> getLastSignInDate() async {
    Results result = await db.query("select MAX(date) from sign_in;");
    String lastDate = result.toList()[0][0].toString();
    return lastDate;
  }

  //获取上一次的早起签到日期
  Future<String> getLastGetUpDate() async {
    Results result = await db.query("select MAX(date) from get_up;");
    String lastDate = result.toList()[0][0].toString();
    return lastDate;
  }


  //更新早起签到天数
  void updateGetUpDays() async {
    var tmp1 = await db
        .query("update key_data set val = val+1 where name = 'get_up_days';");
  }

  //获取早起签到天数
  Future<int> getGetUpDays() async {
    var result = await db.query(
        "select val from key_data where( name = 'get_up_days' );");
    var max_persistant_days = result.toList();
    return int.parse(max_persistant_days[0][0].toString());
  }

    //获取早起签到天数
  Future<int> getSignInDays() async {
    var result = await db.query(
        "select val from key_data where( name = 'sign_in_days' );");
    var max_persistant_days = result.toList();
    return int.parse(max_persistant_days[0][0].toString());
  }


  //更新打卡签到天数
  void updateSignInDays() async {
    var tmp1 = await db
        .query("update key_data set val = val+1 where name = 'sign_in_days';");
  }

  //获取最长连续签到天数
  Future<int> getMaxPersistantDays() async {
    var result = await db.query(
        "select val from key_data where( name = 'max_persistant_days' );");
    var max_persistant_days = result.toList();
    return int.parse(max_persistant_days[0][0].toString());
  }

  //获取连续签到天数
  Future<int> getPersistantDays() async {
    var result = await db.query(
        "select val from key_data where( name = 'persistant_sign_in_days' );");
    var persistant_sign_in_days = result.toList();
    return int.parse(persistant_sign_in_days[0][0].toString());
  }

  //更新最长连续打卡天数
  void updateMax_persistant_sign_in_days() async {
    var last = await getMaxPersistantDays();
    var now = await getPersistantDays();
    if (now > last) {
      var result = await db.query(
          "update key_data set val = ? where name = 'max_persistant_days';",
          [now.toString()]);
    }
  }

  //更新连续打卡天数
  void updatePersistant_sign_in_days(String date) async {
    if(date=='null'){
      var tmp3 = await db.query(
          "update key_data set val = 1 where name = 'persistant_sign_in_days';");
      return;
    }
    var now = DateTime.parse(await getLastSignInDate());
    var last = DateTime.parse(date);
    var gap = last.difference(now).abs().inHours;
    print(last);
    print(now);
    print(gap);

    if (gap <= 24) {
      var tmp3 = await db.query(
          "update key_data set val = val+1 where name = 'persistant_sign_in_days';");
    } else {
      var tmp3 = await db.query(
          "update key_data set val = 1 where name = 'persistant_sign_in_days';");
    }
  }
}
