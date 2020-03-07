import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:fast_gbk/fast_gbk.dart';

enum AlgType {
  aes,
  salsa20
}

class AesCoder {
  Key _key;
  AlgType _algType;

  AesCoder(String key,AlgType algtype) {
    var utf8key = utf8.encode(key);
    var hashkey = md5.convert(utf8key).bytes;
    print(hashkey.length);
    _key = Key(hashkey);
    _algType = algtype;
  }

  IV _buildIV(int seed) {
    final _generator = Random(seed);
    final _bytes = Uint8List.fromList(
      List.generate(8, (i) => _generator.nextInt(256)));
    return IV(_bytes);
  }

  Uint8List enCrypt(List<int> bytes) {
    final seed = DateTime.now().millisecondsSinceEpoch%0xFF;
    final iv = _buildIV(seed);
    //final encrypter = Encrypter(AES(_key, mode: AESMode.ctr));  
    var encrypter;
    if(_algType == AlgType.salsa20)
      encrypter = Encrypter(Salsa20(_key));
    else
      encrypter = Encrypter(AES(_key, mode: AESMode.ctr));
    final encrypted = encrypter.encryptBytes(bytes, iv: iv);
    print(encrypted.bytes);
    return Uint8List.fromList([seed,...encrypted.bytes]);
  }

  Uint8List deCrypt(List<int> bytes) {
    final seed = bytes[0];
    final iv = _buildIV(seed);
    //final encrypter = Encrypter(AES(_key, mode: AESMode.ctr)); 
    var encrypter;
    if(_algType == AlgType.salsa20)
      encrypter = Encrypter(Salsa20(_key));
    else
      encrypter = Encrypter(AES(_key, mode: AESMode.ctr));
    final encrypted = Encrypted(Uint8List.fromList(bytes.sublist(1)));     
    return Uint8List.fromList(encrypter.decryptBytes(encrypted, iv: iv));
  }
}

class BaseGbkEncoder {  
  static Uint8List encode(List<int> src) {
    if(src.length == 0)
      return Uint8List(0);
    var dst = Uint8List((src.length +2)~/3*4);
    int si = 0,di = 0;
    final int n = (src.length ~/ 3)*3;
    while(si < n) {
      int val = (src[si+0]<<16 | src[si+1]<<8 | src[si+2])&0xFFFFFF;
      int high = val>>12&0xFFF;
      int low = val&0xFFF;
      dst[di + 0] = 0xB0 + high~/94;
      dst[di + 1] = 0xA0 + high%94+1;
      dst[di + 2] = 0xB0 + low~/94;
      dst[di + 3] = 0xA0+ low%94+1;
      si += 3;
      di += 4;
    }
    final remain = src.length - si;
    if(remain == 0)
      return dst;
    //余下的,以256个字符,第六十一区开始
    for(;si < src.length;si++) {
      var val = src[si]&0xFF;
      dst[di] = (0xDD + val~/94)&0xFF;
      dst[di + 1] = (0xA0 + val%94+1)&0xFF;
      di += 2;
    }
    if(remain == 1) {
      dst[di] = 0xA1;
      dst[di+1] = 0xA3;
      di += 2;
    }    
    return dst;
  }

  static String encodeString(String src) {
    final val = gbk.encode(src);
    final dst = encode(val);
    return gbk.decode(dst);
  }  

  static int decode(Uint8List dst,List<int> src) {
    if(src.length == 0) {
      return 0;      
    }
    final ilen = src.length;
    final olen = dst.length;
    if(ilen % 2 != 0) {
      return -1;
    }
    int si = 0;
    int n = 0;
    while(si < ilen && n < olen) {
      if(src[si] == 0xA3 && src[si + 1] == 0xAC ||  src[si] == 0xA1 && src[si + 1] == 0xA3) {
        si += 2;
        continue;
      }
      int val = 0;
      if(src[si] >= 0xB0 && src[si] <= 0xDC) {
        var high = (src[si] - 0xB0)*94 + (src[si + 1] -0xA1);
        val |= high<<20;
        var low = (src[si+2] - 0xB0)*94 + (src[si + 3] -0xA1);
        val |= low<<8;
        dst[n + 0] = (val >> 24)&0xFF;
        dst[n + 1] = (val >> 16)&0xFF;
        dst[n + 2] = (val >> 8)&0xFF;
        si += 4;
        n += 3;
      } else if(src[si] >= 0xDD && src[si] <= 0xDD + 3) {
        if(ilen - si > 4) {
          return -1;
        }
        var val = (src[si] - 0xDD)*94 + (src[si + 1] -0xA1);
        dst[n] = val&0xFF;
        n++;
        si += 2;
      } else {
        return -1;
      }
    }
    return n;
  }

  static int decodeLen(int n) {
    return n~/4 *3;
  }

  static Uint8List decodeBytes(List<int> src) {
    var n = decodeLen(src.length);
    var dst = Uint8List(n);
    n = decode(dst, src);
    if(n <= 0) {
      return Uint8List(0);
    }    
    return dst.sublist(0,n);
  }

  static Uint8List decodeString(String src) {
    final input = gbk.encode(src);
    var n = decodeLen(input.length);
    var dst = Uint8List(n);
    n = decode(dst, input);
    if(n <= 0) {
      return Uint8List(0);
    }
    return dst;
  }
}