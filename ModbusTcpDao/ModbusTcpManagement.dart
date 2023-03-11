import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:provider/provider.dart';

import 'Adu.dart';

class TcpManage {
  late Socket? socket = null; //socket对象
  late String _remoteIp;

  set remoteIp(String value) {
    _remoteIp = value;
  } //服务端的ip
  late int _remotePort; //服务端的port
  set remotePort(int value) {
    _remotePort = value;
  }
  late StreamSubscription<Uint8List>? socketSubscription; //socket的订阅流
  StreamController<List<int>> controller =
      StreamController<List<int>>(); //获取listen的数据的流，用于标识是否接收端消息
  Uint8List returnData = Uint8List(0); //TCP错误就返回空

  //get方法
  String get remoteIp => _remoteIp;
  int get remotePort => _remotePort;

  //构造函数：ModbusTcpManage类的构造函数 入参是服务端的ip与端口
  TcpManage(String remoteIp, int remotePort) {
    _remoteIp = remoteIp;
    _remotePort = remotePort;
  }
  TcpManage.empty(){}

  Future<void> connect() async {
    try {
      socket = await Socket.connect(_remoteIp, _remotePort,
          timeout: Duration(seconds: 2));
      print('---------连接成功------------');
      print('Connected to: '
          '${socket!.remoteAddress.address}:${socket?.remotePort}');
      // await _listen();
    } catch (e) {
      print("连接socket出现异常,已主动断开连接，e=${e.toString()}");
      close();
      throw Exception(e);
    }
  }
  void close(){
    socket?.flush();
    socket?.close();
    socket?.destroy();
    socket =null;
  }
//socket监听
  _listen() async {
    socketSubscription = socket?.listen((Uint8List buffer) async {
      returnData = buffer;
      controller.sink.add(buffer);
    }, onError: _errorHandler, onDone: _doneHandler, cancelOnError: false);
    // print("开始监听");
  }

  //发送数据 Unit8List的值是0-255 超了会循环 详情参考：https://juejin.cn/post/6913851705561972744
  Future<void> send(Uint8List sendBytes) async {
    socket?.add(sendBytes);
    print("send: $sendBytes ");
  }

  _errorHandler(error) {
    print("tcp监听错误:$error");
    close();
  }

  _doneHandler() {
    print("tcp socket通信结束");
    close();
  }

  Future<Uint8List> modbusTcpSend(Adu adu) async {
    try {
      await _listen();
    } catch (e) {
      // print("已经监听过了");
      print(e);
    }
    try {
      StreamSubscription _streamSubscription =
          controller.stream.listen((event) {
        // print("一次性流接受成功");
        controller.close();
        controller = StreamController<List<int>>();
      });
      await send(adu.getAduBytes());
      await _streamSubscription.asFuture<void>();
    } on Exception {
      return returnData;
    }
    return returnData;
  }
}


