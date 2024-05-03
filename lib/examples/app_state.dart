import 'package:flutter/material.dart';
import 'package:flutter_rearch/flutter_rearch.dart';
import 'package:rearch/rearch.dart';
import 'package:rearch_example/examples/common/types.dart';

// Feedback & Questions:
//
// 1. Can we use a approach like `scoped_zone_state.dart` to create a zone
//    that shares state across multiple widgets in the widget tree?

CountManager appCountManager(CapsuleHandle use) {
  final (count, setCount) = use.data(0);
  return (
    count: count,
    incrementCount: () => setCount(count() + 1),
  );
}

class AppStatePage extends RearchConsumer {
  const AppStatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetHandle use) {
    use(appCountManager);
    return Scaffold(
      appBar: AppBar(title: const Text('App State Example')),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SharedState(),
          SharedState(),
        ],
      ),
    );
  }
}

class SharedState extends RearchConsumer {
  const SharedState({super.key});

  @override
  Widget build(BuildContext context, WidgetHandle use) {
    final (:count, :incrementCount) = use(appCountManager);
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
