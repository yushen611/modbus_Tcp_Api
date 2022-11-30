/*
 * @Author: ywy
 */
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'Adu.dart';

class TcpManage {
  late Socket? socket = null; //socket对象
  late String _remoteIp; //服务端的ip
  late int _remotePort; //服务端的port

  //get方法
  String get remoteIp => _remoteIp;
  int get remotePort => _remotePort;

  //构造函数：ModbusTcpManage类的构造函数 入参是服务端的ip与端口
  TcpManage(String remoteIp, int remotePort) {
    _remoteIp = remoteIp;
    _remotePort = remotePort;
  }

  Future<void> connect() async {
    try {
      socket = await Socket.connect(_remoteIp, _remotePort,
          timeout: Duration(seconds: 5));
      print('---------连接成功------------');
      print('Connected to: '
          '${socket!.remoteAddress.address}:${socket?.remotePort}');
    } catch (e) {
      print("连接socket出现异常，e=${e.toString()}");
    }
  }

  //发送数据 Unit8List的值是0-255 超了会循环 详情参考：https://juejin.cn/post/6913851705561972744
  Future<void> send(Uint8List sendBytes) async {
    socket?.add(sendBytes);
    socket?.flush(); //这个貌似可以不要
    print("send: $sendBytes ");
  }

  _errorHandler(error) {
    print("tcp监听错误:$error");
    socket?.destroy();
  }

  _doneHandler() {
    print("tcp socket通信结束");
    socket?.destroy();
  }

  //主动销毁连接
  Future<void> disconnect() async {
    socket?.destroy();
    print("已主动销毁连接");
  }

  Future<Uint8List> modbusTcpSend(Adu adu) async {
    Uint8List returnData = Uint8List(0); //TCP错误就返回空
    try {
      var tcpmanage = TcpManage(_remoteIp, _remotePort);
      await tcpmanage.connect();
      await tcpmanage.send(adu.getAduBytes());
      var subscription = tcpmanage.socket?.listen((Uint8List buffer) async {
        returnData = buffer;
        tcpmanage.socket?.destroy();
      }, onError: _errorHandler, onDone: _doneHandler, cancelOnError: false);
      await subscription?.asFuture<void>();
    } on Exception {
      return returnData;
    }

    return returnData;
  }
}
