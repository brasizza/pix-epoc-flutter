import 'dart:convert';

import 'package:flutter/material.dart';

class Utils {
  Utils._();

  static String base64ToString(String baseString) {
    String decoded = utf8.decode(base64.decode(baseString));
    return decoded;
  }

  static Image imageFromBase64String(String img, {height}) {
    return Image.memory(
      base64Decode(img),
      fit: BoxFit.contain,
      height: height ?? null,
      gaplessPlayback: true,
    );
  }
}
