// ignore_for_file: public_member_api_docs, sort_constructors_first
class HttpError implements Exception {
  final String msg;
  final int statusCode;

  HttpError({
    required this.msg,
    required this.statusCode,
  });

  @override
  String toString() {
    // TODO: implement toString
    return msg;
  }
}
