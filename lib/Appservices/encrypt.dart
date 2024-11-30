import 'package:encrypt/encrypt.dart' as encrypt;

class MyEncryptionDecryption {
  static final key = encrypt.Key.fromLength(32);
  static final iv = encrypt.IV.fromLength(16);
  static final encrypter = encrypt.Encrypter(encrypt.AES(key));

  String toEncrypt(String text) {
    final encrypted = encrypter.encrypt(text, iv: iv);
    return encrypted.base64;
  }

  String toDecrypt(String encryptedBase64) {
    final encrypted = encrypt.Encrypted.fromBase64(encryptedBase64);
    String decrypted = encrypter.decrypt(encrypted, iv: iv);
    print(decrypted);
    return decrypted;
  }
}
