import 'dart:typed_data';

import 'ModbusError.dart';
import 'ModbusToolFunc.dart';

//modbus 制订了三种pdu 请求 响应 异常响应
enum PduType {
  mb_req_pdu,
  mb_right_rsp_pdu,
  mb_excep_rsp_pdu,
  mb_unknown_rsp_pdu
}

abstract class Pdu {
  //属性 functionCode,databytes
  Uint8List _functionCode = Uint8List(1);
  Uint8List _databytes = Uint8List(0);
  late PduType _pduType;

  //获取完整pdu
  Uint8List getPdubytes() {
    assert(_functionCode.length == 1);
    final bytesBuilder = BytesBuilder();
    bytesBuilder.add(_functionCode);
    bytesBuilder.add(_databytes);
    Uint8List byteList = bytesBuilder.toBytes();
    return byteList;
  }

  //获取pdu的长度
  int getPduLength() {
    return this.getPdubytes().length;
  }

  //get/set
  Uint8List get functionCode => _functionCode;
  set functionCode(Uint8List functionCode) => _functionCode = functionCode;

  Uint8List get databytes => _databytes;
  set databytes(Uint8List databytes) => _databytes = databytes;

  PduType get pduType => _pduType;
  set pduType(PduType pduType) => _pduType = pduType;

  //judgerecvPduType 判断接收的pdu种类
  PduType judgeRecvPduType(Uint8List rspBytes) {
    //判断接收到的请求的功能码是否与来的一致
    if (rspBytes[0] == this._functionCode[0]) {
      return PduType.mb_right_rsp_pdu;
    } else if (rspBytes[0] == (this._functionCode[0] + 0x80)) {
      return PduType.mb_excep_rsp_pdu;
    }
    return PduType.mb_unknown_rsp_pdu;
  }

  //recv_pdu_rsp_right 接收正确pdu的处理方法 Pdu_databytes是除去pdu功能码后的数据部分
  List<int> recv_pdu_rsp_right(Uint8List Pdu_databytes);

  //recv_rsp_error 接收错误pdu的处理方法
  String? recv_rsp_error(Uint8List rspBytes) {
    assert(rspBytes.length == 1); //保存的pdu只有一个
    return ModbusErrorEnum.getErrorMsg(rspBytes[0]);
  }
}

//读离散的值 0x01
class Pdu01 extends Pdu {
  late int _DiscreteNum; //请求离散值的数量,重复存一下
  //请求构造函数
  Pdu01.req_builder(int startaddress, int DiscreteNum) {
    _DiscreteNum = DiscreteNum;
    super._functionCode = Uint8List.fromList([0x01]); //功能码一个字节
    assert(startaddress >= 0x0000 && startaddress <= 0xFFFF);
    Uint8List startaddressBtyes =
        BytesOne2Two(int2Bytes(startaddress)); //起始地址两个字节
    Uint8List DiscreteNumBtyes =
        BytesOne2Two(int2Bytes(DiscreteNum)); //线圈数量两个字节
    super._databytes = BytesCat(startaddressBtyes, DiscreteNumBtyes);
    super._pduType = PduType.mb_req_pdu;
  }

  @override //rsp_databytes是返回的pdu的数据部分
  recv_pdu_rsp_right(Uint8List rsp_databytes) {
    //需要读的数量是请求pdu的 _DiscreteNum
    //字节计数
    int bytesNum = rsp_databytes[0];
    //线圈状态
    Uint8List DiscretesBytes = rsp_databytes.sublist(1);

    //结果数组
    List<int> resDiscretesList = [];
    //逐个字节进行读取，从第一个数据字节的 LSB（最低有效位）开始读，其它线圈依次类推，一直到这个字节的高位端为止，并在后续字节中从低位到高位的顺序。
    for (int BytesIndex = 0; BytesIndex < bytesNum; BytesIndex++) {
      int ByteValue = DiscretesBytes[BytesIndex];
      //如果这个字节的值都是需要读取的值，那就全部都读了  注：魔法数字 8 是一个字节的比特数量
      if ((BytesIndex + 1) * 8 <= _DiscreteNum) {
        for (int curDiscreteByteIndex = 0;
            curDiscreteByteIndex < 8;
            curDiscreteByteIndex++) {
          int DiscreteValue = ByteValue & 0x01;
          resDiscretesList.add(DiscreteValue);
          ByteValue = ByteValue >> 1;
        }
      }
      //对于不满一个字节的值，单独从低到高位读 ，因此要右移
      else {
        int remainDiscreteNum = _DiscreteNum - BytesIndex * 8;
        for (int curDiscreteByteIndex = 0;
            curDiscreteByteIndex < remainDiscreteNum;
            curDiscreteByteIndex++) {
          int DiscreteValue = ByteValue & 0x01;
          resDiscretesList.add(DiscreteValue);
          ByteValue = ByteValue >> 1;
        }
      }
    }
    return resDiscretesList;
  }
}

//0x02
class Pdu02 extends Pdu {
  late int _DiscreteNum; //请求离散值的数量,重复存一下
  //请求构造函数
  Pdu02.req_builder(int startaddress, int DiscreteNum) {
    _DiscreteNum = DiscreteNum;
    super._functionCode = Uint8List.fromList([0x02]); //功能码一个字节
    assert(startaddress >= 0x0000 && startaddress <= 0xFFFF);
    Uint8List startaddressBtyes =
        BytesOne2Two(int2Bytes(startaddress)); //起始地址两个字节
    Uint8List DiscreteNumBtyes =
        BytesOne2Two(int2Bytes(DiscreteNum)); //线圈数量两个字节
    super._databytes = BytesCat(startaddressBtyes, DiscreteNumBtyes);
    super._pduType = PduType.mb_req_pdu;
  }

  @override
  List<int> recv_pdu_rsp_right(Uint8List Pdu_databytes) {
    //需要读的数量是请求pdu的 _DiscreteNum
    //字节计数
    int bytesNum = Pdu_databytes[0];
    //线圈状态
    Uint8List DiscretesBytes = Pdu_databytes.sublist(1);

    //结果数组
    List<int> resDiscretesList = [];
    //逐个字节进行读取，从第一个数据字节的 LSB（最低有效位）开始读，其它线圈依次类推，一直到这个字节的高位端为止，并在后续字节中从低位到高位的顺序。
    for (int BytesIndex = 0; BytesIndex < bytesNum; BytesIndex++) {
      int ByteValue = DiscretesBytes[BytesIndex];
      //如果这个字节的值都是需要读取的值，那就全部都读了  注：魔法数字 8 是一个字节的比特数量
      if ((BytesIndex + 1) * 8 <= _DiscreteNum) {
        for (int curDiscreteByteIndex = 0;
            curDiscreteByteIndex < 8;
            curDiscreteByteIndex++) {
          int DiscreteValue = ByteValue & 0x01;
          resDiscretesList.add(DiscreteValue);
          ByteValue = ByteValue >> 1;
        }
      }
      //对于不满一个字节的值，单独从低到高位读 ，因此要右移
      else {
        int remainDiscreteNum = _DiscreteNum - BytesIndex * 8;
        for (int curDiscreteByteIndex = 0;
            curDiscreteByteIndex < remainDiscreteNum;
            curDiscreteByteIndex++) {
          int DiscreteValue = ByteValue & 0x01;
          resDiscretesList.add(DiscreteValue);
          ByteValue = ByteValue >> 1;
        }
      }
    }
    return resDiscretesList;
  }
}

//0x03
class Pdu03 extends Pdu {
  //请求构造函数
  Pdu03.req_builder(int startaddress, int DiscreteNum) {
    super._functionCode = Uint8List.fromList([0x03]); //功能码一个字节
    assert(startaddress >= 0x0000 && startaddress <= 0xFFFF);
    Uint8List startaddressBtyes =
        BytesOne2Two(int2Bytes(startaddress)); //起始地址两个字节
    Uint8List DiscreteNumBtyes =
        BytesOne2Two(int2Bytes(DiscreteNum)); //线圈数量两个字节
    super._databytes = BytesCat(startaddressBtyes, DiscreteNumBtyes);
    super._pduType = PduType.mb_req_pdu;
  }
  @override
  List<int> recv_pdu_rsp_right(Uint8List Pdu_databytes) {
    //字节计数
    int bytesNum = Pdu_databytes[0];
    //线圈状态
    Uint8List DiscretesBytes = Pdu_databytes.sublist(1);

    //结果数组
    List<int> resDiscretesList = [];
    //逐个字节进行读取，从第一个数据字节的 LSB（最低有效位）开始读，其它线圈依次类推，一直到这个字节的高位端为止，并在后续字节中从低位到高位的顺序。
    for (int BytesIndex = 0;
        BytesIndex < bytesNum;
        BytesIndex = BytesIndex + 2) {
      int ByteValueHigh = DiscretesBytes[BytesIndex]; //高位
      int ByteValueLow = DiscretesBytes[BytesIndex + 1]; //低位
      int ByteValue = HighLowCat(ByteValueHigh, ByteValueLow);
      resDiscretesList.add(ByteValue);
    }
    return resDiscretesList;
  }
}

//0x04
class Pdu04 extends Pdu {
  //请求构造函数
  Pdu04.req_builder(int startaddress, int DiscreteNum) {
    super._functionCode = Uint8List.fromList([0x04]); //功能码一个字节
    assert(startaddress >= 0x0000 && startaddress <= 0xFFFF);
    Uint8List startaddressBtyes =
        BytesOne2Two(int2Bytes(startaddress)); //起始地址两个字节
    Uint8List DiscreteNumBtyes =
        BytesOne2Two(int2Bytes(DiscreteNum)); //线圈数量两个字节
    super._databytes = BytesCat(startaddressBtyes, DiscreteNumBtyes);
    super._pduType = PduType.mb_req_pdu;
  }
  @override
  List<int> recv_pdu_rsp_right(Uint8List Pdu_databytes) {
    //字节计数
    int bytesNum = Pdu_databytes[0];
    //线圈状态
    Uint8List DiscretesBytes = Pdu_databytes.sublist(1);

    //结果数组
    List<int> resDiscretesList = [];
    //逐个字节进行读取，从第一个数据字节的 LSB（最低有效位）开始读，其它线圈依次类推，一直到这个字节的高位端为止，并在后续字节中从低位到高位的顺序。
    for (int BytesIndex = 0;
        BytesIndex < bytesNum;
        BytesIndex = BytesIndex + 2) {
      int ByteValueHigh = DiscretesBytes[BytesIndex]; //高位
      int ByteValueLow = DiscretesBytes[BytesIndex + 1]; //低位
      int ByteValue = HighLowCat(ByteValueHigh, ByteValueLow);
      resDiscretesList.add(ByteValue);
    }
    return resDiscretesList;
  }
}

//0x05
class Pdu05 extends Pdu {
  //请求构造函数
  Pdu05.req_builder(int address, bool DiscreteValue) {
    super._functionCode = Uint8List.fromList([0x05]); //功能码一个字节
    assert(address >= 0x0000 && address <= 0xFFFF);
    Uint8List addressBtyes = BytesOne2Two(int2Bytes(address)); //起始地址两个字节
    Uint8List DiscreteValueBtyes;
    if (DiscreteValue == true) {
      //开关为开时设置为0xff00
      DiscreteValueBtyes =
          BytesCat(int2Bytes(0xff), int2Bytes(0x00)); //线圈数量两个字节
    } else {
      //开关为关时设置为0x0000
      DiscreteValueBtyes =
          BytesCat(int2Bytes(0x00), int2Bytes(0x00)); //线圈数量两个字节
    }

    super._databytes = BytesCat(addressBtyes, DiscreteValueBtyes);
    super._pduType = PduType.mb_req_pdu;
  }

  @override
  List<int> recv_pdu_rsp_right(Uint8List Pdu_databytes) {
    print(Pdu_databytes);
    //线圈状态
    Uint8List DiscreteBytes = Pdu_databytes.sublist(2);

    //结果数组
    List<int> resDiscretesList = [];
    //修改之后的开关量的值
    int DiscreteValue = HighLowCat(DiscreteBytes[0], DiscreteBytes[1]);
    if (DiscreteValue == 0xff00) {
      resDiscretesList.add(1);
    } else {
      resDiscretesList.add(0);
    }

    return resDiscretesList;
  }
}

//0x06
class Pdu06 extends Pdu {
  //请求构造函数
  Pdu06.req_builder(int address, int ContinuousValue) {
    super._functionCode = Uint8List.fromList([0x06]); //功能码一个字节
    assert(address >= 0x0000 && address <= 0xFFFF);
    Uint8List addressBtyes = BytesOne2Two(int2Bytes(address)); //起始地址两个字节
    Uint8List ContinuousValueBtyes = BytesCat(int2Bytes(ContinuousValue >> 8),
        int2Bytes(ContinuousValue & 0x00ff)); //分别获取值的高位与低位，再分别放到不同的字节中

    super._databytes = BytesCat(addressBtyes, ContinuousValueBtyes);
    super._pduType = PduType.mb_req_pdu;
  }

  @override
  List<int> recv_pdu_rsp_right(Uint8List Pdu_databytes) {
    print(Pdu_databytes);
    //线圈状态
    Uint8List ContinuouBytes = Pdu_databytes.sublist(2);

    //结果数组
    List<int> resContinuouList = [];
    //修改之后的开关量的值
    int ContinuouValue = HighLowCat(ContinuouBytes[0], ContinuouBytes[1]);
    resContinuouList.add(ContinuouValue);
    return resContinuouList;
  }
}
