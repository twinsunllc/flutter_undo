# Flutter Undo

This package provides a mechanism to interact with `UndoManager` on iOS.

## Getting Started

The easiest way to use the plugin is to wrap a text editing widget in the `UndoableTextElement` widget:

```dart
UndoableTextElement(
  controller: controller,
  focusNode: focusNode,
  child: TextField(controller: controller, focusNode: focusNode),
);
```

For more control, you can interact with the `UndoManager` directly:

```dart
// Register a command
UndoManager.instance.registerCommand(
  UndoCommand(
    undo: (identifier) {
      widget.controller.value = lastValue;
    },
    redo: (identifier) {
      widget.controller.value = currentValue;
    },
  ),
);
```

```dart
// Clear the undo stack
UndoManager.instance.reset();
```
