import 'package:talker/talker.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:flutter/material.dart';

class LoggerPage extends StatefulWidget {
  final Talker talker;
  const LoggerPage(this.talker, {Key? key}) : super(key: key);

  @override
  _LoggerPageState createState() => _LoggerPageState(this.talker);
}

class _LoggerPageState extends State<LoggerPage> {
  final Talker talker;

  _LoggerPageState(this.talker);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TalkerScreen(talker: widget.talker),
    );
  }
}
