import 'dart:async';
import 'Adu.dart';
import 'Pdu.dart';
import 'ModbusTcpManagement.dart';

//9.测试modbus tcp 02 Adu auto
Future<void> testModbustcp02auto(TcpManage tcpmanage) async {
  Pdu02 pduReadDiscrete = Pdu02.req_builder(1, 5);
  Adu adu = Adu.autoBuildByPdu(pduReadDiscrete);

  var rsp_Adubytes = await tcpmanage.modbusTcpSend(adu);
  print(rsp_Adubytes);
  var aduResponse = adu.receive(rsp_Adubytes);
  print(aduResponse);
}

//11.测试modbus tcp 03 Adu auto
Future<void> testModbustcp03auto(TcpManage tcpmanage) async {
  Pdu03 pduReadDiscrete = Pdu03.req_builder(6, 5);
  Adu adu = Adu.autoBuildByPdu(pduReadDiscrete);

  var rsp_Adubytes = await tcpmanage.modbusTcpSend(adu);
  var aduResponse = adu.receive(rsp_Adubytes);
  print(aduResponse);
  print(aduResponse.body.length);
}

//13.测试modbus tcp 05 Adu auto
Future<void> testModbustcp05auto(TcpManage tcpmanage) async {
  Pdu05 pduReadDiscrete = Pdu05.req_builder(3, false);
  Adu adu = Adu.autoBuildByPdu(pduReadDiscrete);

  var rsp_Adubytes = await tcpmanage.modbusTcpSend(adu);
  var aduResponse = adu.receive(rsp_Adubytes);
  print(aduResponse);
}

//14.测试modbus tcp 06 Adu auto
Future<void> testModbustcp06auto(TcpManage tcpmanage) async {
  Pdu06 pduReadDiscrete = Pdu06.req_builder(6, 0x039e);
  Adu adu = Adu.autoBuildByPdu(pduReadDiscrete);

  var rsp_Adubytes = await tcpmanage.modbusTcpSend(adu);
  var aduResponse = adu.receive(rsp_Adubytes);
  print(aduResponse);
}

Future<void> main() async {
  String ip = "192.168.1.102";
  int port = 502;
  var tcpmanage = TcpManage(ip, port);
  await tcpmanage.connect();
  String flag = "0203";
  // flag = "0506";
  // while (true)
  if (flag == "0203") {
    print("\n测试02功能码:从地址1开始，一共获取5个");
    await testModbustcp02auto(tcpmanage);
    print("\n测试03功能码:从地址6开始，一共获取5个");
    await testModbustcp03auto(tcpmanage);
  } else if (flag == "0506") {
    print("\n测试05功能码:修改地址3的值为0");
    await testModbustcp05auto(tcpmanage);
    print("\n测试06功能码:修改地址6的值为926");
    await testModbustcp06auto(tcpmanage);
  }
}
