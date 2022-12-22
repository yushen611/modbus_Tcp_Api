import 'dart:typed_data';

import 'ModbusToolFunc.dart';

class Mbap {
  //  属性：transaction_Id，protocol_Id,length,unit_Id
  // 方法：getMbapBytes(),set/get，Mbap()
  Uint8List _transaction_Id = Uint8List(2); //事务元标识符
  Uint8List _protocol_Id = Uint8List(2); //协议标识符
  Uint8List _length = Uint8List(2); //长度
  Uint8List _unit_Id = Uint8List(1); //单元标识符
  static final int unit_Id_lenth = 1;
  //构造函数 需要传去之后的PDU的长度
  Mbap(int PduLenth, {int unit_id_int = 0x01}) {
    _transaction_Id = Uint8List.fromList([0x00, 0x00]);
    _protocol_Id = Uint8List.fromList([0x00, 0x00]);
    _length = BytesOne2Two(int2Bytes(unit_Id_lenth + PduLenth));
    _unit_Id = int2Bytes(unit_id_int);
  }
  //获取整个Mbap报文头的字节
  Uint8List getMbapBytes() {
    final bytesBuilder = BytesBuilder();
    bytesBuilder.add(_transaction_Id);
    bytesBuilder.add(_protocol_Id);
    bytesBuilder.add(_length);
    bytesBuilder.add(_unit_Id);
    Uint8List byteList = bytesBuilder.toBytes();
    return byteList;
  }

  //set/get方法
  Uint8List get transaction_Id => _transaction_Id;
  set transaction_Id(Uint8List transaction_Id) =>
      _transaction_Id = transaction_Id;

  Uint8List get protocol_Id => _protocol_Id;
  set protocol_Id(Uint8List protocol_Id) => _protocol_Id = protocol_Id;

  Uint8List get length => _length;
  set length(Uint8List length) => _length = length;

  Uint8List get unit_Id => _unit_Id;
  set unit_Id(Uint8List unit_Id) => _unit_Id = unit_Id;
}
