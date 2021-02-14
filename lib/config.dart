import 'dart:ui';

class Config {
  static const int SCALE = 4;
  static const Color COLOR_FONT_DARK = Color(0xFF776E65);
  static const Color COLOR_FONT_LIGHT = Color(0xFFF9F6F2);
  static const Color COLOR_BG = Color(0xFFBBADA0);
  static const Color COLOR_EMPTY = Color(0xFFCDC1B4);
  static const Color COLOR_0 = Color(0x00000000);
  static const Color COLOR_2 = Color(0xFFEEE4DA);
  static const Color COLOR_4 = Color(0xFFEEE1C9);
  static const Color COLOR_8 = Color(0xFFF3B27A);
  static const Color COLOR_16 = Color(0xFFF69664);
  static const Color COLOR_32 = Color(0xFFF77C5F);
  static const Color COLOR_64 = Color(0xFFF75F3B);
  static const Color COLOR_128 = Color(0xFFEDD073);
  static const Color COLOR_256 = Color(0xFFEDCC62);
  static const Color COLOR_512 = Color(0xFFECC402);
  static const Color COLOR_1024 = Color(0xFFC9DD22);
  static const Color COLOR_2048 = Color(0xFF60D992);
  static const Color COLOR_WHITE_MASK = Color(0x80FFFFFF);
  static const COLOR_MAP = {
    0: Config.COLOR_0,
    2: Config.COLOR_2,
    4: Config.COLOR_4,
    8: Config.COLOR_8,
    16: Config.COLOR_16,
    32: Config.COLOR_32,
    64: Config.COLOR_64,
    128: Config.COLOR_128,
    256: Config.COLOR_256,
    512: Config.COLOR_512,
    1024: Config.COLOR_1024,
    2048: Config.COLOR_2048,
    4096: Config.COLOR_2048,
    8192: Config.COLOR_2048,
  };
  static const SIZE_MAP = {
    1: 2.5,
    2: 2.5,
    3: 3.5,
    4: 5.25,
  };
}
