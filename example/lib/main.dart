import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_undo/flutter_undo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController controller;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController.fromValue(TextEditingValue(text: 'Hello, Undoable!'));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Undo Example'),
        ),
        body: Center(
          child: UndoableTextElement(
            controller: controller,
            focusNode: focusNode,
            child: TextField(controller: controller, focusNode: focusNode),
          ),
        ),
      ),
    );
  }
}
