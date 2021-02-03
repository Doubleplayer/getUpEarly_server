import 'dart:convert';
import 'dart:io';
import 'data.dart';
import 'package:http_server/http_server.dart' as http_server;
import 'package:path/path.dart';

String myPath = dirname(Platform.script.toFilePath());

class VersionManager {
  var requestServer;
  HttpRequest request;
  VersionManager(this.requestServer, this.request);
  void sendHtml() {
    http_server.VirtualDirectory staticFiles =
        new http_server.VirtualDirectory('.');
    //监听请求

//当我们收到请求根目录或者请求/index.html页面时，返回我们的刚刚写好的html页面
//因为http_server这个包已经为我们处理好了，所以如果html不存在，也不会让服务器奔溃掉，而是返回未找到页面
    staticFiles.serveFile(
        new File(myPath + r'/../webApp/index.html'), request); //win系统使用该代码
  }

  void sendApk() async {
    http_server.VirtualDirectory staticFiles =
        new http_server.VirtualDirectory('.');
    //监听请求

//当我们收到请求根目录或者请求/index.html页面时，返回我们的刚刚写好的html页面
//因为http_server这个包已经为我们处理好了，所以如果html不存在，也不会让服务器奔溃掉，而是返回未找到页面
    staticFiles.serveFile(
        new File(myPath + r'/../apk/APP.apk'), request); //win系统使用该代码
  }
}
