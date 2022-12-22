//异常时 功能码是请求功能码+0x80；异常码用来表示错误的类型
class ModbusErrorEnum {
  static const int NO_ERROR = 0x00;
  static const int ILLEGAL_FUNCTION = 0x01;
  static const int ILLEGAL_DATA_ADDRESS = 0x02;
  static const int ILLEGAL_DATA_VALUE = 0x03;
  static const int SLAVE_DEVICE_FAILURE = 0x04;
  static const int ACKNOWLEDGE = 0x05;
  static const int SLAVE_DEVICE_BUSY = 0x06;
  static const int NEGATIVE_ACKNOWLEDGE = 0x07;
  static const int MEMORY_PARITY_ERROR = 0x08;
  static const int GATEWAY_PATH_UNAVAILABLE = 0x0A;
  static const int GATEWAY_TARGET_DEVICE_FAILED_TO_RESPOND = 0x0B;

  static const _errorMsg = {
    NO_ERROR: 'No error',
    ILLEGAL_FUNCTION: 'Illegal function',
    ILLEGAL_DATA_ADDRESS: 'Illegal data address',
    ILLEGAL_DATA_VALUE: 'Illegal data value',
    SLAVE_DEVICE_FAILURE: 'Slave device failure',
    ACKNOWLEDGE: 'Acknowledge',
    SLAVE_DEVICE_BUSY: 'Slave device busy',
    NEGATIVE_ACKNOWLEDGE: 'Negative acknowledge',
    MEMORY_PARITY_ERROR: 'Memory parity error',
    GATEWAY_PATH_UNAVAILABLE: 'Gateway path unavailable',
    GATEWAY_TARGET_DEVICE_FAILED_TO_RESPOND:
        'Gateway target device failed to respond'
  };
  static String? getErrorMsg(int errorCode) {
    return _errorMsg[errorCode];
  }

  static bool isNoError(int errorCode) {
    return errorCode == NO_ERROR;
  }
}
