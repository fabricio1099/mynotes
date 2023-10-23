import 'package:logger/logger.dart';

var log = Logger(
  printer: PrettyPrinter(
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);