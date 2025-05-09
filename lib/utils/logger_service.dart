import 'package:logger/logger.dart';

class LoggerService{
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 4,
      errorMethodCount: 8,
      lineLength: 150,
      colors: true,

    ),

  );

  static void debug(String message){
    _logger.d(message);
  }

  static void info(String message){
    _logger.i(message);
  }

  static void warning(String message){
    _logger.w(message);
  }

  static void error(String message, [dynamic error, StackTrace? stackTreace]){
    _logger.e(message, error: error, stackTrace: stackTreace);
  }
}