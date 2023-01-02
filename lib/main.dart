import 'package:f_logs/f_logs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timemanagement/firebase_initializer.dart';
import 'package:flutter_timemanagement/screen/login_screen.dart';
import 'package:flutter_timemanagement/util/authentication_notifier.dart';
import 'package:flutter_timemanagement/widgets/main_menu.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initLogs();
  runApp(FirebaseInitializer());
}

void initLogs() {
  LogsConfig config = FLog.getDefaultConfigurations()
    ..isDevelopmentDebuggingEnabled = true
    ..timestampFormat = TimestampFormat.TIME_FORMAT_FULL_3
    ..formatType = FormatType.FORMAT_CUSTOM
    ..fieldOrderFormatCustom = [
      FieldName.TIMESTAMP,
      FieldName.LOG_LEVEL,
      FieldName.CLASSNAME,
      FieldName.METHOD_NAME,
      FieldName.TEXT,
      FieldName.EXCEPTION,
      FieldName.STACKTRACE
    ]
    ..customOpeningDivider = "{"
    ..customClosingDivider = "}";

  FLog.applyConfigurations(config);
}

class MyApp extends StatelessWidget {

  AuthenticationNotifier notifier = AuthenticationNotifier();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: notifier,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BeProductive',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Builder(builder: (context) {
          var isAuthenticated = context.watch<AuthenticationNotifier>().isAuthenticated;
          return isAuthenticated ? MainMenu() : LoginScreen();
        }),
        initialRoute: '/',
      ),
    );
  }
}