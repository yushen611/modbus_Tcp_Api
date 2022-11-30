import 'dart:typed_data';
import 'Adu.dart';
import 'Mbap.dart';
import 'Pdu.dart';
import 'TcpManagement.dart';
import 'ModbusToolFunc.dart';

void mReceive(Uint8List bytes) {
  print(bytes);
  print("接受成功");
}

//2.测试Tool中的函数：int2Bytes
void testUint8List() {
  Uint8List bytes = int2Bytes(8);
  print(bytes);
}

//3.测试Mbap类
void testMbap() {
  Mbap mbap = Mbap(4);
  Uint8List mbapbytes = mbap.getMbapBytes();
  print(mbapbytes);
  Hex mbapHex = Hex(mbapbytes);
  print(mbapHex);
  print(mbapHex.getBytesNum());
}

//4.测试PDU
void testPDU_PduReadDiscrete() {
  Pdu01 pduReadDiscrete = Pdu01.req_builder(1, 1);
  Hex pduHex = Hex(pduReadDiscrete.getPdubytes());
  print(pduHex);
  print(pduHex.getBytesNum());
}

//5.测试ADU的字节
void testADU1() {
  Pdu01 pduReadDiscrete = Pdu01.req_builder(1, 1);
  Mbap mbap = Mbap(pduReadDiscrete.getPduLength());
  Uint8List Adu = BytesCat(mbap.getMbapBytes(), pduReadDiscrete.getPdubytes());
  Hex AduHexh = Hex(Adu);
  print(AduHexh);
  print(AduHexh.getBytesNum());
}

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

//10.测试 HighLowCat
void testHighLowCat() {
  int high = 0x02;
  int low = 0x2B;
  int res = HighLowCat(high, low);
  print(res);
  //0x022B 就是555
}

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

Future<void> main() async {
  testModbustcp03auto();
}
