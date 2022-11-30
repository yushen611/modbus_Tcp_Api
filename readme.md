这是一个modbus tcp通信协议的API 基于dart语言，可用于flutter进行通信

This is an API for the modbus tcp communication protocol based on the dart language and can be used for flutter communication

<br>



# Easy Begin



首先需要引入接口文件

```dart
import 'dart:typed_data';
import 'Adu.dart';
import 'Mbap.dart';
import 'Pdu.dart';
import 'TcpManagement.dart';
import 'ModbusToolFunc.dart';
```





接口实现了六种功能码 `01 02 03 04 05 06`，



## `01`function code

```dart
//8.测试modbus tcp 01 Adu auto
Future<void> testModbustcp01auto() async {
  Pdu01 pduReadDiscrete = Pdu01.req_builder(1, 5);
  Adu adu = Adu.autoBuildByPdu(pduReadDiscrete);

  String ip = "127.0.0.1";
  int port = 502;
  var tcpmanage = TcpManage(ip, port);
  var rsp_Adubytes = await tcpmanage.modbusTcpSend(adu);
  // print(rsp_Adubytes);
  var aduResponse = adu.receive(rsp_Adubytes);
  print(aduResponse);
}
```



## `02`function code

```dart
//9.测试modbus tcp 02 Adu auto
Future<void> testModbustcp02auto() async {
  Pdu02 pduReadDiscrete = Pdu02.req_builder(1, 5);
  Adu adu = Adu.autoBuildByPdu(pduReadDiscrete);

  String ip = "127.0.0.1";
  int port = 502;
  var tcpmanage = TcpManage(ip, port);
  var rsp_Adubytes = await tcpmanage.modbusTcpSend(adu);
  // print(rsp_Adubytes);
  var aduResponse = adu.receive(rsp_Adubytes);
  print(aduResponse);
}
```

## `03`function code

```dart
//11.测试modbus tcp 03 Adu auto
Future<void> testModbustcp03auto() async {
  Pdu03 pduReadDiscrete = Pdu03.req_builder(0, 29);
  Adu adu = Adu.autoBuildByPdu(pduReadDiscrete);

  String ip = "127.0.0.1";
  int port = 502;
  var tcpmanage = TcpManage(ip, port);
  var rsp_Adubytes = await tcpmanage.modbusTcpSend(adu);
  var aduResponse = adu.receive(rsp_Adubytes);
  print(aduResponse.body.length);
  print(aduResponse);
}
```



## `04`function code

```dart
//12.测试modbus tcp 04 Adu auto
Future<void> testModbustcp04auto() async {
  Pdu04 pduReadDiscrete = Pdu04.req_builder(1, 3);
  Adu adu = Adu.autoBuildByPdu(pduReadDiscrete);

  String ip = "127.0.0.1";
  int port = 502;
  var tcpmanage = TcpManage(ip, port);
  var rsp_Adubytes = await tcpmanage.modbusTcpSend(adu);
  var aduResponse = adu.receive(rsp_Adubytes);

  print(aduResponse);
}
```



## `05`function code

```dart
//13.测试modbus tcp 05 Adu auto
Future<void> testModbustcp05auto() async {
  Pdu05 pduReadDiscrete = Pdu05.req_builder(3, false);
  Adu adu = Adu.autoBuildByPdu(pduReadDiscrete);

  String ip = "127.0.0.1";
  int port = 502;
  var tcpmanage = TcpManage(ip, port);
  var rsp_Adubytes = await tcpmanage.modbusTcpSend(adu);
  var aduResponse = adu.receive(rsp_Adubytes);
  print(aduResponse);
}
```

## `06`function code

```dart
//14.测试modbus tcp 06 Adu auto
Future<void> testModbustcp06auto() async {
  Pdu06 pduReadDiscrete = Pdu06.req_builder(4, 0x039e);
  Adu adu = Adu.autoBuildByPdu(pduReadDiscrete);

  String ip = "127.0.0.1";
  int port = 502;
  var tcpmanage = TcpManage(ip, port);
  var rsp_Adubytes = await tcpmanage.modbusTcpSend(adu);
  var aduResponse = adu.receive(rsp_Adubytes);
  print(aduResponse);
}

```



# File intro

## Adu.dart

对于ADU的构造

the builder of  ADU

## Mbap.dart

对于Mbap的构造

the builder of Mbap

## ModbusError.dart

modbus错误处理

modbus error handling

## ModbusToolFunc.dart

一些帮助性的函数

Some helpful functions

## Pdu.dart

对于Pdu的构造

the builder of Pdu

## TcpManagement.dart

tcp管理层

tcp management for mudbus tcp

## TestMain.dart

对接口函数的一些测试放在了 `TestMain.dart`

Some tests of the interface function are placed in ``TestMain.dart`

<br>