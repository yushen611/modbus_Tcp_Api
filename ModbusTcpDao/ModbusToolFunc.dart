import 'dart:typed_data';

//工具函数：int转成字节
Uint8List int2Bytes(int num) {
  final bytesBuilder = BytesBuilder();
  bytesBuilder.addByte(num);
  Uint8List byteList = bytesBuilder.toBytes();
  return byteList;
}

//把小于等于2个字节的btyes转化成2个字节的bytes
Uint8List BytesOne2Two(Uint8List oneLengthbytes) {
  int bytesNum = oneLengthbytes.length; //字节数量
  assert(bytesNum >= 1);
  assert(bytesNum <= 2);
  if (bytesNum == 1) {
    final bytesBuilder = BytesBuilder();
    bytesBuilder.add([0x00]);
    bytesBuilder.add(oneLengthbytes);
    Uint8List byteList = bytesBuilder.toBytes();
    return byteList;
  } else if (bytesNum == 2) {
    return oneLengthbytes;
  } else {
    return Uint8List(2);
  }
}

//拼接两个bytes
Uint8List BytesCat(Uint8List frontBytes, Uint8List afterByes) {
  final bytesBuilder = BytesBuilder();
  bytesBuilder.add(frontBytes);
  bytesBuilder.add(afterByes);
  Uint8List byteList = bytesBuilder.toBytes();
  return byteList;
}

//把高低位的两个bytes转化成int
int HighLowCat(int highInt, int LowInt) {
  int res = (highInt << 8) + LowInt;
  return res;
}
/**
class Hex {
  String hexStr = "";
  Hex(Uint8List byteArr) {
    hexStr = uint8ToHex(byteArr);
  }

  @override
  String toString() {
    return hexStr;
  }

  //返回Hex中包含的字节数
  int getBytesNum() {
    return ((hexStr.length) / 2).round();
  }

  //工具函数：unit8tohex
  static String uint8ToHex(Uint8List byteArr) {
    if (byteArr.length == 0) {
      return "";
    }
    Uint8List result = Uint8List(byteArr.length << 1);
    var hexTable = [
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      'A',
      'B',
      'C',
      'D',
      'E',
      'F'
    ]; //16进制字符表
    for (var i = 0; i < byteArr.length; i++) {
      var bit = byteArr[i]; //取传入的byteArr的每一位
      var index = bit >> 4 & 15; //右移4位,取剩下四位
      var i2 = i << 1; //byteArr的每一位对应结果的两位,所以对于结果的操作位数要乘2
      result[i2] = hexTable[index].codeUnitAt(0); //左边的值取字符表,转为Unicode放进resut数组
      index = bit & 15; //取右边四位
      result[i2 + 1] =
          hexTable[index].codeUnitAt(0); //右边的值取字符表,转为Unicode放进resut数组
    }
    return String.fromCharCodes(result); //Unicode转回为对应字符,生成字符串返回
  }
}
*/