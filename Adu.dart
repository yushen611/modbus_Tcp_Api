/*
 * @Author: ywy
 */
/*
 * @Author: ywy
 */

import 'dart:typed_data';

import 'Mbap.dart';
import 'Pdu.dart';
import 'ModbusToolFunc.dart';

class Adu {
  late Mbap _mbap;
  late Pdu _pdu;

  //默认构造函数
  Adu(Mbap mbap, Pdu pdu) {
    _mbap = mbap;
    _pdu = pdu;
  }
  //根据pdu自动构造ADU的构造函数
  Adu.autoBuildByPdu(Pdu pdu) {
    _mbap = Mbap(pdu.getPduLength());
    _pdu = pdu;
  }

  //获取Adu的数据帧
  Uint8List getAduBytes() {
    return BytesCat(_mbap.getMbapBytes(), _pdu.getPdubytes());
  }

  //接受函数
  AduResponse receive(Uint8List rsp_Adubytes) {
    AduResponse aduResponse = AduResponse();
    //如果接受的为空 代表TCP错误
    if (rsp_Adubytes.isEmpty) {
      aduResponse._responseType = PduType.mb_excep_rsp_pdu;
      aduResponse._info = "TCP连接错误";
      return aduResponse;
    }
    //不为空代表TCP正常 收到正确的Adu
    Uint8List rsp_pdu_bytes =
        rsp_Adubytes.sublist(7); //获取返回的pdu 因为能返回 mbap就应该是正确的 其长度字段也是冗余用不到
    Uint8List rsp_pdu_datapart_bytes = rsp_pdu_bytes.sublist(1); //pdu除去功能码之后的部分
    PduType pduTpye = _pdu.judgeRecvPduType(rsp_pdu_bytes); //获得到的pdu的类型
    aduResponse.responseType = pduTpye; //设置返回的rsp的类型 /同pdu类型
    if (pduTpye == PduType.mb_right_rsp_pdu) {
      aduResponse.info = "接受成功";
      aduResponse.body = _pdu.recv_pdu_rsp_right(rsp_pdu_datapart_bytes);
    } else if (pduTpye == PduType.mb_excep_rsp_pdu) {
      aduResponse.info = _pdu.recv_rsp_error(rsp_pdu_datapart_bytes)!;
    } else {
      aduResponse.info = "未知错误";
    }
    return aduResponse;
  }
}

class AduResponse {
  PduType _responseType = PduType.mb_unknown_rsp_pdu;
  String _info = ""; //返回内容的说明，如错误的原因 等
  List<int> _body = []; //如果正确就返回正确的读取到的内容 如果错误就返回空的

  set body(List<int> body) => _body = body;
  List<int> get body => _body;

  set info(String info) => _info = info;
  String get info => _info;

  set responseType(PduType responseType) => _responseType = responseType;
  PduType get responseType => _responseType;

  @override
  String toString() {
    var responsemap = {
      "responseType": _responseType,
      "info": _info,
      "body": _body
    };
    return responsemap.toString();
  }
}
