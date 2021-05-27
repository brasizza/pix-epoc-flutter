library pix_epoc;

import 'package:pix_epoc/core/controllers/matera_controller.dart';

enum FeeType { value, percentage }

class Pix {
  final Object provider;

  Pix({this.provider});

  static MateraController get materaInstance => MateraController.instance;
}
