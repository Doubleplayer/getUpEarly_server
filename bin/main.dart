import 'dart:convert';
import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'manager/sql_manager.dart';
import 'data.dart';
import 'package:http_server/http_server.dart';
import 'versionManager.dart';
import 'manager/ScoreManager.dart';

String myHost = "172.17.13.219";

ScoresManage manager = new ScoresManage();
void main() async {
  {
    //创建服务器
    var requestServer = await HttpServer.bind(myHost, 10086);
    await manager.init();
    print("http服务启动起来");
    print(requestServer);
    await for (HttpRequest request in requestServer) {
      handleMessage(request, requestServer);
    }
  }
}

void handleMessage(HttpRequest request, HttpServer server) {
  try {
    if (request.method == 'GET') {
      handleGET(request, server);
    } else if (request.method == 'POST') {
      handlePOST(request);
    }
  } catch (e) {
    print("捕获了一个异常");
  }
}

void handleGET(HttpRequest request, HttpServer server) async {
  var action = request.uri.queryParameters['action'];
  print(action);
  if (action == 'getScores') {
    manager.getScores().then((value) {
      request.response
        ..write(json.encode(value))
        ..close();
    });
  }
  if (action == 'getAwards') {
    print("获取奖励信息");
    request.response
      ..write(json.encode(''))
      ..close();
  }
  if (action == 'update') {
    var temp = await manager.version.readAsString();
    var result = jsonDecode(temp);
    print(result);
    request.response
      ..write(json.encode(result))
      ..close();
  }
  if (action == 'getUp') {
    var result = await manager.getUp();
    request.response
      ..write(json.encode(result))
      ..close();
  }
  if (action == 'getPersistantSignInDays') {
    var result = await manager.getSignInDays();
    request.response
      ..write(json.encode(result))
      ..close();
  }
  
  if (request.uri.toString() == '/updateInfo') {
    print("123123");
    VersionManager(server, request).sendHtml();
  }
  if (request.uri.toString() == '/apk') {
    VersionManager(server, request).sendApk();
  }
  if (request.uri.toString() == '/orders') {
    print("访问orders");
    manager.get_orders().then((value) {
      request.response
        ..write(json.encode(value))
        ..close();
    });
  }
}

void handlePOST(HttpRequest request) async {
  var body = await HttpBodyHandler.processRequest(request);
  var result = body.body;
  print(result);
  try {
    if (result["type"] == "ORDER") {
      String description = result["description"];
      String scores = result["scores"];
      String url = result["url"];
      manager.getScores().then((temp) {
        if (int.parse(temp) >= int.parse(scores)) {
          var save = {
            "description": description,
            "scores": scores,
            "url": url,
            "time": DateTime.now().toString(),
            "state": "处理中"
          };
          manager.updateOrders(save);
          manager.updateScores(-int.parse(scores));
          request.response
            ..write(jsonEncode("FINISH"))
            ..close();
        } else {
          request.response
            ..write(jsonEncode("FAILED"))
            ..close();
        }
      });
    } else if (result["type"] == "Login") {
      String username = result["user"];
      String password = result["password"];
      if (username == 'xmz' && password == "xiaoxiao666..") {
        request.response
          ..write(jsonEncode("SUCCEED"))
          ..close();
      } else {
        request.response
          ..write(jsonEncode("FAILED"))
          ..close();
      }
    } else if (result['type'] == "uploadImage") {
      HttpBodyFileUpload fileUploaded = result['file'];
      bool flag = await manager.save_image(fileUploaded.filename,
          fileUploaded.content, result['date'], result['time']);
      if (flag == true)
        request.response
          ..write(jsonEncode("签到成功"))
          ..close();
      else {
        request.response
          ..write(jsonEncode("今日已签到"))
          ..close();
      }
    } else {
      request.response
        ..statusCode = 404
        ..write(jsonEncode("FAILED"))
        ..close();
    }
  } catch (e) {
    request.response
      ..write(jsonEncode("FAILED"))
      ..close();
  }
}
