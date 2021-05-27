import 'package:flutter/material.dart';
import 'package:pix_epoc/core/utils.dart';

abstract class IPix {
  Future generateQrCode();

  addProvider(Object provider, {bool debug = false});
}
