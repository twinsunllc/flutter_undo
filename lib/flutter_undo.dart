import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

class UndoManager {
  UndoManager._() {
    _channel = MethodChannel('flutter_undo');
    _channel.setMethodCallHandler(_handleUndoInvocation);
  }

  static final UndoManager _instance = UndoManager._();

  MethodChannel _channel;

  Map<String, UndoCommand> _commands = {};

  Future<dynamic> _handleUndoInvocation(MethodCall methodCall) async {
    Logger.root.finest('[UndoManager] ${methodCall.method}: ${methodCall.arguments}');
    switch (methodCall.method) {
      case 'UndoManager.undo':
        if (_commands.containsKey(methodCall.arguments)) {
          _commands[methodCall.arguments].performUndo();
        } else {
          Logger.root.finest('[UndoManager][undo] command ${methodCall.arguments} not found');
        }
        return;
      case 'UndoManager.redo':
        if (_commands.containsKey(methodCall.arguments)) {
          _commands[methodCall.arguments].performRedo();
        } else {
          Logger.root.finest('[UndoManager][redo] command ${methodCall.arguments} not found');
        }
        return;
      default:
        throw MissingPluginException();
    }
  }

  void reset() {
    Logger.root.finest('[UndoManager] clear');
    _commands.clear();
    if (defaultTargetPlatform == TargetPlatform.iOS) _channel.invokeMethod('UndoManagerPlugin.reset');
  }

  void registerCommand(UndoCommand command) {
    Logger.root.finest('[UndoManager] register ${command.identifier}');
    _commands[command.identifier] = command;
    if (defaultTargetPlatform == TargetPlatform.iOS) _channel.invokeMethod('UndoManagerPlugin.register', command.identifier);
  }
}

typedef UndoCallback = void Function(String identifier);

class UndoCommand {
  UndoCommand({
    @required this.undo,
    @required this.redo,
  }) : _identifier = (_nextIdentifier++).toString();

  final UndoCallback undo;
  final UndoCallback redo;

  static int _nextIdentifier = 1;
  String _identifier;

  String get identifier => _identifier;

  void performUndo() => undo(identifier);

  void performRedo() => redo(identifier);
}

class UndoableTextElement extends StatefulWidget {
  UndoableTextElement({
    Key key,
    @required this.controller,
    @required this.focusNode,
    @required this.child,
  }) : super(key: key);

  final Widget child;
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  _UndoableTextElementState createState() => _UndoableTextElementState();
}

class _UndoableTextElementState extends State<UndoableTextElement> {
  TextEditingValue _lastValue;
  final List<String> _operationsInProgress = [];
  bool get _undoOrRedoInProgress => _operationsInProgress.isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onValueChanged);
    _lastValue = widget.controller.value;
  }

  @override
  void dispose() {
    super.dispose();
    widget.focusNode.removeListener(_onFocusChanged);
    widget.controller.removeListener(_onValueChanged);
  }

  void _onFocusChanged() {
    UndoManager._instance.reset();
  }

  void _onValueChanged() {
    Logger.root.finest('[UndoableTextElement] _onValueChanged: ${widget.controller.value} ($_lastValue)');
    if (!widget.focusNode.hasPrimaryFocus) {
      Logger.root.finest('[UndoableTextElement] _onValueChanged does not have focus; ignoring');
      return;
    }
    if (_undoOrRedoInProgress) {
      Logger.root.finest('[UndoableTextElement] undo or redo in progress; ignoring');
      _lastValue = widget.controller.value;
      return;
    }
    if (widget.controller.value.text == _lastValue.text) {
      Logger.root.finest('[UndoableTextElement] text is unchanged; ignoring');
      return;
    }
    Logger.root.finest('[UndoableTextElement] text changed from "${_lastValue.text}" to "${widget.controller.value.text}"');
    final currentValue = widget.controller.value.copyWith();
    final lastValue = this._lastValue.copyWith();
    UndoManager._instance.registerCommand(
      UndoCommand(
        undo: (identifier) {
          _operationsInProgress.add(identifier);
          widget.controller.value = lastValue;
          _operationsInProgress.remove(identifier);
        },
        redo: (identifier) {
          _operationsInProgress.add(identifier);
          widget.controller.value = currentValue;
          _operationsInProgress.remove(identifier);
        },
      ),
    );
    _lastValue = currentValue;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}