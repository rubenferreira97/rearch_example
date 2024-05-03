import 'package:flutter/material.dart';
import 'package:flutter_rearch/flutter_rearch.dart';
import 'package:rearch/rearch.dart';

// Feedback & Questions:
//
// 1. Can we replace the following code with a capsule (or factory) that creates
// a new state for each new widget instance?

// CountManager localCountManager(CapsuleHandle use) {
//   final (count, setCount) = use.data(0);
//   return (
//     count: count,
//     incrementCount: () => setCount(count() + 1),
//   );
// }

class LocalStatePage extends StatelessWidget {
  const LocalStatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local State Example')),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          LocalState(),
          LocalState(),
        ],
      ),
    );
  }
}

class LocalState extends RearchConsumer {
  const LocalState({super.key});

  @override
  Widget build(BuildContext context, WidgetHandle use) {
    // Can we replace the following code with a capsule (or factory) that
    // creates a new state for each new widget instance?
    final (:count, :incrementCount) = (() {
      // Using a IIFE to encapsulate the state and actions.
      // If possible use a capsule to allow reuse and encapsulation across
      // multiple widgets.
      final (count, setCount) = use.data(0);
      return (
        count: count,
        incrementCount: () => setCount(count() + 1),
      );
    })();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('You have pushed the button this many times:'),
        Text('${count()}'),
        ElevatedButton(
          onPressed: incrementCount,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
