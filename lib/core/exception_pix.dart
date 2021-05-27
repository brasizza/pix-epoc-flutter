class ExceptionPix implements Exception {
  final String msg;
  const ExceptionPix(this.msg);
  String toString() => msg;
}
